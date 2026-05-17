//
//  ToastType.swift
//  English Manager
//
//  Created by Sergej Klepikov on 06.05.2026.
//

import Foundation

enum ToastType {
    case success(String)
    case error(String)
    case warning(String)
    
    var message: String {
        switch self {
        case .success(let m), .error(let m), .warning(let m):
            return m
        }
    }
    
    var icon: String {
        switch self {
        case .success:
            return "checkmark.circle.fill"
        case .error:
            return "xmark.circle.fill"
        case .warning:
            return "exclamationmark.triangle.fill"
        }
    }
}
