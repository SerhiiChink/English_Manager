//
//  RoleViewModel.swift
//  English Manager
//
//  Created by Sergej Klepikov on 15.03.2026.
//

import Foundation

protocol RoleViewModelProtocol: AnyObject {
    func updateUserRole(_ role: UserRole)
}

final class RoleViewModel: RoleViewModelProtocol {
    // MARK: - Properties
    private let firestoreService: FirestoreServiceProtocol
    private let authService: AuthServiceProtocol
    
    // MARK: - Init
    init(
        firestoreService: FirestoreServiceProtocol = FirestoreService(),
        authService: AuthServiceProtocol = AuthService()
    ) {
        self.firestoreService = firestoreService
        self.authService = authService
    }
    
    // MARK: - Up date role
    func updateUserRole(_ role: UserRole) {
        guard let userId = authService.currentUserId else { return }
        Task {
            try? await firestoreService.updateUserRole(userId: userId,
                                                       role: role)
        }
    }
}

