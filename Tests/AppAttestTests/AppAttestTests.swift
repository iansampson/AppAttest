import XCTest
@testable import AppAttest
import CryptoKit

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
            try assertion.verify(testData)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    static var allTests = [
        ("testAttestation", testAttestation),
        ("testAssertion", testAssertion)
    ]
}

// TODO: Add tests for invalid attestations and assertions.
