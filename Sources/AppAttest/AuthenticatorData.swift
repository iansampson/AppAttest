//
//  AuthenticatorData.swift
//  
//
//  Created by Ian Sampson on 2020-12-18.
//

import Foundation

/// Authenticator data as specified by the
/// [Web Authentication](https://www.w3.org/TR/webauthn/#sec-authenticator-data) specification.
struct AuthenticatorData: Equatable {
    let bytes: Data
    
    enum Error: Swift.Error {
        case invalidAAGUID
    }
    
    init(bytes: Data) throws {
        self.bytes = bytes
        
        // TODO: Consider moving this step elsewhere,
        // since AuthenticatorData is still valid without
        // the Apple-specific AAGUID.
        if let aaguid = AAGUID(bytes: bytes[37..<53]) {
            self.aaguid = aaguid
        } else {
            throw Error.invalidAAGUID
        }
    }
    
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
    
    /// An App Attest-specific constant that indicates whether the attested key belongs
    /// to the development or production environment. Apps generate keys using the former
    /// during development, and the latter after distribution, as described in
    ///[com.apple.developer.devicecheck.appattest-environment](https://developer.apple.com/documentation/bundleresources/entitlements/com_apple_developer_devicecheck_appattest-environment).
    
    /// 8. Verify that the authenticator data’s aaguid field is either appattestdevelop if operating
    /// in the development environment, or appattest followed by seven 0x00 bytes if operating
    /// in the production environment.
    let aaguid: AAGUID
    
    enum AAGUID: String, CaseIterable {
        case appAttest = "appattest"
        case appAttestDevelop = "appattestdevelop"
        
        init?(bytes: Data) {
            if let id = AAGUID.allCases.first(where: { bytes == $0.bytes }) {
                self = id
            } else {
                return nil
            }
        }
        
        var bytes: Data {
            let data = rawValue.data(using: .utf8)!
            switch self {
            case .appAttestDevelop:
                return data
            case .appAttest:
                return data + Data(repeatElement(0x00, count: 7))
            }
        }
    }
    
    var credentialID: Data {
        // Retrieve the two bytes that encode the length
        // of the credentialID as a UInt16.
        let length = bytes[53..<55].reduce(0) { value, byte in
            value << 8 | UInt16(byte)
        } // TODO: Refactor this into a generic function.
        return bytes[55..<(55 + length)]
    }
}

// TODO: Add custom decodable conformance.
