//
//  MockValidationService.swift
//  English ManagerTests
//
//  Created by Sergej Klepikov on 15.08.2026.
//

import Foundation
@testable import English_Manager

final class MockValidationService: ValidationServiceProtocol {
    // MARK: - Properties
    var validationResultToReturn: ValidationResult = .success
    
    // MARK: - Call Trackers
    private(set) var validateEmailCalledWith: String?
    private(set) var validatePasswordCalledWith: String?
    private(set) var validateLoginFormCalledWith: (email: String, password: String)?
        
    // MARK: - Methods
    func validateEmail(_ email: String) -> ValidationResult {
        validateEmailCalledWith = email
        return validationResultToReturn
    }

    func validatePassword(_ password: String) -> ValidationResult {
        validatePasswordCalledWith = password
        return validationResultToReturn
    }

    func validateLoginForm(email: String, password: String) -> ValidationResult {
        validateLoginFormCalledWith = (email, password)
        return validationResultToReturn
    }
}
