//
//  Validation.swift
//  
//
//  Created by Ian Sampson on 2020-12-18.
//

import Foundation
import CryptoKit
import Anchor

extension Attestation {
    enum ValidationError: Error {
        case invalidNonce
        case invalidAppIDHash
        case invalidPublicKey
        case invalidCounter
        case invalidCredentialID
    }
    // TODO: Rewrite as a struct with expected and received
    // or with compared values. Or add associated types.
    
    func verify(challenge: Challenge, appID: String, keyID: Data, date: Date? = nil) throws {
        // 1.
        try verifyCertificates(date: date)
        // Fails to validate leaf certificate
        
        // 2 & 3.
        let nonce = self.nonce(for: challenge)
        
        // 4.
        let octet = try extractOctet()
        guard octet == Array(nonce) else {
            throw ValidationError.invalidNonce
        }
        
        // 5.
        guard publicKeyMatchesKeyID(keyID) else {
            throw ValidationError.invalidPublicKey
        }
        
        // 6.
        try authenticatorData.verify(appID: appID)
        
        // 7.
        try authenticatorData.verifyCounter()
        
        // 8.
        // Already checked aaguid.
        // However we could change that to a method,
        // e.g. verifyAAGUID or extractAAGUID.
        
        // 9.
        try authenticatorData.verifyKeyID(keyID)
    }
    
    /// 1. Verify that the x5c array contains the intermediate and leaf certificates for App Attest,
    /// starting from the credential certificate stored in the first data buffer in the array (credcert).
    /// Verify the validity of the certificates using [Apple’s App Attest root certificate](https://www.apple.com/certificateauthority/private/).
    func verifyCertificates(date: Date?) throws {
        let anchor = try X509.Certificate(
            base64Encoded: Certificates.appleAppAttestationRootCA,
            format: .der
        )
        
        let _ = try X509.Chain(trustAnchor: anchor)
            .validatingAndAppending(
                certificate: statement.certificates[1],
                posixTime: date?.timeIntervalSince1970
            )
            .validatingAndAppending(
                certificate: statement.certificates[0],
                posixTime: date?.timeIntervalSince1970
            )
            //.validatingAndAppending(certificate: statement.certificates[0])
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
    // See extractOctet()
    
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
    func verify(appID: String) throws {
        let hash = appID.data(using: .utf8)
            .map { SHA256.hash(data: $0) }
            .map { Data($0) }
        guard rpID == hash else {
            throw Attestation.ValidationError.invalidAppIDHash
        }
    }
    
    /// 7.  Verify that the authenticator data’s counter field equals 0.
    func verifyCounter() throws {
        guard counter == 0 else {
            throw Attestation.ValidationError.invalidCounter
        }
    }
    
    /// 8. Verify that the authenticator data’s aaguid field is either appattestdevelop if operating
    /// in the development environment, or appattest followed by seven 0x00 bytes if operating
    /// in the production environment.
    // AuthenticatorData.init(bytes:) already casts the raw bytes
    // in the aaguid field to an AAGUID enum, ensuring that the value
    // is valid.
    // Because the aaguid is specific to Apple, we could *not*
    // declare it as a property on the authenticator data,
    // and instead compute it when performing these checks.
    
    /// 9. Verify that the authenticator data’s credentialId field is the same as the key identifier.
    // TODO: Remove this method and just make this comparison
    // inside the larger function.
    func verifyKeyID(_ keyID: Data) throws {
        guard credentialID == keyID else {
            throw Attestation.ValidationError.invalidCredentialID
        }
    }
}
