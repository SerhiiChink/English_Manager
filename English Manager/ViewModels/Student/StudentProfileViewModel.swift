//
//  StudentProfileViewModel.swift
//  English Manager
//
//  Created by Sergej Klepikov on 21.03.2026.
//

import Foundation
import GoogleSignIn
import AuthenticationServices

protocol StudentProfileViewModelProtocol: AnyObject {
    var onUpdate: (() -> Void)? { get set }
    var onError: ((String) -> Void)? { get set }
    var onLoading: ((Bool) -> Void)? { get set }
    var onAccountDeleted: (() -> Void)? { get set }
    var user: User? { get }
    var teacher: User? { get }
    var statItems: [StatItem] { get }
    var isGoogleUser: Bool { get }
    var isAppleUser: Bool { get }
    func fetchProfile()
    func refresh()
    func signOut()
    func changePassword(_ password: String)
    func deleteAccount(email: String, password: String)
    func deleteAccountWithGoogle(presenting: UIViewController)
    func deleteAccountWithApple(window: ASPresentationAnchor)
}

final class StudentProfileViewModel: StudentProfileViewModelProtocol {
    // MARK: - Callbacks
    var onUpdate: (() -> Void)?
    var onError: ((String) -> Void)?
    var onLoading: ((Bool) -> Void)?
    var onAccountDeleted: (() -> Void)?
    
    // MARK: - Data
    private(set) var user: User?
    private(set) var teacher: User?
    private var lessonsCount: Int = 0
    private var homeworkCount: Int = 0
    var statItems: [StatItem] {
        [
            StatItem(title: "lessons_capitalized".localized,
                     value: "\(lessonsCount)"),
            StatItem(title: "homework".localized,
                     value: "\(homeworkCount)")
        ]
    }
    
    var isGoogleUser: Bool { authService.isGoogleUser }
    var isAppleUser: Bool { authService.isAppleUser }
    
    // MARK: - Properties
    private let firestoreService: FirestoreServiceProtocol
    private let authService: AuthServiceProtocol
    private var isFetching = false
    
    init(
        firestoreService: FirestoreServiceProtocol = FirestoreService(),
        authService: AuthServiceProtocol = AuthService()
    ) {
        self.firestoreService = firestoreService
        self.authService = authService
    }
    
    // MARK: - Fetch
    func fetchProfile() {
        performFetch(forceRefresh: false)
    }

    func refresh() {
        performFetch(forceRefresh: true)
    }
    
    private func performFetch(forceRefresh: Bool) {
        guard !isFetching else { return }
        guard let userId = authService.currentUserId else {
            onError?("User not found")
            return
        }
        isFetching = true
        onLoading?(true)
        Task {
            do {
                let fetchedUser = try await UserCache.shared.getUser(
                    id: userId,
                    service: firestoreService,
                    forceRefresh: forceRefresh
                )
                let fetchedTeacher: User?
                if let teacherId = fetchedUser.teacherId {
                    fetchedTeacher = try? await UserCache.shared.getUser(
                        id: teacherId,
                        service: firestoreService,
                        forceRefresh: forceRefresh
                    )
                } else {
                    fetchedTeacher = nil
                }
                async let lessons = firestoreService
                    .fetchStudentLessons(studentId: userId)
                async let homeworks = firestoreService
                    .fetchStudentHomeworks(studentId: userId)
                let (fetchedLessons,
                     fetchedHomeworks) = try await (lessons, homeworks)
                await MainActor.run { [weak self] in
                    self?.user = fetchedUser
                    self?.teacher = fetchedTeacher
                    self?.lessonsCount = fetchedLessons.count
                    self?.homeworkCount = fetchedHomeworks.count
                    self?.isFetching = false
                    self?.onLoading?(false)
                    self?.onUpdate?()
                }
            } catch {
                await MainActor.run { [weak self] in
                    self?.isFetching = false
                    self?.onLoading?(false)
                    self?.onError?(error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: - Sign Out
    func signOut() {
        do {
            try authService.signOut()
            UserDefaults.standard.removeObject(forKey: UDKeys.userRole)
            UserDefaults.standard.removeObject(forKey: UDKeys.userId)
        } catch {
            onError?(error.localizedDescription)
        }
    }
    
    // MARK: - Change Password
    func changePassword(_ password: String) {
        onLoading?(true)
        Task {
            do {
                try await authService.changePassword(password)
                await MainActor.run { [weak self] in
                    self?.onLoading?(false)
                    self?.onUpdate?()
                }
            } catch {
                await MainActor.run { [weak self] in
                    self?.onLoading?(false)
                    self?.onError?(error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: - Delete Account
    func deleteAccount(email: String, password: String) {
        onLoading?(true)
        Task {
            do {
                try await authService.deleteAccount(email: email,
                                                    password: password)
                UserDefaults.standard.removeObject(forKey: UDKeys.userRole)
                UserDefaults.standard.removeObject(forKey: UDKeys.userId)
                await MainActor.run { [weak self] in
                    self?.onLoading?(false)
                    self?.onAccountDeleted?()
                }
            } catch {
                await MainActor.run { [weak self] in
                    self?.onLoading?(false)
                    self?.onError?(error.localizedDescription)
                }
            }
        }
    }
    
    func deleteAccountWithGoogle(presenting: UIViewController) {
        onLoading?(true)
        Task {
            do {
                try await authService
                    .deleteAccountWithGoogle(presenting: presenting)
                UserDefaults.standard.removeObject(forKey: UDKeys.userRole)
                UserDefaults.standard.removeObject(forKey: UDKeys.userId)
                await MainActor.run { [weak self] in
                    self?.onLoading?(false)
                    self?.onAccountDeleted?()
                }
            } catch {
                await MainActor.run { [weak self] in
                    self?.onLoading?(false)
                    self?.onError?(error.localizedDescription)
                }
            }
        }
    }
    
    func deleteAccountWithApple(window: ASPresentationAnchor) {
        onLoading?(true)
        Task {
            do {
                try await authService.deleteAccountWithApple(window: window)
                UserDefaults.standard.removeObject(forKey: UDKeys.userRole)
                UserDefaults.standard.removeObject(forKey: UDKeys.userId)
                await MainActor.run { [weak self] in
                    self?.onLoading?(false)
                    self?.onAccountDeleted?()
                }
            } catch {
                await MainActor.run { [weak self] in
                    self?.onLoading?(false)
                    if (error as NSError).code == ASAuthorizationError.canceled.rawValue { return }
                    self?.onError?(error.localizedDescription)
                }
            }
        }
    }
}
