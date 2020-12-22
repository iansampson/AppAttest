import XCTest
@testable import AppAttest

final class AppAttestTests: XCTestCase {    
    func testAttestation() {
        do {
            try [
                AttestationData.iOS14_2,
                AttestationData.iOS14_3Beta2,
                AttestationData.iOS14_3Beta3,
                AttestationData.iOS14_3
            ]
                .map {
                    $0.encoded
                }
                .forEach {
                    let attestation = try Attestation(data: $0.attestation)
                    try attestation.verify($0)
                }
        } catch {
            XCTFail(error.localizedDescription)
        }
        // TODO: Print more specific errors (i.e. which set of test data).
    }
    
    func testAssertion() {
        do {
            let testData = AssertionData.iOS14_3
            let assertion = try Assertion(cbor: Data(base64Encoded: testData.assertionBase64)!)
            
            // Decode DER-encoded SPKI into raw bytes.
            let publicKeyData = Data(base64Encoded: testData.publicKey)!
            let node = try ASN1.parse(Array(publicKeyData))
            let keyInfo = try ASN1.SubjectPublicKeyInfo(asn1Encoded: node)
            let publicKey = Data(keyInfo.key.bytes)
            
            try assertion.verify(
                clientData: Data(base64Encoded: testData.clientDataBase64)!,
                publicKey: publicKey,
                appID: testData.teamIdentifier + "." + testData.bundleIdentifier,
                previousCounter: nil, //testData.counter,
                receivedChallenge: Data(base64Encoded: testData.challengeBase64)!,
                storedChallenge: Data(base64Encoded: testData.challengeBase64)!
                // TODO: Passing both challenges using the same data does not
                // really test anything, since the function just equates them.
            )
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    static var allTests = [
        ("testAttestation", testAttestation),
    ]
}
