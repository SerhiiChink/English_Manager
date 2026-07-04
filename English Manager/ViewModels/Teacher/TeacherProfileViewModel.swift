//
//  TeacherProfileViewModel.swift
//  English Manager
//
//  Created by Sergej Klepikov on 18.03.2026.
//

import Foundation
import GoogleSignIn
import AuthenticationServices

protocol TeacherProfileViewModelProtocol: AnyObject {
    var onUpdate: (() -> Void)? { get set }
    var onError: ((String) -> Void)? { get set }
    var onLoading: ((Bool) -> Void)? { get set }
    var onAccountDeleted: (() -> Void)? { get set }
    var user: User? { get }
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

final class TeacherProfileViewModel: TeacherProfileViewModelProtocol {
    // MARK: - Callbacks
    var onUpdate: (() -> Void)?
    var onError: ((String) -> Void)?
    var onLoading: ((Bool) -> Void)?
    var onAccountDeleted: (() -> Void)?
    
    // MARK: - Data
    private(set) var user: User?
    private var studentsCount: Int = 0
    private var lessonsCount: Int = 0
    var statItems: [StatItem] {
        [
            StatItem(title: "students".localized,
                     value: "\(studentsCount)"),
            StatItem(title: "lessons_capitalized".localized,
                     value: "\(lessonsCount)"),
        ]
    }
    
    var isGoogleUser: Bool { authService.isGoogleUser }
    var isAppleUser: Bool { authService.isAppleUser }
    
    // MARK: - Properties
    private let firestoreService: FirestoreServiceProtocol
    private let authService: AuthServiceProtocol
    private var isFetching = false
    
    // MARK: - Init
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
                async let students = firestoreService
                    .fetchStudents(teacherId: userId)
                async let lessons = firestoreService
                    .fetchLessons(teacherId: userId)
                let fetchedStudents = (try? await students) ?? []
                let fetchedLessons = (try? await lessons) ?? []
                await MainActor.run { [weak self] in
                    self?.user = fetchedUser
                    self?.studentsCount = fetchedStudents.count
                    self?.lessonsCount = fetchedLessons.count
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
