//
//  StudentProfileViewModel.swift
//  English Manager
//
//  Created by Sergej Klepikov on 21.03.2026.
//

import UIKit
import SnapKit

protocol StudentProfileViewModelProtocol: AnyObject {
    var onUpdate: (() -> Void)? { get set }
    var onError: ((String) -> Void)? { get set }
    var onLoading: ((Bool) -> Void)? { get set }
    var user: User? { get }
    func fetchProfile()
    func signOut()
    func changePassword(_ password: String)
}

final class StudentProfileViewModel: StudentProfileViewModelProtocol {
    // MARK: - Callbacks
    var onUpdate: (() -> Void)?
    var onError: ((String) -> Void)?
    var onLoading: ((Bool) -> Void)?
    
    // MARK: - Data
    private(set) var user: User?
    
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
        guard !isFetching else { return }
        guard let userId = authService.currentUserId else {
            onError?("User not found")
            return
        }
        isFetching = true
        onLoading?(true)
        Task {
            do {
                let fetchedUser = try await firestoreService
                    .fetchUser(id: userId)
                await MainActor.run { [weak self] in
                    self?.user = fetchedUser
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
}
