import XCTest
@testable import AppAttest
import CryptoKit

final class AppAttestTests: XCTestCase {    
    func testAttestation() {
        do {
            try [
                AttestationSample.iOS14_2,
                AttestationSample.iOS14_3Beta2,
                AttestationSample.iOS14_3Beta3,
                AttestationSample.iOS14_3
            ]
                .map {
                    $0.encoded
                }
                .forEach {
                    let appID = AppAttest.AppID(teamID: $0.teamID, bundleID: $0.bundleID)
                    let result = try AppAttest.verify(
                        attestation: $0.attestation,
                        challenge: $0.challenge,
                        appID: appID,
                        keyID: $0.keyID,
                        date: $0.date
                    )
                    print(result.publicKey)
                    print(result.receipt)
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
// TODO: Support receipt validation and fraud assessment
// https://developer.apple.com/documentation/devicecheck/assessing_fraud_risk
