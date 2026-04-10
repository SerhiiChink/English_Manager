const functions = require('firebase-functions/v1');
const admin = require('firebase-admin');

admin.initializeApp();
const db = admin.firestore();

// ─────────────────────────────────────────
// MARK: - Generate Occurrences (щонеділі)
// ─────────────────────────────────────────
exports.generateWeeklyOccurrences = functions
    .pubsub
    .schedule('0 20 * * 0')  // ← cron формат: о 20:00 щонеділі
    .timeZone('Europe/Kiev')
    .onRun(async (context) => {
        const schedules = await db.collection('schedules')
            .where('isActive', '==', true)
            .get()
        
        const batch = db.batch()
        const nextMonday = getNextMonday()
        
        for (const doc of schedules.docs) {
            const schedule = doc.data()
            const lessonDate = getDateForWeekday(
                nextMonday,
                schedule.weekday,
                schedule.time
            )
            const existing = await db.collection('lessonOccurrences')
                .where('scheduleId', '==', doc.id)
                .where('scheduledAt', '==', lessonDate)
                .get()
            
            if (existing.empty) {
                const ref = db.collection('lessonOccurrences').doc()
                batch.set(ref, {
                    studentId: schedule.studentId,
                    teacherId: schedule.teacherId,
                    scheduleId: doc.id,
                    scheduledAt: lessonDate,
                    status: 'scheduled',
                    createdAt: new Date()
                })
            }
        }
        await batch.commit()
        console.log('Weekly occurrences generated')
        return null
    })

// ─────────────────────────────────────────
// MARK: - Send Reminders (кожну годину)
// ─────────────────────────────────────────
exports.sendLessonReminders = functions
    .pubsub
    .schedule('0 * * * *')  // ← кожну годину
    .timeZone('Europe/Kiev')
    .onRun(async (context) => {
        const now = new Date()
        const inOneHour = new Date(now.getTime() + 60 * 60 * 1000)
        const inOneHourPlus5 = new Date(inOneHour.getTime() + 5 * 60 * 1000)
        
        const snapshot = await db.collection('lessonOccurrences')
            .where('scheduledAt', '>=', inOneHour)
            .where('scheduledAt', '<=', inOneHourPlus5)
            .where('status', '==', 'scheduled')
            .get()
        
        const promises = snapshot.docs.map(async (doc) => {
            const occurrence = doc.data()
            const student = await db.collection('users')
                .doc(occurrence.studentId).get()
            const fcmToken = student.data()?.fcmToken
            if (!fcmToken) return
            
            return admin.messaging().send({
                token: fcmToken,
                notification: {
                    title: 'Заняття через годину 📚',
                    body: 'Не забудьте підготуватись!'
                },
                data: {
                    type: 'lesson_reminder',
                    occurrenceId: doc.id
                },
                apns: {
                    payload: {
                        aps: { category: 'LESSON_REMINDER' }
                    }
                }
            })
        })
        
        await Promise.all(promises)
        console.log(`Reminders sent for ${snapshot.size} lessons`)
        return null
    })

// ─────────────────────────────────────────
// MARK: - Process Lessons (кожну годину)
// ─────────────────────────────────────────
exports.processCompletedLessons = functions
    .pubsub
    .schedule('0 * * * *') // кожну годину
    .timeZone('Europe/Kiev')
    .onRun(async () => {
        const now = new Date()

        const snapshot = await db.collection('lessonOccurrences')
            .where('scheduledAt', '<=', now)
            .where('status', '==', 'scheduled')
            .get()

        if (snapshot.empty) {
            console.log("No lessons to process")
            return null
        }

        const batch = db.batch()
        const pushPromises = []

        for (const doc of snapshot.docs) {
            const occurrence = doc.data()

            const studentRef = db.collection('users').doc(occurrence.studentId)
            const studentDoc = await studentRef.get()

            if (!studentDoc.exists) continue

            const currentBalance = studentDoc.data()?.lessonsBalance || 0

            const newBalance = Math.max(currentBalance - 1, 0)

            batch.update(studentRef, {
                lessonsBalance: admin.firestore.FieldValue.increment(-1)
            })

            batch.update(doc.ref, {
                status: 'completed',
                processedAt: now
            })

            if (currentBalance <= 1) {
                const fcmToken = studentDoc.data()?.fcmToken

                if (fcmToken) {
                    pushPromises.push(
                        admin.messaging().send({
                            token: fcmToken,
                            notification: {
                                title: 'Уроки закінчились 📚',
                                body: 'Поповніть баланс 💳'
                            },
                            data: {
                                type: 'balance_empty'
                            }
                        })
                    )
                }
            }
        }

        await batch.commit()
        await Promise.all(pushPromises)

        console.log(`Processed ${snapshot.size} lessons`)
        return null
    })

