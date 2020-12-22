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
                    let _ = try AppAttest.verify(
                        attestation: $0.attestation,
                        challenge: $0.challenge,
                        appID: appID,
                        keyID: $0.keyID,
                        date: $0.date
                    )
                    //print(result.publicKey)
                    //print(result.receipt)
                }
        } catch {
            XCTFail(error.localizedDescription)
        }
        // TODO: Print more specific errors (i.e. which set of test data).
    }
    
    func testAssertion() {
        do {
            let sample = AssertionSample.iOS14_3.encoded
            let appID = AppAttest.AppID(teamID: sample.teamID, bundleID: sample.bundleID)
            let publicKey = try P256.Signing.PublicKey(x963Representation: sample.publicKey)

            let _ = try AppAttest.verify(
                assertion: sample.assertion,
                clientData: sample.clientData,
                receivedChallenge: sample.receivedChallenge,
                storedChallenge: sample.storedChallenge,
                storedCounter: sample.previousCounter,
                appID: appID,
                publicKey: publicKey
            )
            //print(result)
            
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
