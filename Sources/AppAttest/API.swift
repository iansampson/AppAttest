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
    
    public static func verify(
        // TODO: Make these inputs more type-safe.
        // Or at least document them properly
        // (e.g. Attestation is a CBOR representation.)
        attestation: Data,
        challenge: Data,
        appID: AppID,
        keyID: Data,
        date: Date? = nil
    ) throws -> AttestationResult {
        let attestation = try Attestation(data: attestation)
        let certificate = attestation.statement.certificates[0]
        
        guard let publicKeyData = certificate.publicKey else {
            throw Attestation.ValidationError.invalidPublicKey
            // Or .missingPublicKey
        }
        let publicKey = try P256.Signing.PublicKey(x963Representation: publicKeyData)
        
        try attestation.verify(
            challenge: challenge,
            appID: appID.description,
            keyID: keyID,
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
    public struct AssertionResult {
        let counter: Int
    }
    
    public struct ReceivedAssertion {
        let assertion: Data
        let clientData: Data
        let challenge: Data
    }
    
    // TODO: Refine this API
    // (e.g. disambiguate what stored and received mean,
    // and when counter should be nil.)
    public static func verify(
        assertion: Data,
        clientData: Data,
        receivedChallenge: Data,
        
        storedChallenge: Data, // sentChallenge?
        storedCounter: Int?, // previousCounter?
        
        appID: AppID,
        publicKey: P256.Signing.PublicKey
    ) throws -> AssertionResult {
        let assertion = try Assertion(cbor: assertion)
        try assertion.verify(
            clientData: clientData,
            publicKey: publicKey,
            appID: appID.description,
            previousCounter: storedCounter,
            receivedChallenge: receivedChallenge,
            storedChallenge: storedChallenge
        )
        return AssertionResult(counter: Int(assertion.authenticatorData.counter))
    }
}
