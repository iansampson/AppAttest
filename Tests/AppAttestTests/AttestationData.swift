//
//  TestData.swift
//  
//
//  Created by Ian Sampson on 2020-12-19.
//

import Foundation

struct AttestationData {
    let appID: String
    let keyID: String // Base64-encoded
    let challenge: String // Base64-encoded
    let attestation: String // Base64-encoded
    
    var encoded: _AttestationData {
        _AttestationData(self)
    }
}

struct _AttestationData {
    let appID: String
    let keyID: Data
    let challenge: Data
    let attestation: Data
    
    init(_ unencoded: AttestationData) {
        self.appID = unencoded.appID
        self.keyID = Data(base64Encoded: unencoded.keyID)!
        self.challenge = Data(base64Encoded: unencoded.challenge)!
        self.attestation = Data(base64Encoded: unencoded.attestation)!
    }
}
