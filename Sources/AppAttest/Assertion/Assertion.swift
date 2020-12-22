//
//  Assertion.swift
//  
//
//  Created by Ian Sampson on 2020-12-21.
//

import Foundation
import CryptoKit
import SwiftCBOR

struct Assertion {
    let signature: Data
    let authenticatorData: AuthenticatorData
    
    init(cbor data: Data) throws {
        let decoder = CodableCBORDecoder()
        let decoded = try decoder.decode(CodableCBOR.self, from: data)
        signature = decoded.signature
        authenticatorData = AuthenticatorData(bytes: decoded.authenticatorData)
        // TODO: Validate authenticator data before completing initialization.
    }
}

extension Assertion {
    struct AuthenticatorData {
        let bytes: Data
        
        /// A hash of your app’s App ID, which is the concatenation of your 10-digit team identifier,
        /// a period, and your app’s CFBundleIdentifier value.
        var rpID: Data {
            bytes[0..<32]
        }
        
        /// The number of times your app used the attested key to sign an assertion.
        var counter: Int32 {
            bytes[33..<37].reduce(0) { value, byte in
                value << 8 | Int32(byte) // UInt32 ?
            }
        }
    }
}

extension Assertion {
    struct CodableCBOR: Codable {
        let signature: Data
        let authenticatorData: Data
    }
}

extension Assertion {
    enum ValidationError: Error {
        case invalidSignature // or invalidKey
        case invalidAppID
        case invalidCounter
        case invalidClientData
        // TODO: Make these errors more specific.
    }
    
    func verify(
        clientData: Data,
        publicKey: Data,
        appID: String,
        previousCounter: Int?, // TODO: Consider renaming to storedCounter
        receivedChallenge: Data,
        storedChallenge: Data
    ) throws {
        // 1. Compute clientDataHash as the SHA256 hash of clientData.
        let clientDataHash = SHA256.hash(data: clientData)
        
        // 2. Concatenate authenticatorData and clientDataHash
        // and apply a SHA256 hash over the result to form nonce.
        let nonce = SHA256.hash(data: authenticatorData.bytes + clientDataHash)
        
        // 3. Use the public key that you stored from the attestation object
        // to verify that the assertion’s signature is valid for nonce.
        let signingKey = try P256.Signing.PublicKey(x963Representation: publicKey)
        let signature = try P256.Signing.ECDSASignature(derRepresentation: self.signature)
        guard signingKey.isValidSignature(signature, for: nonce) else {
            throw ValidationError.invalidSignature
        }
        // Signature algorithm: SHA256withECDSA
        // TODO: Call to .isValidSignature returns false.
        
        // signing key
        // signature: der-encoded -> ansi-represented -> CryptoKit
        // nonce
        
        // 4. Compute the SHA256 hash of the client’s App ID, and verify
        // that it matches the RP ID in the authenticator data.
        let appIDHash = SHA256.hash(data: appID.data(using: .utf8)!)
        // TODO: Avoid force unwrap.
        guard authenticatorData.rpID == Data(appIDHash) else {
            throw ValidationError.invalidAppID
        }

        // 5. Verify that the authenticator data’s counter value is greater
        // than the value from the previous assertion, or greater than 0
        // on the first assertion.
        if let previousCounter = previousCounter {
            guard authenticatorData.counter > previousCounter else {
                throw ValidationError.invalidCounter
            }
        } else {
            guard authenticatorData.counter > 0 else {
                throw ValidationError.invalidCounter
            }
        }

        // 6. Verify that the challenge embedded in the client data matches
        // the earlier challenge to the client.
        guard receivedChallenge == storedChallenge else {
            throw ValidationError.invalidClientData
        }
        
        // TODO: Store counter for use in step 5 of verifying the next assertion.
    }
}
