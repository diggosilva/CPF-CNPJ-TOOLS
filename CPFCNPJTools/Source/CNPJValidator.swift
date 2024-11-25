//
//  CNPJValidator.swift
//  CPFCNPJTools
//
//  Created by Diggo Silva on 19/11/24.
//

import Foundation

public enum CNPJStatus {
    case cnpjNull      // CNPJ cannot be null or empty.
    case invalidFormat // Invalid CNPJ.\nCNPJ must have 14 digits (only numbers).
    case equalDigits   // CNPJ with repeated digits is not valid (e.g., 11.111.111/0001-11, which is invalid because it's a repeated number).
    case valid         // Valid CNPJ.
    case invalid       // Invalid CNPJ.
}

/// The `CNPJValidator` class is responsible for validating, generating, and formatting CNPJ numbers (Brazilian National Registry of Legal Entities).
///
/// It provides methods to validate a CNPJ, generate fake CNPJs, format a CNPJ into a readable format, and apply a mask to the CNPJ.
public class CNPJValidator {
    /// Initializes a new CNPJValidator.
    public init() {}
    
    /// Validates a provided CNPJ, checking its format and verifying if the check digits are correct.
    ///
    /// - Parameter cnpj: The CNPJ to be validated.
    /// - Returns: A `CNPJStatus` value indicating the result of the validation.
    ///
    /// **Usage example:**
    /// ```swift
    /// let validator = CNPJValidator()
    /// let result = validator.validate(cnpj: "11444777000135")
    /// print(result) // .valid or .invalid
    /// ```
    public func validate(cnpj: String) -> CNPJStatus {
        // Clears the CPF, removing non-numeric characters
        let clearedCNPJ = cnpj.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        
        guard clearedCNPJ.count > 0 else { return .cnpjNull }
        
        // Checks if the CPF has 14 digits
        guard clearedCNPJ.count == 14, clearedCNPJ.allSatisfy({ $0.isNumber }) else { return .invalidFormat }
        
        // Checks if all digits are the same
        if Set(clearedCNPJ).count == 1 { return .equalDigits }
        
        // Divides the CNPJ into the first 12 digits and the last 2 (verification digits)
        let cnpjBaseDigits = clearedCNPJ.prefix(12).compactMap({ Int(String($0)) })
        let providedCheckDigits = clearedCNPJ.suffix(2).compactMap({ Int(String($0)) })
        
        let multiplyFirstBy = [5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2]
        let multiplySecondBy = [6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2]
        
        // Calculates the first verification digit
        let calculated1stCheckDigit = Double(calculatedCNPJCheckSum(cnpj12Digits: cnpjBaseDigits, multiplyBy: multiplyFirstBy)).truncatingRemainder(dividingBy: 11)
        let firstCheckDigit = calculated1stCheckDigit < 2 ? 0 : 11 - Int(calculated1stCheckDigit)
        
        // Calculates the second verification digit
        let calculated2ndCheckDigit = Double(calculatedCNPJCheckSum(cnpj12Digits: cnpjBaseDigits + [firstCheckDigit], multiplyBy: multiplySecondBy)).truncatingRemainder(dividingBy: 11)
        let secondCheckDigit = calculated2ndCheckDigit < 2 ? 0 : 11 - Int(calculated2ndCheckDigit)
        
        // Compares the calculated verification digits with the provided ones
        if firstCheckDigit == providedCheckDigits.first, secondCheckDigit == providedCheckDigits.last {
            return .valid
        } else {
            return .invalid
        }
    }
    