// ─────────────────────────────────────────
// MARK: - Homework Reviewed Push
// ─────────────────────────────────────────
exports.onHomeworkReviewed = functions
    .firestore
    .document('homeworks/{homeworkId}')
    .onUpdate(async (change, context) => {
        const before = change.before.data()
        const after = change.after.data()
        
        if (before.status === after.status) return null
        if (after.status !== 'reviewed') return null
        
        const student = await db.collection('users')
            .doc(after.studentId).get()
        const fcmToken = student.data()?.fcmToken
        if (!fcmToken) return null
        
        const grade = after.grade ? ` Оцінка: ${after.grade}/10` : ''
        
        await admin.messaging().send({
            token: fcmToken,
            notification: {
                title: 'Домашку перевірено ✅',
                body: `${after.title}${grade}`
            },
            data: {
                type: 'homework_reviewed',
                homeworkId: change.after.id
            }
        })
        return null
    })

// ─────────────────────────────────────────
// MARK: - Payment Created Push
// ─────────────────────────────────────────
exports.onPaymentCreated = functions
    .firestore
    .document('payments/{paymentId}')
    .onCreate(async (snap, context) => {
        const payment = snap.data()
        
        const teacher = await db.collection('users')
            .doc(payment.teacherId).get()
        const fcmToken = teacher.data()?.fcmToken
        if (!fcmToken) return null
        
        await admin.messaging().send({
            token: fcmToken,
            notification: {
                title: 'Нова оплата 💳',
                body: `${payment.studentName} оплатив ${payment.lessonsCount} занять`
            },
            data: {
                type: 'payment_pending',
                paymentId: snap.id
            }
        })
        return null
    })

// ─────────────────────────────────────────
// MARK: - Payment Confirmed Push
// ─────────────────────────────────────────
exports.onPaymentConfirmed = functions
    .firestore
    .document('payments/{paymentId}')
    .onUpdate(async (change, context) => {
        const before = change.before.data()
        const after = change.after.data()
        
        if (before.status === after.status) return null
        if (after.status !== 'confirmed') return null
        
        const student = await db.collection('users')
            .doc(after.studentId).get()
        const fcmToken = student.data()?.fcmToken
        if (!fcmToken) return null
        
        await admin.messaging().send({
            token: fcmToken,
            notification: {
                title: 'Оплату підтверджено ✅',
                body: `Додано ${after.confirmedLessons || after.lessonsCount} занять`
            },
            data: {
                type: 'payment_confirmed',
                paymentId: change.after.id
            }
        })
        return null
    })

// ─────────────────────────────────────────
// MARK: - Helpers
// ─────────────────────────────────────────
function getNextMonday() {
    const now = new Date()
    const day = now.getDay()
    const daysUntilMonday = day === 0 ? 1 : 8 - day
    const nextMonday = new Date(now)
    nextMonday.setDate(now.getDate() + daysUntilMonday)
    nextMonday.setHours(0, 0, 0, 0)
    return nextMonday
}

function getDateForWeekday(weekStart, weekday, time) {
    const date = new Date(weekStart)
    date.setDate(weekStart.getDate() + weekday - 1)
    const [hours, minutes] = time.split(':').map(Number)
    date.setHours(hours, minutes, 0, 0)
    return date
}