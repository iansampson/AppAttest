import XCTest
@testable import AppAttest

final class AppAttestTests: XCTestCase {
    func testExample() {
        do {
            let testData = TestData.example.encoded
            let challenge = Challenge(data: testData.challenge)
            let attestation = try Attestation(data: testData.attestation)
            try attestation.verify(
                challenge: challenge,
                appID: testData.appID,
                keyID: testData.keyID
            )
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