    /// Generates a valid and random fake CNPJ.
    ///
    /// This method creates a random CNPJ, calculates the check digits, and returns a valid CNPJ.
    ///
    /// - Returns: A randomly generated valid fake CNPJ.
    ///
    /// **Usage example:**
    /// ```swift
    /// let validator = CNPJValidator()
    /// let fakeCNPJ = validator.generateFakeCNPJ()
    /// print(fakeCNPJ) // "11444777000135"
    /// ```
    public func generateFakeCNPJ() -> String {
        let get8RandomNumbers = (0..<8).compactMap({ _ in Int.random(in: 0...9) }) + [0, 0, 0, 1]
        
        var cnpj12Digits = get8RandomNumbers.compactMap({ Int(String($0)) })
        let multiplyFirstBy = [5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2]
        let multiplySecondBy = [6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2]
        
        let calculated1stCheckDigit = Double(calculatedCNPJCheckSum(cnpj12Digits: cnpj12Digits, multiplyBy: multiplyFirstBy)).truncatingRemainder(dividingBy: 11)
        calculated1stCheckDigit < 2 ? cnpj12Digits.append(0) : cnpj12Digits.append(11 - Int(calculated1stCheckDigit))
        
        let calculated2ndCheckDigit = Double(calculatedCNPJCheckSum(cnpj12Digits: cnpj12Digits, multiplyBy: multiplySecondBy)).truncatingRemainder(dividingBy: 11)
        calculated2ndCheckDigit < 2 ? cnpj12Digits.append(0) : cnpj12Digits.append(11 - Int(calculated2ndCheckDigit))
        
        let generatedFakeCNPJ = cnpj12Digits.compactMap({ String($0) }).joined()
        return validate(cnpj: generatedFakeCNPJ) == .valid ? generatedFakeCNPJ : generateFakeCNPJ()
    }
    
    /// Generates a fake CNPJ with a mask (readable format).
    ///
    /// This method generates a fake CNPJ and applies the formatting in the "xx.xxx.xxx/xxxx-xx" pattern.
    ///
    /// - Returns: The generated fake CNPJ with the applied mask, or `nil` if the CNPJ cannot be generated.
    ///
    /// **Usage example:**
    /// ```swift
    /// let validator = CNPJValidator()
    /// let fakeCNPJMasked = validator.generateFakeCNPJMasked()
    /// print(fakeCNPJMasked) // "11.444.777/0001-35"
    /// ```
    public func generateFakeCNPJMasked() -> String? {
        return formattedCNPJ(generateFakeCNPJ())
    }
    
    /// Formats a CNPJ in the "xx.xxx.xxx/xxxx-xx" pattern.
    ///
    /// - Parameter cnpj: The CNPJ to be formatted.
    /// - Returns: The formatted CNPJ, or `nil` if the CNPJ does not have exactly 14 digits.
    ///
    /// **Usage example:**
    /// ```swift
    /// let formatted = validator.formattedCNPJ("11444777000135")
    /// print(formatted) // "11.444.777/0001-35"
    /// ```
    func formattedCNPJ(_ cnpj: String) -> String {
        guard cnpj.count == 14 else { return cnpj }
        let formattedCNPJ = "\(cnpj.prefix(2)).\(cnpj.dropFirst(2).prefix(3)).\(cnpj.dropFirst(5).prefix(3))/\(cnpj.dropFirst(8).prefix(4))-\(cnpj.suffix(2))"
        return formattedCNPJ
    }
    
    /// Calculates the checksum of a base CNPJ, used to determine the check digits.
    ///
    /// - Parameters:
    ///   - cnpj12Digits: The first 12 digits of the CNPJ.
    ///   - multiplyBy: An array of multipliers for the checksum calculation.
    /// - Returns: The calculated checksum value.
    ///
    /// **Usage example:**
    /// ```swift
    /// let checkSum = validator.calculatedCNPJCheckSum(cnpj12Digits: [1, 1, 4, 4, 4, 7, 7, 7, 0, 0, 0, 1], multiplyBy: [5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2])
    /// print(checkSum) // Result of the calculation
    /// ```
    func calculatedCNPJCheckSum(cnpj12Digits: [Int], multiplyBy: [Int]) -> Int {
        let result = zip(cnpj12Digits, multiplyBy).map({ $0 * $1 })
        return result.reduce(0, +)
    }
    
    /// Applies a mask to the CNPJ, transforming it into the "xx.xxx.xxx/xxxx-xx" format.
    ///
    /// - Parameter cnpj: The CNPJ to be masked.
    /// - Returns: The CNPJ with the applied mask.
    ///
    /// **Usage example:**
    /// ```swift
    /// let maskedCNPJ = validator.applyCNPJMask(cnpj: "11444777000135")
    /// print(maskedCNPJ) // "11.444.777/0001-35"
    /// ```
    public func applyCNPJMask(cnpj: String) -> String {
        var originalText = cnpj.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        
        if originalText.count > 14 {
            originalText = String(originalText.prefix(14))
        }
        var maskedText = ""
        
        for (index, char) in originalText.enumerated() {
            if index == 2 || index == 5 {
                maskedText.append(".")
            } else if index == 8 {
                maskedText.append("/")
            } else if index == 12 {
                maskedText.append("-")
            }
            maskedText.append(char)
        }
        return maskedText
    }
}
