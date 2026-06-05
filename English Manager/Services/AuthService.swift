//
//  AuthService.swift
//  English Manager
//
//  Created by Sergej Klepikov on 05.03.2026.
//

import Foundation
import FirebaseAuth
import FirebaseStorage
import GoogleSignIn

protocol AuthServiceProtocol {
    var isLoggedIn: Bool { get }
    var currentUserId: String? { get }
    var isGoogleUser: Bool { get }
    func signIn(email: String, password: String) async throws
    func signUp(email: String, password: String) async throws
    func signOut() throws
    func resetPassword(email: String) async throws
    func changePassword(_ password: String) async throws
    func deleteAccount(email: String, password: String) async throws
    func signInWithGoogle(presenting: UIViewController) async throws
    func deleteAccountWithGoogle(presenting: UIViewController) async throws
}

final class AuthService: AuthServiceProtocol {
    // MARK: - Properties
    private let firestoreService: FirestoreServiceProtocol
    var isLoggedIn: Bool {
        Auth.auth().currentUser != nil
    }
    
    var currentUserId: String? {
        Auth.auth().currentUser?.uid
    }
    
    var isGoogleUser: Bool {
        Auth.auth().currentUser?.providerData
            .contains { $0.providerID == "google.com" } ?? false
    }
    
    // MARK: - Init
    init(firestoreService: FirestoreServiceProtocol = FirestoreService()) {
        self.firestoreService = firestoreService
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
    
    // MARK: - Google Sign In
    func signInWithGoogle(presenting: UIViewController) async throws {
        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: presenting)
        let user = result.user
        guard let idToken = user.idToken?.tokenString else {
            throw NSError(
                domain: "GoogleSignIn",
                code: -1, userInfo: [NSLocalizedDescriptionKey: "Missing ID token"]
            )
        }
        let credential = GoogleAuthProvider.credential(
            withIDToken: idToken,
            accessToken: user.accessToken.tokenString
        )
        let authResult = try await Auth.auth().signIn(with: credential)
        let firebaseUser = authResult.user
        if let existingUser = try? await firestoreService
            .fetchUser(id: firebaseUser.uid) {
            _ = existingUser
        } else {
            let profile = result.user.profile
            let newUser = User(
                id: firebaseUser.uid,
                name: profile?.givenName ?? "",
                surname: profile?.familyName ?? "",
                email: profile?.email ?? firebaseUser.email ?? "",
                role: nil
            )
            try await firestoreService.saveUser(newUser)
        }
    }
    
    func deleteAccountWithGoogle(presenting: UIViewController) async throws {
        guard let user = Auth.auth().currentUser else { return }
        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: presenting)
        guard let idToken = result.user.idToken?.tokenString else { return }
        let credential = GoogleAuthProvider.credential(
            withIDToken: idToken,
            accessToken: result.user.accessToken.tokenString
            )
        try await user.reauthenticate(with: credential)
        let avatarRef = Storage.storage().reference()
            .child("avatars").child(user.uid).child("avatar.jpg")
        try? await avatarRef.delete()
        try await user.delete()
    }
}
