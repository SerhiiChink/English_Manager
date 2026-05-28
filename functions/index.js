const functions = require('firebase-functions/v1');
const admin = require('firebase-admin');

admin.initializeApp();
const db = admin.firestore();

// ─────────────────────────────────────────
// MARK: - Generate Occurrences (weekly)
// ─────────────────────────────────────────
exports.generateWeeklyOccurrences = functions
    .pubsub
    .schedule('0 20 * * 0')
    .timeZone('Europe/Kiev')
    .onRun(async () => {
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
// MARK: - Schedule Created
// ─────────────────────────────────────────
exports.onScheduleCreated = functions
    .firestore
    .document('schedules/{scheduleId}')
    .onCreate(async (snap) => {
        const schedule = snap.data()
        if (!schedule.isActive) return null

        const nextDate = getNextDateForWeekday(
            new Date(),
            schedule.weekday,
            schedule.time
        )

        await db.collection('lessonOccurrences').add({
            studentId: schedule.studentId,
            teacherId: schedule.teacherId,
            scheduleId: snap.id,
            scheduledAt: nextDate,
            status: 'scheduled',
            createdAt: new Date()
        })

        console.log(`Occurrence created for schedule ${snap.id}`)
        return null
    })

// ─────────────────────────────────────────
// MARK: - Schedule Updated
// ─────────────────────────────────────────
exports.onScheduleUpdated = functions
    .firestore
    .document('schedules/{scheduleId}')
    .onUpdate(async (change) => {
        const before = change.before.data()
        const after = change.after.data()

        if (before.weekday === after.weekday &&
            before.time === after.time) return null

        const oldOccurrences = await db.collection('lessonOccurrences')
            .where('scheduleId', '==', change.after.id)
            .where('status', '==', 'scheduled')
            .get()

        const batch = db.batch()
        oldOccurrences.docs.forEach(doc => batch.delete(doc.ref))

        if (after.isActive) {
            const nextDate = getNextDateForWeekday(
                new Date(),
                after.weekday,
                after.time
            )
            const newRef = db.collection('lessonOccurrences').doc()
            batch.set(newRef, {
                studentId: after.studentId,
                teacherId: after.teacherId,
                scheduleId: change.after.id,
                scheduledAt: nextDate,
                status: 'scheduled',
                createdAt: new Date()
            })
        }

        await batch.commit()
        console.log(`Schedule ${change.after.id} updated`)
        return null
    })

// ─────────────────────────────────────────
// MARK: - Schedule Deleted
// ─────────────────────────────────────────
exports.onScheduleDeleted = functions
    .firestore
    .document('schedules/{scheduleId}')
    .onDelete(async (snap) => {
        const occurrences = await db.collection('lessonOccurrences')
            .where('scheduleId', '==', snap.id)
            .where('status', '==', 'scheduled')
            .get()

        if (occurrences.empty) return null

        const batch = db.batch()
        occurrences.docs.forEach(doc => batch.delete(doc.ref))
        await batch.commit()

        console.log(`Deleted ${occurrences.size} occurrences for schedule ${snap.id}`)
        return null
    })

// ─────────────────────────────────────────
// MARK: - Process Lessons (every 2 hours)
// ─────────────────────────────────────────
exports.processCompletedLessons = functions
    .pubsub
    .schedule('0 */2 * * *')
    .timeZone('Europe/Kiev')
    .onRun(async () => {
        const now = new Date()

        const snapshot = await db.collection('lessonOccurrences')
            .where('scheduledAt', '<=', now)
            .where('status', '==', 'scheduled')
            .get()

        if (snapshot.empty) {
            console.log('No lessons to process')
            return null
        }

        const studentIds = [...new Set(
            snapshot.docs.map(d => d.data().studentId)
        )]
        const studentDocs = await Promise.all(
            studentIds.map(id => db.collection('users').doc(id).get())
        )
        const studentsMap = {}
        studentDocs.forEach(doc => {
            if (doc.exists) studentsMap[doc.id] = doc
        })

        const batch = db.batch()
        const pushPromises = []
        const scheduleCache = {}

        for (const doc of snapshot.docs) {
            const occurrence = doc.data()
            const studentDoc = studentsMap[occurrence.studentId]
            if (!studentDoc) continue

            const studentData = studentDoc.data()
            const isAutoDebit = studentData?.isAutoDebitEnabled === true

            batch.update(doc.ref, {
                status: 'completed',
                processedAt: now
            })

            if (isAutoDebit) {
                const currentBalance = studentData?.lessonsBalance || 0
                const newBalance = currentBalance - 1

                batch.update(studentDoc.ref, {
                    lessonsBalance: admin.firestore.FieldValue.increment(-1)
                })

                if (newBalance <= 0) {
                    const fcmToken = studentData?.fcmToken
                    if (fcmToken) {
                        pushPromises.push(
                            admin.messaging().send({
                                token: fcmToken,
                                apns: {
                                    payload: {
                                        aps: {
                                            alert: {
                                                'title-loc-key': 'push_balance_empty_title',
                                                'loc-key': 'push_balance_empty_body'
                                            },
                                            sound: 'default'
                                        }
                                    }
                                },
                                data: { type: 'balance_empty' }
                            })
                        )
                    }
                }
            }

            if (!scheduleCache[occurrence.scheduleId]) {
                scheduleCache[occurrence.scheduleId] = await db
                    .collection('schedules')
                    .doc(occurrence.scheduleId)
                    .get()
            }
            const scheduleDoc = scheduleCache[occurrence.scheduleId]
            if (!scheduleDoc.exists || !scheduleDoc.data().isActive) continue

            const currentScheduledAt = occurrence.scheduledAt.toDate()
            const nextDate = new Date(currentScheduledAt)
            nextDate.setDate(nextDate.getDate() + 7)

            const existing = await db.collection('lessonOccurrences')
                .where('scheduleId', '==', occurrence.scheduleId)
                .where('scheduledAt', '==', nextDate)
                .get()

            if (existing.empty) {
                const newRef = db.collection('lessonOccurrences').doc()
                batch.set(newRef, {
                    studentId: occurrence.studentId,
                    teacherId: occurrence.teacherId,
                    scheduleId: occurrence.scheduleId,
                    scheduledAt: nextDate,
                    status: 'scheduled',
                    createdAt: now
                })
            }
        }

        await batch.commit()
        await Promise.all(pushPromises)
        console.log(`Processed ${snapshot.size} lessons`)
        return null
    })

// ─────────────────────────────────────────
// MARK: - Send Reminders (every hour)
// ─────────────────────────────────────────
exports.sendLessonReminders = functions
    .pubsub
    .schedule('0 * * * *')
    .timeZone('Europe/Kiev')
    .onRun(async () => {
        const now = new Date()
        const inOneHour = new Date(now.getTime() + 60 * 60 * 1000)
        const inOneHourPlus5 = new Date(inOneHour.getTime() + 5 * 60 * 1000)

        const snapshot = await db.collection('lessonOccurrences')
            .where('scheduledAt', '>=', inOneHour)
            .where('scheduledAt', '<=', inOneHourPlus5)
            .where('status', '==', 'scheduled')
            .get()

        if (snapshot.empty) return null

        const studentIds = [...new Set(
            snapshot.docs.map(d => d.data().studentId)
        )]
        const studentDocs = await Promise.all(
            studentIds.map(id => db.collection('users').doc(id).get())
        )
        const studentsMap = {}
        studentDocs.forEach(doc => {
            if (doc.exists) studentsMap[doc.id] = doc.data()
        })

        const promises = snapshot.docs.map(doc => {
            const occurrence = doc.data()
            const student = studentsMap[occurrence.studentId]
            const fcmToken = student?.fcmToken
            if (!fcmToken) return null

            return admin.messaging().send({
                token: fcmToken,
                apns: {
                    payload: {
                        aps: {
                            alert: {
                                'title-loc-key': 'push_lesson_reminder_title',
                                'loc-key': 'push_lesson_reminder_body'
                            },
                            sound: 'default'
                        }
                    }
                },
                data: {
                    type: 'lesson_reminder',
                    occurrenceId: doc.id
                }
            })
        }).filter(Boolean)

        await Promise.all(promises)
        console.log(`Reminders sent for ${snapshot.size} lessons`)
        return null
    })

// ─────────────────────────────────────────
// MARK: - Payment Created Push
// ─────────────────────────────────────────
exports.onPaymentCreated = functions
    .firestore
    .document('payments/{paymentId}')
    .onCreate(async (snap) => {
        const payment = snap.data()

        const teacher = await db.collection('users')
            .doc(payment.teacherId).get()
        const fcmToken = teacher.data()?.fcmToken
        if (!fcmToken) return null

        await admin.messaging().send({
            token: fcmToken,
            apns: {
                payload: {
                    aps: {
                        alert: {
                            'title-loc-key': 'push_payment_pending_title',
                            'loc-key': 'push_payment_pending_body',
                            'loc-args': [payment.studentName, String(payment.lessonsCount)]
                        },
                        sound: 'default'
                    }
                }
            },
            data: {
                type: 'payment_pending',
                paymentId: snap.id
            }
        })
        return null
    })

// ─────────────────────────────────────────
// MARK: - Student Removed (cascade delete)
// ─────────────────────────────────────────
exports.onStudentRemoved = functions
    .firestore
    .document('users/{studentId}')
    .onUpdate(async (change) => {
        const before = change.before.data()
        const after = change.after.data()

        if (!before.teacherId || after.teacherId) return null

        const studentId = change.after.id
        const teacherId = before.teacherId

        console.log(`Student ${studentId} removed from teacher ${teacherId}, starting cascade delete`)

        const collections = [
            'lessons',
            'homeworks',
            'payments',
            'schedules',
            'lessonOccurrences'
        ]

        await Promise.all(
            collections.map(col => cascadeDelete(col, studentId, teacherId))
        )

        console.log(`Cascade delete complete for student ${studentId}`)
        return null
    })

// ─────────────────────────────────────────
// MARK: - Account Deleted (full cleanup)
// ─────────────────────────────────────────
exports.onAccountDeleted = functions
    .auth
    .user()
    .onDelete(async (user) => {
        const userId = user.uid

        const userDoc = await db.collection('users').doc(userId).get()
        if (!userDoc.exists) return null

        const userData = userDoc.data()
        const role = userData?.role
        const teacherId = userData?.teacherId

        if (role === 'teacher') {
            const students = await db.collection('users')
                .where('teacherId', '==', userId)
                .get()
            const batch = db.batch()
            students.docs.forEach(doc => {
                batch.update(doc.ref, {
                    teacherId: admin.firestore.FieldValue.delete(),
                    teacherAlias: admin.firestore.FieldValue.delete(),
                    isAutoDebitEnabled: admin.firestore.FieldValue.delete(),
                    lessonsBalance: admin.firestore.FieldValue.delete(),
                    totalLessonsPaid: admin.firestore.FieldValue.delete()
                })
            })
            await batch.commit()

            const teacherCollections = ['lessons', 'homeworks', 'payments', 'schedules', 'lessonOccurrences', 'teacherSettings']
            await Promise.all(
                teacherCollections.map(col => cascadeDeleteByTeacher(col, userId))
            )
        }

        if (role === 'student' && teacherId) {
            const collections = ['lessons', 'homeworks', 'payments', 'schedules', 'lessonOccurrences']
            await Promise.all(
                collections.map(col => cascadeDelete(col, userId, teacherId))
            )
        }

        await db.collection('users').doc(userId).delete()

        console.log(`Account ${userId} fully deleted`)
        return null
    })

async function cascadeDeleteByTeacher(collectionName, teacherId) {
    const snapshot = await db.collection(collectionName)
        .where('teacherId', '==', teacherId)
        .get()
    if (snapshot.empty) return
    const chunks = []
    for (let i = 0; i < snapshot.docs.length; i += 500) {
        chunks.push(snapshot.docs.slice(i, i + 500))
    }
    await Promise.all(chunks.map(chunk => {
        const batch = db.batch()
        chunk.forEach(doc => batch.delete(doc.ref))
        return batch.commit()
    }))
    console.log(`${collectionName}: deleted ${snapshot.size} docs for teacher ${teacherId}`)
}

// ─────────────────────────────────────────
// MARK: - Cascade Delete Helper
// ─────────────────────────────────────────
async function cascadeDelete(collectionName, studentId, teacherId) {
    const snapshot = await db.collection(collectionName)
        .where('studentId', '==', studentId)
        .where('teacherId', '==', teacherId)
        .get()

    if (snapshot.empty) {
        console.log(`${collectionName}: nothing to delete`)
        return
    }

    const chunks = []
    for (let i = 0; i < snapshot.docs.length; i += 500) {
        chunks.push(snapshot.docs.slice(i, i + 500))
    }

    await Promise.all(chunks.map(chunk => {
        const batch = db.batch()
        chunk.forEach(doc => batch.delete(doc.ref))
        return batch.commit()
    }))

    console.log(`${collectionName}: deleted ${snapshot.size} docs`)
}

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
    const offset = weekday === 1 ? 6 : weekday - 2
    date.setDate(weekStart.getDate() + offset)
    const [hours, minutes] = time.split(':').map(Number)
    date.setHours(hours, minutes, 0, 0)
    return date
}

function getNextDateForWeekday(from, weekday, time) {
    const date = new Date(from)
    const jsDay = weekday === 1 ? 0 : weekday - 1
    const currentDay = date.getDay()
    let diff = jsDay - currentDay
    const [hours, minutes] = time.split(':').map(Number)

    if (diff < 0) {
        diff += 7
    } else if (diff === 0) {
        const scheduledToday = new Date(date)
        scheduledToday.setHours(hours, minutes, 0, 0)
        if (scheduledToday <= from) {
            diff += 7
        }
    }

    date.setDate(date.getDate() + diff)
    date.setHours(hours, minutes, 0, 0)
    return date
}