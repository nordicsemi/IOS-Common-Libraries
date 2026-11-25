//
//  PKCECodeGenerator.swift
//  iOSCommonLibraries
//
//  Created by Dinesh Harjani on 25/11/2026.
//  Copyright © 2026 Nordic Semiconductor. All rights reserved.
//

import Foundation
import CryptoKit

// MARK: - PKCECodeGenerator

/**
 Based on code seen by [Mick F.]( https://www.mickf.net/tech/oauth-pkce-swift-secure-code-verifiers-and-code-challenges/).
 */
public enum PKCECodeGenerator {
    
    // MARK: generateCodeVerifier()
    
    public static func generateCodeVerifier() throws -> String {
        let octets = try generateCryptographicallySecureRandomOctets(count: 32)
        return base64URLEncode(octets: octets)
    }
    
    // MARK: generateCodeChallenge(for:)
    
    public static func generateCodeChallenge(for verifier: String) throws(Error) -> String {
        let challenge = verifier
            .data(using: .ascii)
            .map { SHA256.hash(data: $0) }
            .map { base64URLEncode(octets: $0) }

        guard let challenge else {
            throw .failedToCreateChallengeForVerifier
        }
        return challenge
    }
    
    // MARK: Private
    
    private static func generateCryptographicallySecureRandomOctets(count: Int) throws(Error) -> [UInt8] {
        var octets = [UInt8](repeating: 0, count: count)
        let status = SecRandomCopyBytes(kSecRandomDefault, octets.count, &octets)
        guard status == errSecSuccess else {
            throw .failedToGenerateRandomOctets
        }
        return octets
    }
    
    private static func base64URLEncode<T>(octets: T) -> String where T: Sequence, UInt8 == T.Element {
        let data = Data(octets)
        return data
            .base64EncodedString()                    // Regular base64 encoder
            .replacingOccurrences(of: "=", with: "")  // Remove any trailing '='s
            .replacingOccurrences(of: "+", with: "-") // 62nd char of encoding
            .replacingOccurrences(of: "/", with: "_") // 63rd char of encoding
            .trimmingCharacters(in: .whitespaces)
    }
}

// MARK: - Error

public extension PKCECodeGenerator {
    
    enum Error: LocalizedError {
        case failedToGenerateRandomOctets
        case failedToCreateChallengeForVerifier
    }
}
