//
//  MockStorageService.swift
//  English ManagerTests
//
//  Created by Sergej Klepikov on 12.08.2026.
//

import Foundation
@testable import English_Manager

final class MockStorageService: StorageServiceProtocol {
    // MARK: - Properties
    var mockedAvatarURL = "https://example.com/avatars/mock_avatar.jpg"
    
    // MARK: - Error Simulation
    var shouldReturnError = false
    var customError: Error = NSError(
        domain: "StorageServiceError",
        code: -1,
        userInfo: [NSLocalizedDescriptionKey: "Mock Storage Upload Error"]
    )
    
    // MARK: - Call Trackers
    private(set) var uploadAvatarCalledWith: (userId: String, imageData: Data)?
    
    // MARK: - Methods
    func uploadAvatar(userId: String, imageData: Data) async throws -> String {
        if shouldReturnError {
            throw customError
        }
        uploadAvatarCalledWith = (userId, imageData)
        return mockedAvatarURL
    }
}
