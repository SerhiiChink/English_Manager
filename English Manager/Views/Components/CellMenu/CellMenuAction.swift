//
//  CellMenuAction.swift
//  English Manager
//
//  Created by Sergej Klepikov on 19.04.2026.
//

import Foundation

struct CellMenuAction {
    let title: String
    let icon: String
    let isDestructive: Bool
    let handle: () -> Void
    
    static func edit(_ handler: @escaping () -> Void) -> CellMenuAction {
        CellMenuAction(title: "edit".localized,
                       icon: "pencil",
                       isDestructive: false,
                       handle: handler)
    }
    
    static func delete(_ handler: @escaping () -> Void) -> CellMenuAction {
        CellMenuAction(title: "delete".localized,
                       icon: "trash",
                       isDestructive: true,
                       handle: handler)
    }
    
    static func remove(_ handler: @escaping () -> Void) -> CellMenuAction {
        CellMenuAction(title: "remove_student".localized,
                       icon: "person.badge.minus",
                       isDestructive: true,
                       handle: handler)
    }
}

