//
//  AuthService.swift
//  English Manager
//
//  Created by Sergej Klepikov on 05.03.2026.
//

import Foundation
import FirebaseAuth

protocol AuthServiceProtocol {
    var isLoggedIn: Bool { get }
    var currentUserId: String? { get }
    func signIn(email: String, password: String) async throws
    func signUp(email: String, password: String) async throws
    func signOut() throws
    func resetPassword(email: String) async throws
}

final class AuthService: AuthServiceProtocol {
    // MARK: - Properties
    var isLoggedIn: Bool {
        Auth.auth().currentUser != nil
    }
    
    var currentUserId: String? {
        Auth.auth().currentUser?.uid
    }
    
    // MARK: - Sign In
    func signIn(email: String, password: String) async throws {
        try await Auth.auth().signIn(withEmail: email,
                                     password: password)
    }
    
    // MARK: - Sign Up
    func signUp(email: String, password: String) async throws {
        try await Auth.auth().createUser(withEmail: email,
                                         password: password)
    }
    
    // MARK: - Sign Out
    func signOut() throws {
        try Auth.auth().signOut()
    }
    
    func resetPassword(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
}
