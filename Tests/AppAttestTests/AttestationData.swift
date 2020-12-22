//
//  TestData.swift
//  
//
//  Created by Ian Sampson on 2020-12-19.
//

import Foundation
@testable import AppAttest

extension AttestationData {
    struct Full {
        let id: String
        
        let teamIdentifier: String
        let bundleIdentifier: String
        
        let keyIdBase64: String
        let publicKey: String
        let clientDataBase64: String
        let clientDataHashSha256Base64: String
        
        let timestamp: Double // Int?
        let environment: Environment
        let iOSVersion: String
        
        let attestationBase64: String
        
        enum Environment {
            case production
            case development
        }
        
        var encoded: _AttestationData {
            AttestationData(
                appID: teamIdentifier + "." + bundleIdentifier,
                keyID: keyIdBase64,
                challenge: clientDataBase64,
                attestation: attestationBase64,
                timestamp: timestamp
            ).encoded
        }
    }
}

struct AttestationData {
    let appID: String
    let keyID: String // Base64-encoded
    let challenge: String // Base64-encoded
    let attestation: String // Base64-encoded
    let timestamp: Double
    
    var encoded: _AttestationData {
        _AttestationData(self)
    }
}

struct _AttestationData {
    let appID: String
    let keyID: Data
    let challenge: Data
    let attestation: Data
    let timestamp: Double
    
    init(_ unencoded: AttestationData) {
        self.appID = unencoded.appID
        self.keyID = Data(base64Encoded: unencoded.keyID)!
        self.challenge = Data(base64Encoded: unencoded.challenge)!
        self.attestation = Data(base64Encoded: unencoded.attestation)!
        self.timestamp = unencoded.timestamp
    }
}

extension Attestation {
    func verify(_ testData: _AttestationData) throws {
        try verify(
            challenge: Challenge(data: testData.challenge),
            appID: testData.appID,
            keyID: testData.keyID,
            date: Date(timeIntervalSince1970: testData.timestamp)
        )
    }
}
