//
//  ValidationService.swift
//  English Manager
//
//  Created by Sergej Klepikov on 06.03.2026.
//

import Foundation

protocol ValidationServiceProtocol {
    func validateEmail(_ email: String) -> ValidationResult
    func validatePassword(_ password: String) -> ValidationResult
    func validateLoginForm(email: String,
                           password: String) -> ValidationResult
}

final class ValidationService: ValidationServiceProtocol {
    func validateEmail(_ email: String) -> ValidationResult {
        guard !email.isEmpty else {
            return .failure("validation_email_empty".localized)
        }
        guard isValidEmail(email) else {
            return .failure("validation_email_invalid".localized)
        }
        return .success
    }
    
    func validatePassword(_ password: String) -> ValidationResult {
        guard !password.isEmpty else {
            return .failure("validation_password_empty".localized)
        }
        guard password.count >= 8 else {
            return .failure("validation_password_too_short".localized)
        }
        guard password.range(of: "[A-Z]",
                             options: .regularExpression) != nil else {
            return .failure("validation_password_no_uppercase".localized)
        }
        guard password.rangeOfCharacter(from: .decimalDigits) != nil else {
            return .failure("validation_password_no_digit".localized)
        }
        return .success
    }
    
    func validateLoginForm(email: String,
                           password: String) -> ValidationResult {
        let emailResult = validateEmail(email)
        guard case .success = emailResult else {
            return emailResult
        }
        let passwordResult = validatePassword(password)
        guard case .success = passwordResult else {
            return passwordResult
        }
        return .success
    }
    
    // MARK: - Private
    private func isValidEmail(_ email: String) -> Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let predicate = NSPredicate(format:"SELF MATCHES %@", regex)
        return predicate.evaluate(with: email)
    }
}
