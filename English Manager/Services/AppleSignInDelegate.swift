//
//  AppleSignInDelegate.swift
//  English Manager
//
//  Created by Sergej Klepikov on 22.06.2026.
//

import AuthenticationServices
import FirebaseAuth

final class AppleSignInDelegate: NSObject,
                                 ASAuthorizationControllerDelegate,
                                 ASAuthorizationControllerPresentationContextProviding {
    // MARK: - Properties
    private let nonce: String
    private let firestoreService: FirestoreServiceProtocol
    private let window: ASPresentationAnchor
    private let completion: (Result<Void, Error>) -> Void
    
    // MARK: - Init
    init(
        nonce: String,
        firestoreService: FirestoreServiceProtocol,
        window: ASPresentationAnchor,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        self.nonce = nonce
        self.window = window
        self.firestoreService = firestoreService
        self.completion = completion
    }
    
    // MARK: - ASAuthorizationControllerPresentationContextProviding
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        window
    }
    
    // MARK: - ASAuthorizationControllerDelegate
    func authorizationController(controller: ASAuthorizationController,
                                 didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let tokenData = credential.identityToken,
              let tokenString = String(data: tokenData, encoding: .utf8) else {
            completion(.failure(NSError(domain: "AppleSignIn", code: -1)))
            return
        }
        let firebaseCredential = OAuthProvider.appleCredential(
            withIDToken: tokenString,
            rawNonce: nonce,
            fullName: credential.fullName
        )
        Task {
            do {
                let authResult = try await Auth.auth()
                    .signIn(with: firebaseCredential)
                let fireballUser = authResult.user
                if (try? await firestoreService
                    .fetchUser(id: fireballUser.uid)) == nil {
                    let user = User(
                        id: fireballUser.uid,
                        name: credential.fullName?.givenName ?? "",
                        surname: credential.fullName?.familyName ?? "",
                        email: credential.email ?? fireballUser.email ?? "",
                        role: nil
                    )
                    try await firestoreService.saveUser(user)
                }
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController,
                                 didCompleteWithError error: Error) {
        completion(.failure(error))
    }
}
