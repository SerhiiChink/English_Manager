//
//  QuerySnapshot+Decode.swift
//  English Manager
//
//  Created by Sergej Klepikov on 14.03.2026.
//

import FirebaseFirestore

extension QuerySnapshot {
    func decode<T: Decodable>(_ type: T.Type) throws -> [T] {
        try documents.map { try $0.data(as: T.self) }
    }
}
