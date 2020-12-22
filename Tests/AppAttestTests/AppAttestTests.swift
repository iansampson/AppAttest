import XCTest
@testable import AppAttest

final class AppAttestTests: XCTestCase {    
    func testAttestation() {
        do {
            try [TestData.iOS14_2, TestData.iOS14_3Beta2, TestData.iOS14_3Beta3, TestData.iOS14_3]
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

    static var allTests = [
        ("testAttestation", testAttestation),
    ]
}
