import XCTest
@testable import StringArithmetic


final class EquatabilityTests: XCTestCase {
    func testEquatability1() {
        let a: RationalNumber = "0"
        let b: RationalNumber = "0"
        XCTAssertEqual(a, b)
    }
    
    func testEquatability2() {
        let a: RationalNumber = "0"
        let b: RationalNumber = "0.0"
        XCTAssertEqual(a, b)
    }
    
    func testEquatability3() {
        let a: RationalNumber = "0"
        let b: RationalNumber = "1"
        XCTAssertNotEqual(a, b)
    }
    
    func testEquatability4() {
        let a: RationalNumber = "0"
        let b: RationalNumber = "0.1"
        XCTAssertNotEqual(a, b)
    }

    static var allTests = [
        ("testEquatability1", testEquatability1),
        ("testEquatability2", testEquatability2),
        ("testEquatability3", testEquatability3),
        ("testEquatability4", testEquatability4),
    ]
}
