//
//  API.swift
//  
//
//  Created by Ian Sampson on 2020-12-21.
//

import Foundation
import CryptoKit

public enum AppAttest { }


// MARK: - Attestation

extension AppAttest {
    public struct AttestationResult {
        let publicKey: P256.Signing.PublicKey
        let receipt: Data
    }
    
    public struct AppID {
        let teamID: String
        let bundleID: String
        
        var description: String {
            "\(teamID).\(bundleID)"
        }
    }
    // TODO: Allow initialization with a String
    // or StringLiteral.
    
    public struct AttestationResponse {
        let attestation: Data
        let keyID: Data
    }
    
    public static func verifyAttestation(
        challenge: Data,
        response: AttestationResponse,
        appID: AppID,
        date: Date? = nil
    ) throws -> AttestationResult {
        let attestation = try Attestation(data: response.attestation)
        let certificate = attestation.statement.certificates[0]
        
        guard let publicKeyData = certificate.publicKey else {
            throw Attestation.ValidationError.invalidPublicKey
            // Or .missingPublicKey
        }
        let publicKey = try P256.Signing.PublicKey(x963Representation: publicKeyData)
        
        try attestation.verify(
            challenge: challenge,
            appID: appID.description,
            keyID: response.keyID,
            date: date
        )
        // TODO: Pass in publicKey as an argument.
        
        return AttestationResult(
            publicKey: publicKey,
            receipt: attestation.statement.receipt
        )
    }
}


// MARK: - Assertion

extension AppAttest {
    // TODO: Namespace this struct/
    // Assertion.ClientResponse
    // Assertion.Challenge.Response
    public struct AssertionResponse {
        let assertion: Data
        let clientData: Data
        let challenge: Data
    }
    
    public struct AssertionResult {
        let counter: Int
    }
    
    public static func verifyAssertion(
        challenge: Data,
        response: AssertionResponse,
        previousResult: AssertionResult?,
        publicKey: P256.Signing.PublicKey,
        appID: AppID
    ) throws -> AssertionResult {
        let assertion = try Assertion(cbor: response.assertion)
        try assertion.verify(
            clientData: response.clientData,
            publicKey: publicKey,
            appID: appID.description,
            previousCounter: previousResult?.counter,
            receivedChallenge: response.challenge,
            storedChallenge: challenge
        )
        return AssertionResult(counter: Int(assertion.authenticatorData.counter))
    }
}
