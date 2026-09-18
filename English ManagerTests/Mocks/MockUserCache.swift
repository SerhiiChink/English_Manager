//
//  MockUserCache.swift
//  English ManagerTests
//
//  Created by Sergej Klepikov on 15.09.2026.
//

import Foundation
@testable import English_Manager

final class MockUserCache: UserCacheProtocol {
    // MARK: - Properties
    var users: [String: User] = [:]
    var shouldReturnError = false
    
    // MARK: - Methods
    func getUser(
        id: String,
        service: FirestoreServiceProtocol,
        forceRefresh: Bool = false
    ) async throws -> User {
        if shouldReturnError {
            throw NSError(domain: "MockUserCacheError", code: -1)
        }
        if let cachedUser = users[id], !forceRefresh {
            return cachedUser
        }
        let fetchedUser = try await service.fetchUser(id: id)
        users[id] = fetchedUser
        return fetchedUser
    }

    func save(_ user: User) {
        users[user.id] = user
    }

    func invalidate(userId: String) {
        users[userId] = nil
    }
}
