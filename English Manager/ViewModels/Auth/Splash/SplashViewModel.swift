//
//  SplashViewModel.swift
//  English Manager
//
//  Created by Sergej Klepikov on 10.05.2026.
//

import Foundation

protocol SplashViewModelProtocol: AnyObject {
    var onShowMain: ((UserRole) -> Void)? { get set }
    var onShowRole: (() -> Void)? { get set }
    var onShowLogin: (() -> Void)? { get set }
    func resolve()
}

final class SplashViewModel: SplashViewModelProtocol {
    // MARK: - Callbacks
    var onShowMain: ((UserRole) -> Void)?
    var onShowRole: (() -> Void)?
    var onShowLogin: (() -> Void)?
    
    // MARK: - Properties
    private let authService: AuthServiceProtocol
    private let firestoreService: FirestoreServiceProtocol

    // MARK: - Init
    init(
        authService: AuthServiceProtocol = AuthService(),
        firestoreService: FirestoreServiceProtocol = FirestoreService()
    ) {
        self.authService = authService
        self.firestoreService = firestoreService
    }
    
    // MARK: - Resolve
    func resolve() {
        guard authService.isLoggedIn,
              let userId = authService.currentUserId else {
            onShowLogin?()
            return
        }
        Task {
            let user = try? await firestoreService.fetchUser(id: userId)
            await MainActor.run { [weak self] in
                if let role = user?.role {
                    self?.onShowMain?(role)
                } else {
                    self?.onShowRole?()
                }
            }
        }
    }
}
