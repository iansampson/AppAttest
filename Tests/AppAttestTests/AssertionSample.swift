//
//  AssertionSample.swift
//  
//
//  Created by Ian Sampson on 2020-12-21.
//

import Foundation
@testable import AppAttest

struct AssertionSample {
    struct Short {
        let assertion: Data
        let clientData: Data
        let publicKey: Data
        let teamID: String
        let bundleID: String
        let previousCounter: Int?
        let receivedChallenge: Data
        let storedChallenge: Data
        
        init(_ assertion: Long) {
            self.assertion = Data(base64Encoded: assertion.assertionBase64)!
            clientData = Data(base64Encoded: assertion.clientDataBase64)!
            publicKey = Data(base64Encoded: assertion.publicKey)!
            teamID = assertion.teamIdentifier
            bundleID = assertion.bundleIdentifier
            previousCounter = nil // TODO: Or not?
            receivedChallenge = Data(base64Encoded: assertion.challengeBase64)!
            storedChallenge = Data(base64Encoded: assertion.challengeBase64)!
        }
    }
    
    struct Long {
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
        
        var encoded: Short {
            Short(self)
        }
    }
}

/*extension Assertion {
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
}*/
