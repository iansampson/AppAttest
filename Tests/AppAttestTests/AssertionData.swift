//
//  AssertionData.swift
//  
//
//  Created by Ian Sampson on 2020-12-21.
//

import Foundation
@testable import AppAttest

// TODO: Consider renaming to AssertionSample.
struct AssertionData {
    struct Short {
        let clientData: Data
        let publicKey: Data
        let appID: String
        let previousCounter: Int?
        let receivedChallenge: Data
        let storedChallenge: Data
        
        init(_ full: Full) {
            clientData = Data(base64Encoded: full.clientDataBase64)!
            publicKey = Data(base64Encoded: full.publicKey)!
            appID = full.teamIdentifier + "." + full.bundleIdentifier
            previousCounter = nil // TODO: Or not?
            receivedChallenge = Data(base64Encoded: full.challengeBase64)!
            storedChallenge = Data(base64Encoded: full.challengeBase64)!
        }
    }
    
    struct Full {
        let id: String
        
        let teamIdentifier: String
        let bundleIdentifier: String
        
        let keyIdBase64: String
        let publicKey: String
        let clientDataBase64: String
        let clientDataHashSha256Base64: String
        let challengeBase64: String
        let counter: Int
        
        let timestamp: Double // Int?
        let environment: Environment
        //let iOSVersion: String
        
        let assertionBase64: String
        
        enum Environment {
            case production
            case development
        }
    }
}

extension Assertion {
    func verify(_ assertionData: AssertionData.Full) throws {
        let short = AssertionData.Short(assertionData)
        try verify(
            clientData: short.clientData,
            publicKey: short.publicKey,
            appID: short.appID,
            previousCounter: short.previousCounter,
            receivedChallenge: short.receivedChallenge,
            storedChallenge: short.storedChallenge
            // TODO: Passing both challenges using the same data does not
            // really test anything, since the function just equates them.
        )
    }
}
