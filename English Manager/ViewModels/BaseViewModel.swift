//
//  BaseViewModel.swift
//  English Manager
//
//  Created by Sergej Klepikov on 16.03.2026.
//

import UIKit

protocol BaseViewModelProtocol: AnyObject {
    var onError: ((String) -> Void)? { get set }
    var onLoading: ((Bool) -> Void)? { get set } 
}

class BaseViewModel: BaseViewModelProtocol {
    var onError: ((String) -> Void)?
    var onLoading: ((Bool) -> Void)?
    
    func perform(_ action: @escaping () async throws -> Void) {
        onLoading?(true)
        Task {
            do {
                try await action()
                await MainActor.run { [weak self] in
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
