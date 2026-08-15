//
//  MockAuthService.swift
//  English ManagerTests
//
//  Created by Sergej Klepikov on 12.08.2026.
//

import UIKit
import AuthenticationServices
@testable import English_Manager

final class MockAuthService: AuthServiceProtocol {
    // MARK: - Properties
    var isLoggedIn: Bool = false
    var currentUserId: String? = "mock_user_id"
    var isGoogleUser: Bool = false
    var isAppleUser: Bool = false
    
    // MARK: - Error Simulation
    var shouldReturnError = false
    var customError: Error = NSError(
        domain: "AuthError",
        code: -1,
        userInfo: [NSLocalizedDescriptionKey: "Mock Auth Error"]
    )
    
    // MARK: - Call Trackers
    private(set) var signInCalledWith: (email: String, password: String)?
    private(set) var signUpCalledWith: (email: String, password: String)?
    private(set) var signOutCalled = false
    private(set) var resetPasswordCalledWithEmail: String?
    private(set) var changePasswordCalledWith: String?
    private(set) var deleteAccountCalled = false
    private(set) var signInWithGoogleCalled = false
    private(set) var signInWithAppleCalled = false
    private(set) var deleteAccountWithGoogleCalled = false
    private(set) var deleteAccountWithAppleCalled = false
    private func checkError() throws {
        if shouldReturnError {
            throw customError
        }
    }
    
    // MARK: - Methods
    func signIn(email: String, password: String) async throws {
        try checkError()
        signInCalledWith = (email, password)
        isLoggedIn = true
        currentUserId = "mock_user_id"
    }
    
    func signUp(email: String, password: String) async throws {
        try checkError()
        signUpCalledWith = (email, password)
        isLoggedIn = true
        currentUserId = "mock_user_id"
    }
    
    func signOut() throws {
        try checkError()
        signOutCalled = true
        isLoggedIn = false
        currentUserId = nil
    }
    
    func resetPassword(email: String) async throws {
        try checkError()
        resetPasswordCalledWithEmail = email
    }
    
    func changePassword(_ password: String) async throws {
        try checkError()
        changePasswordCalledWith = password
    }
    
    func deleteAccount(email: String, password: String) async throws {
        try checkError()
        deleteAccountCalled = true
        isLoggedIn = false
        currentUserId = nil
    }
    
    func signInWithGoogle(presenting: UIViewController) async throws {
        try checkError()
        signInWithGoogleCalled = true
        isLoggedIn = true
        isGoogleUser = true
        currentUserId = "mock_user_id"
    }
    
    func signInWithApple(window: ASPresentationAnchor) async throws {
        try checkError()
        signInWithAppleCalled = true
        isLoggedIn = true
        isAppleUser = true
        currentUserId = "mock_user_id"
    }
    
    func deleteAccountWithGoogle(presenting: UIViewController) async throws {
        try checkError()
        deleteAccountWithGoogleCalled = true
        isLoggedIn = false
        currentUserId = nil
    }
    
    func deleteAccountWithApple(window: ASPresentationAnchor) async throws {
        try checkError()
        deleteAccountWithAppleCalled = true
        isLoggedIn = false
        currentUserId = nil
    }
}
