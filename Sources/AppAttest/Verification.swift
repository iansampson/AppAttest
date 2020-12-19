//
//  File.swift
//  
//
//  Created by Ian Sampson on 2020-12-18.
//

import Foundation
import CryptoKit
import SwiftCBOR
import Security

/*
func verifyAttestation(attestation data: Data, challenge: Data, keyID: Data) throws {
    // Evaluate the certificates.
    let decoder = CodableCBORDecoder()
    let attestation = try decoder.decode(Attestation.self, from: data)
    
    let clientDataHash = Data(SHA256.hash(data: challenge))
    let nonce = SHA256.hash(data: attestation.authenticatorData + clientDataHash)
    //let credentialPublicKeyCertificate = attestation.statement.x5c[0] // credCert
    // Or: publicKeyCredentialCertificate
    //let credentialPublicKeyCertificate = attestation.statement.x5c[0]
    let certificateData = attestation.statement.x5c[0]
    
    print("===")
    print(attestation.statement.x5c[1].base64EncodedString())
    print("===")
    
    let credentialCertificate = SecCertificateCreateWithData(nil, certificateData as CFData)!
    let leafCertificate = SecCertificateCreateWithData(nil, attestation.statement.x5c[1] as CFData)!
    let rootCertificateData = Data(base64Encoded: Certificate.rootCertificate)!
    let rootCertificate = SecCertificateCreateWithData(nil, rootCertificateData as CFData)!
    
    //let certificates = [leafCertificate, credentialCertificate, rootCertificate]
    let certificates = [rootCertificate, credentialCertificate, leafCertificate]
    var optionalTrust: SecTrust?
    let policy = SecPolicyCreateBasicX509()
    let status = SecTrustCreateWithCertificates(certificates as AnyObject, policy, &optionalTrust)
    guard status == errSecSuccess else { return }
    let trust = optionalTrust!
    
    SecTrustEvaluateAsyncWithError(trust, .global()) {
            trust, result, error in

            if result {
                //let publicKey = SecTrustCopyPublicKey(trust)
                print("Trusted!")
                
                // Use key . . .
            } else {
                print("Trust failed: \(error!.localizedDescription)")
            }
        }
    
    SecCertificateCopySubjectSummary(credentialCertificate)
    let oid = "1.2.840.113635.100.8.2"
    
    // TODO: Abstract this into its own section.
    // TODO: Remove dependency on Security.
    var error: Unmanaged<CFError>?
    guard let dictionary = SecCertificateCopyValues(credentialCertificate, nil, &error) as? [String : CFDictionary] else {
        throw error!.takeRetainedValue() as Error
    }
    let property = dictionary[oid] as! [String : CFArray]
    let value = property[kSecPropertyKeyValue as String]! as! [[String : AnyObject]]
    let octet = (value[1]["value"] as! Data).dropFirst(6)
    // Is dropping 6 reliable? Consider using a dedicated ASN.1 reader.
    if octet != Data(nonce) {
        // Throw error.
        return
    }
    
    print("Nonce matches.")
    
    let publicKey = SecCertificateCopyKey(credentialCertificate)!
    var publicKeyError: Unmanaged<CFError>?
    if let data = SecKeyCopyExternalRepresentation(publicKey, &publicKeyError) as Data? {
        let keyHash = SHA256.hash(data: data)
        if keyID == Data(keyHash) {
            print("Public key hash matches key ID")
            return
        }
    }
    
    let appIDHash = SHA256.hash(data: "38Q826TPZ9.ca.iansampson.zephyr-beta".data(using: .utf8)!)
    let rpIDHash = attestation.authenticatorData[0..<32]
    // DO NOT SAVE ANY OF THIS INTO SOURCE CONTROL.
    
    // TODO: Get the public key out of the certificate and get the SHA256 hash.
    
    if appIDHash == rpIDHash {
        print("App ID hash matches.")
    } else {
        return
    }
    
    let counterData = attestation.authenticatorData[33..<37]
    /*let counter = data.withUnsafeBytes { (buffer: UnsafeRawBufferPointer) -> UInt32 in
        buffer.baseAddress
    }*/
    
    let counter = counterData.reduce(0) { value, byte in
        value << 8 | Int32(byte) // UInt32 ?
    }
    // TODO: Add test for endian-ness.
    // But this seems to work.
    
    if counter == 0 {
        print("Counter field is zero.")
    } else {
        return
    }
    
    let aaguid = attestation.authenticatorData[37..<53]
    if aaguid == "appattestdevelop".data(using: .utf8)! || aaguid == "appattest".data(using: .utf8)! + Array<UInt8>(repeating: 0x00, count: 7) {
        // TODO: Use enum here.
        // Test whether appattest works as expected (in a production environment).
        print("AAGUID is valid: \(String(bytes: aaguid, encoding: .utf8)!).")
    } else {
        return
    }
    
    let credenetialIDLengthData = attestation.authenticatorData[53..<55]
    let credenetialIDLength = credenetialIDLengthData.reduce(0) { value, byte in
        value << 8 | UInt16(byte)
    }
    let credentialID = attestation.authenticatorData[55..<(55 + credenetialIDLength)]
    
    if keyID == credentialID {
        print("Credential ID matches key identifier.")
    } else {
        return
    }
    
    print("Attestation is trustworthy!")
    
    // TODO: Create an AuthenticatorData object that parses the blob.
    // At least the relevant parts of it.
    
    // Compare signed and unsigned versions of this algorithm.
    // Or find a Swift package that implements these conversions.
    
    // 16-bit unsigned big-endian integer.
    
    //var counter: UInt32 = .zero
    //let _ = withUnsafeMutableBytes(of: &counter, { data.copyBytes(to: $0)} )
    // big endian
    
    //https://stackoverflow.com/questions/43241845/how-can-i-convert-data-into-types-like-doubles-ints-and-strings-in-swift
    
    //let counter = counterData.withUnsafeBytes { $0.load(as: UInt32.self) }
    // How to ensure bigendian?
    //print(counter)
    
    // https://www.w3.org/TR/webauthn/#sec-authenticator-data
    
    //print(asn1Data)
    //print(result.count)
    //print(Data(nonce))
    //SimpleASN1Reader()
    // DER-encoded ASN.1 sequence.
    // -> octet string (i.e. a string of bytes)
    
    // Verify certificates
    // - [x] Read nonce from certificate extension
    // - [x] Read keyed values from authenticator data
}

// What’s missing?

// 1. Verify that the x5c array contains the intermediate and leaf certificates for App Attest, starting from the credential certificate stored in the first data buffer in the array (credcert). Verify the validity of the certificates using Apple’s App Attest root certificate.

// - [ ] Remove dependency on Security for this step and others involving the certificate.
// 4. Obtain the value of the credCert extension with OID 1.2.840.113635.100.8.2, which is a DER-encoded ASN.1 sequence. Decode the sequence and extract the single octet string that it contains. Verify that the string equals nonce.

// - [x] 5. Create the SHA256 hash of the public key in credCert,
// and verify that it matches the key identifier from your app.

// https://github.com/google/tink
*/
