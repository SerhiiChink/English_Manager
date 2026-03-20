//
//  StorageService.swift
//  English Manager
//
//  Created by Sergej Klepikov on 20.03.2026.
//

import Foundation
import FirebaseStorage
import UIKit

protocol StorageServiceProtocol {
    func uploadAvatar(userId: String,
                      image: UIImage) async throws -> String
}

final class StorageService: StorageServiceProtocol {
    // MARK: - Properties
    private let storage = Storage.storage().reference()
    
    // MARK: - Up Load Avatar
    func uploadAvatar(userId: String,
                      image: UIImage) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            throw NSError(
                domain: "StorageService",
                code: 0,
                userInfo: [NSLocalizedDescriptionKey: "Failed to convert image"]
            )
        }
        let ref = storage.child("avatars").child("\(userId).jpg")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        _ = try await ref.putDataAsync(imageData, metadata: metadata)
        let url = try await ref.downloadURL()
        return url.absoluteString
    }
}
