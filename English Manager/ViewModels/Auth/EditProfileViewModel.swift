//
//  EditProfileViewModel.swift
//  English Manager
//
//  Created by Sergej Klepikov on 19.03.2026.
//

import Foundation
import UIKit

protocol EditProfileViewModelProtocol: AnyObject {
    var onSuccess: (() -> Void)? { get set }
    var onError: ((String) -> Void)? { get set }
    var onLoading: ((Bool) -> Void)? { get set }
    var user: User { get }
    func save(name: String, surname: String)
    func uploadAvatar(_ image: UIImage)
}

final class EditProfileViewModel: EditProfileViewModelProtocol {
    // MARK: - Callbacks
    var onSuccess: (() -> Void)?
    var onError: ((String) -> Void)?
    var onLoading: ((Bool) -> Void)?
    
    // MARK: - Data
    private(set) var user: User
    
    // MARK: - Properties
    private let firestoreService: FirestoreServiceProtocol
    private let storageService: StorageServiceProtocol
    
    // MARK: - Properties
    init(
        user: User,
        firestoreService: FirestoreServiceProtocol = FirestoreService(),
        storageService: StorageServiceProtocol = StorageService()
    ) {
        self.user = user
        self.firestoreService = firestoreService
        self.storageService = storageService
    }
    
    // MARK: - Save
    func save(name: String, surname: String) {
        guard !name.isEmpty else {
            onError?("Name is empty")
            return
        }
        onLoading?(true)
        var updatedUser = user
        updatedUser.name = name
        updatedUser.surname = surname
        Task {
            do {
                try await firestoreService.saveUser(updatedUser)
                await MainActor.run { [weak self] in
                    self?.onLoading?(false)
                    self?.onSuccess?()
                }
            } catch {
                await MainActor.run { [weak self] in
                    self?.onLoading?(false)
                    self?.onError?(error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: - Up Load Avatar
    func uploadAvatar(_ image: UIImage) {
        onLoading?(true)
        Task {
            do {
                let url = try await storageService.uploadAvatar(userId: user.id,
                                                                image: image)
                try await firestoreService.updateUserAvatar(userId: user.id,
                                                            url: url)
                await MainActor.run { [weak self] in
                    self?.user.photoURL = url
                    self?.onLoading?(false)
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
