import XCTest
@testable import AppAttest
import CryptoKit

final class AppAttestTests: XCTestCase {    
    func testAttestation() {
        do {
            let samples = [
                AttestationSample.iOS14_2,
                AttestationSample.iOS14_3Beta2,
                AttestationSample.iOS14_3Beta3,
                AttestationSample.iOS14_3
            ].map { $0.encoded }
            
            try samples.forEach {
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
            let samples = [
                AssertionSample.iOS14_2,
                AssertionSample.iOS14_2Beta2,
                AssertionSample.iOS14_2Beta3,
                AssertionSample.iOS14_3
            ].map { $0.encoded }
            
            try samples.forEach {
                let appID = AppAttest.AppID(teamID: $0.teamID, bundleID: $0.bundleID)
                let publicKey = try P256.Signing.PublicKey(x963Representation: $0.publicKey)

                let _ = try AppAttest.verify(
                    assertion: $0.assertion,
                    clientData: $0.clientData,
                    receivedChallenge: $0.receivedChallenge,
                    storedChallenge: $0.storedChallenge,
                    storedCounter: $0.previousCounter,
                    appID: appID,
                    publicKey: publicKey
                )
                //print(result)
            }
            
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
