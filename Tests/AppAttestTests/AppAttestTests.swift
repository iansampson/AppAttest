import XCTest
@testable import AppAttest
import Crypto

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
                let request = AppAttest.AttestationRequest(attestation: $0.attestation, keyID: $0.keyID)
                let _ = try AppAttest.verifyAttestation(
                    challenge: $0.challenge,
                    request: request,
                    appID: appID,
                    date: $0.date
                )
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
                let response = AppAttest.AssertionRequest(
                    assertion: $0.assertion,
                    clientData: $0.clientData,
                    challenge: $0.receivedChallenge
                )
                let previousResult = $0.previousCounter.map { AppAttest.AssertionResult(counter: $0) }
                
                let _ = try AppAttest.verifyAssertion(
                    challenge: $0.storedChallenge,
                    request: response,
                    previousResult: previousResult,
                    publicKey: publicKey,
                    appID: appID
                )
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
