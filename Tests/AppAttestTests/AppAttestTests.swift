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
                keyID: testData.keyID,
                date: Date(timeIntervalSince1970: 1608163200)
            )
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testVeehaitch() {
        do {
            let testData = TestData.veehaitch.encoded
            let challenge = Challenge(data: testData.challenge)
            let attestation = try Attestation(data: testData.attestation)
            try attestation.verify(
                challenge: challenge,
                appID: testData.appID,
                keyID: testData.keyID,
                date: Date(timeIntervalSince1970: 1608379862)
            )
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
