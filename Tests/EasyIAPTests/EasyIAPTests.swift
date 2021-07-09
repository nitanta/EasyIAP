import XCTest
@testable import EasyIAP

final class EasyIAPTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(EasyIAP().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
