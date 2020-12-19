//
//  File.swift
//  
//
//  Created by Ian Sampson on 2020-12-18.
//

import Foundation
import CryptoKit
import Anchor

extension Attestation {
    /// 1. Verify that the x5c array contains the intermediate and leaf certificates for App Attest,
    /// starting from the credential certificate stored in the first data buffer in the array (credcert).
    /// Verify the validity of the certificates using [Apple’s App Attest root certificate](https://www.apple.com/certificateauthority/private/).
    func verifyCertificates() throws {
        let anchor = try X509.Certificate(base64Encoded: Certificates.anchor, format: .der)
        let certificates = statement.certificates.reversed()
        let _ = try X509.Chain(trustAnchor: anchor)
            .validatingAndAppending(certificates: certificates)
    }
    
    /// 2. Create clientDataHash as the SHA256 hash of the one-time challenge sent to your app
    /// before performing the attestation, and append that hash to the end of the authenticator data
    /// (authData from the decoded object).
    /// 3. Generate a new SHA256 hash of the composite item to create nonce.
    func nonce(for challenge: Challenge) -> SHA256.Digest {
        let clientDataHash = Data(SHA256.hash(data: challenge.data))
        return SHA256.hash(data: authenticatorData.bytes + clientDataHash)
    }
    
    /// 4. Obtain the value of the credCert extension with OID 1.2.840.113635.100.8.2,
    /// which is a DER-encoded ASN.1 sequence. Decode the sequence and extract
    /// the single octet string that it contains. Verify that the string equals nonce.
    /*var octet: Data {
        
    }*/
    
    /// 5. Create the SHA256 hash of the public key in credCert, and verify that it matches
    /// the key identifier from your app.
    func publicKeyMatchesKeyID(_ keyID: Data) -> Bool {
        let certificate = statement.certificates[0]
        guard let publicKey = certificate.publicKey else {
            return false
            //fatalError()
            // TODO: Throw meaningful error.
        }
        let hash = SHA256.hash(data: publicKey)
        return hash == keyID
    }
}

extension AuthenticatorData {
    /// 6. Compute the SHA256 hash of your app’s App ID, and verify that this is the same
    /// as the authenticator data’s RP ID hash.
    func verify(appID: String) -> Bool {
        let hash = appID.data(using: .utf8)
            .map { SHA256.hash(data: $0) }
            .map { Data($0) }
        return rpID == hash
    }
    
    /// 7.  Verify that the authenticator data’s counter field equals 0.
    func verifyCounter() throws {
        guard counter == 0 else {
            // Throw error.
            return
        }
    }
    
    /// 8. Verify that the authenticator data’s aaguid field is either appattestdevelop if operating
    /// in the development environment, or appattest followed by seven 0x00 bytes if operating
    /// in the production environment.
    // AuthenticatorData.init(bytes:) already casts the raw bytes
    // in the aaguid field to an AAGUID enum, ensuring that the value
    // is valid.
    
    /// 9. Verify that the authenticator data’s credentialId field is the same as the key identifier.
    // TODO: Remove this method and just make this comparison
    // inside the larger function.
    func credentialIDMatchesKeyID(_ keyID: Data) -> Bool {
        credentialID == keyID
    }
}
