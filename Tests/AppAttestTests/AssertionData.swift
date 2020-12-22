//
//  AssertionData.swift
//  
//
//  Created by Ian Sampson on 2020-12-21.
//

struct AssertionData {
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
        
        /*var encoded: _AttestationData {
            AttestationData(
                appID: teamIdentifier + "." + bundleIdentifier,
                keyID: keyIdBase64,
                challenge: clientDataBase64,
                attestation: attestationBase64,
                timestamp: timestamp
            ).encoded
        }*/
    }
}
