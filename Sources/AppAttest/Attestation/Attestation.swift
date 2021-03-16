//
//  Attestation.swift
//  
//
//  Created by Ian Sampson on 2020-12-16.
//

import Foundation
import Crypto
import SwiftCBOR
import Anchor

struct Attestation: Equatable {
    let format: String
    let statement: Statement
    let authenticatorData: AuthenticatorData
    
    struct Statement: Equatable {
        let certificates: [X509.Certificate]
        // TODO: Make certificates a struct with labels
        // and only two properties.
        let receipt: Data
    }
    
    init(data: Data) throws {
        let _attestation = try CodableCBOR(data: data)
        format = _attestation.format
        statement = try Statement(
            certificates: _attestation.statement.x5c.map {
                try X509.Certificate(bytes: $0, format: .der)
            },
            receipt: _attestation.statement.receipt)
        authenticatorData = try AuthenticatorData(bytes: _attestation.authenticatorData)
    }
    
    // TODO: Consider adding Codable conformance again,
    // if only to support JSON encoding.
}


// MARK: - CBOR

extension Attestation {
    fileprivate struct CodableCBOR: Codable {
        let format: String
        let statement: Statement
        let authenticatorData: Data
        
        struct Statement: Codable, Equatable {
            let x5c: [Data]
            let receipt: Data
        }
        
        enum CodingKeys: String, CodingKey {
            case format = "fmt"
            case statement = "attStmt"
            case authenticatorData = "authData"
        }
        
        init(data: Data) throws {
            let decoder = CodableCBORDecoder()
            self = try decoder.decode(CodableCBOR.self, from: data)
        }
    }
}
