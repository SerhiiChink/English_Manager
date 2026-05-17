//
//  UserCache.swift
//  English Manager
//
//  Created by Sergej Klepikov on 22.04.2026.
//

import Foundation

final class UserCache {
    static let shared = UserCache()
    private init() {}
    
    // MARK: - Keys
    private enum Keys {
        static func user(id: String) -> String { "cached_user_\(id)" }
        static func timestamp(id: String) -> String {
            "cached_user_timestamp_\(id)"
        }
        
    }
    
    // MARK: - Properties
    private let ttl: TimeInterval = 5 * 60
    private var memoryCache: User?
    private var loadingTask: Task<User, Error>?
    
    // MARK: - Get
    func getUser(id: String,
                 service: FirestoreServiceProtocol,
                 forceRefresh: Bool = false) async throws -> User {
        if !forceRefresh {
            if let memory = memoryCache, memory.id == id { return memory }
            if let cached = cachedUser(for: id) { return cached }
        }
        if let task = loadingTask {
            return try await task.value
        }
        let task = Task<User, Error> {
            let user = try await service.fetchUser(id: id)
            self.save(user)
            return user
        }
        loadingTask = task
        defer { loadingTask = nil }
        return try await task.value
    }
    
    // MARK: - Save
    func save(_ user: User) {
        memoryCache = user
        guard let data = try? JSONEncoder().encode(user) else { return }
        UserDefaults.standard.set(data, forKey: Keys.user(id: user.id))
        UserDefaults.standard.set(Date(), forKey: Keys.timestamp(id: user.id))
    }
    
    // MARK: - Invalidate
    func invalidate(userId: String) {
        memoryCache = nil
        loadingTask = nil
        UserDefaults.standard.removeObject(forKey: Keys.user(id: userId))
        UserDefaults.standard.removeObject(forKey: Keys.timestamp(id: userId))
    }
    
    // MARK: - Private
    private func cachedUser(for id: String) -> User? {
        guard
            let timeStamp = UserDefaults.standard.object(
                forKey: Keys.timestamp(id: id)
            ) as? Date, Date().timeIntervalSince(timeStamp) < ttl,
            let data = UserDefaults.standard.data(
                forKey: Keys.user(id: id)),
            let user = try? JSONDecoder().decode(User.self, from: data)
        else { return nil }
        memoryCache = user
        return user
    }
}
