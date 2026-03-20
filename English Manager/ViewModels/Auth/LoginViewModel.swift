//
//  LoginViewModel.swift
//  English Manager
//
//  Created by Sergej Klepikov on 06.03.2026.
//

import Foundation

protocol LoginViewModelProtocol {
    var onSuccess: (() -> Void)? { get set }
    var onError: ((String) -> Void)? { get set }
    var onLoading: ((Bool) -> Void)? { get set }
    func login(email: String, password: String)
    func register(email: String, password: String)
    func  resetPassword(email: String)
}

final class LoginViewModel: LoginViewModelProtocol {
    // MARK: - Callbacks
    var onSuccess: (() -> Void)?
    var onError: ((String) -> Void)?
    var onLoading: ((Bool) -> Void)?
    
    // MARK: - Properties
    private let authService: AuthServiceProtocol
    private let validator: ValidationServiceProtocol
    private let firestoreService: FirestoreServiceProtocol
    
    // MARK: - Init
    init(
        authService: AuthServiceProtocol = AuthService(),
        validator: ValidationServiceProtocol = ValidationService(),
        firestoreService: FirestoreServiceProtocol = FirestoreService()
    ) {
        self.authService = authService
        self.validator = validator
        self.firestoreService = firestoreService
    }
    
    // MARK: - Login
    func login(email: String, password: String) {
        if case .failure(let message) = validator.validateLoginForm(email: email, password: password) {
            onError?(message)
            return
        }
        performAuth {
            try await self.authService.signIn(email: email,
                                              password: password)
        }
    }
    
    // MARK: - Register
    func register(email: String, password: String) {
        if case .failure(let message) = validator.validateLoginForm(email: email, password: password) {
            onError?(message)
            return
        }
        performAuth {
            try await self.authService.signUp(email: email,
                                              password: password)
            guard let userId = self.authService.currentUserId else { return }
            let user = User(id: userId,
                            name: "",
                            surname: "",
                            email: email,
                            role: nil)
            try await self.firestoreService.saveUser(user)
        }
    }
    
    // MARK: - Reset Password
    func resetPassword(email: String) {
        if case .failure(let message) = validator.validateEmail(email) {
            onError?(message)
            return
        }
        performAuth {
            try await self.authService.resetPassword(email: email)
        }
    }
    
    // MARK: - Helper
    private func performAuth(_ action: @escaping () async throws -> Void) {
        onLoading?(true)
        Task {
            do {
                try await action()
                await MainActor.run { [ weak self ] in
                    self?.onLoading?(false)
                    self?.onSuccess?()
                }
            } catch {
                await MainActor.run { [ weak self ] in
                    self?.onLoading?(false)
                    self?.onError?(error.localizedDescription)
                }
            }
        }
    }
}
