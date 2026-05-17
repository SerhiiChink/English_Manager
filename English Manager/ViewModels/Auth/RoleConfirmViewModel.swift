//
//  RoleConfirmViewModel.swift
//  English Manager
//
//  Created by Sergej Klepikov on 10.05.2026.
//

import Foundation

protocol RoleConfirmViewModelProtocol: AnyObject {
    var role: UserRole { get }
    var roleStyle: RoleStyle { get }
    var onSuccess: ((UserRole) -> Void)? { get set }
    var onError: ((String) -> Void)? { get set }
    var onLoading: ((Bool) -> Void)? { get set }
    func confirm()
}

final class RoleConfirmViewModel: RoleConfirmViewModelProtocol {
    // MARK: - Callbacks
    var onSuccess: ((UserRole) -> Void)?
    var onError: ((String) -> Void)?
    var onLoading: ((Bool) -> Void)?
    
    // MARK: - Data
    let role: UserRole
    
    // MARK: - Computed
    var roleStyle: RoleStyle {
        RoleMapper.style(for: role)
    }
    
    // MARK: - Properties
    private let firestoreService: FirestoreServiceProtocol
    private let authService: AuthServiceProtocol
    
    // MARK: - Init
    init(
        role: UserRole,
        firestoreService: FirestoreServiceProtocol = FirestoreService(),
        authService: AuthServiceProtocol = AuthService()
    ) {
        self.role = role
        self.firestoreService = firestoreService
        self.authService = authService
    }
    
    // MARK: - Confirm
    func confirm() {
        guard let userId = authService.currentUserId else {
            onError?("User not found")
            return
        }
        onLoading?(true)
        Task {
            do {
                try await firestoreService.updateUserRole(userId: userId,
                                                          role: role)
                UserDefaults.standard.set(role.rawValue,
                                          forKey: UDKeys.userRole)
                await MainActor.run { [weak self] in
                    guard let self else { return }
                    onLoading?(false)
                    onSuccess?(role)
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
