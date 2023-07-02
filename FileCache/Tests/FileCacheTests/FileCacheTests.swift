import XCTest
@testable import FileCache

final class FileCacheTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(FileCache().text, "Hello, World!")
    }
}
