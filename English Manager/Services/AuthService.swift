//
//  AuthService.swift
//  English Manager
//
//  Created by Sergej Klepikov on 05.03.2026.
//

import Foundation
import FirebaseAuth
import FirebaseStorage

protocol AuthServiceProtocol {
    var isLoggedIn: Bool { get }
    var currentUserId: String? { get }
    func signIn(email: String, password: String) async throws
    func signUp(email: String, password: String) async throws
    func signOut() throws
    func resetPassword(email: String) async throws
    func changePassword(_ password: String) async throws
    func deleteAccount(email: String, password: String) async throws
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
    
    // MARK: - Change Password
    func changePassword(_ password: String) async throws {
        try await Auth.auth().currentUser?.updatePassword(to: password)
    }
    
    // MARK: - Delete Account
    func deleteAccount(email: String, password: String) async throws {
        guard let user = Auth.auth().currentUser else { return }
        let credential = EmailAuthProvider.credential(withEmail: email,
                                                      password: password)
        try await user.reauthenticate(with: credential)
        let avatarRef = Storage.storage().reference()
            .child("avatars")
            .child(user.uid)
            .child("avatar.jpg")
        try? await avatarRef.delete()
        try await user .delete()
    }
}
