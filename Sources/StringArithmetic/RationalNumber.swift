//
//  RationalNumber.swift
//  
//
//  Created by Jan Nash on 26.11.20.
//


// MARK: CustomStringConvertible, CustomDebugStringConvertible
extension RationalNumber: CustomStringConvertible, CustomDebugStringConvertible {
    var description: String { value }
    var debugDescription: String { "RationalNumber<\(integerValue)e-\(decimalPlaces); value: \(value)>" }
}


// MARK: Equatable
extension RationalNumber: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool { lhs.value == rhs.value }
}


// MARK: Hashable
extension RationalNumber: Hashable {
    func hash(into hasher: inout Hasher) { value.hash(into: &hasher) }
}


// MARK: Declaration
struct RationalNumber: ExpressibleByStringLiteral {
    // Operations
    static func + (lhs: Self, rhs: Self) -> Self { add(lhs, rhs) }
    
    // State
    private var integerValue: String
    private var decimalPlaces: UInt
    private let value: String
    private let separator: Character = "."
    
    // Initializers
    init(stringLiteral value: String) {
        guard value.count > 0 else { fatalError() }
        guard [value.first!, value.last!].allSatisfy(\.isNumber) else { fatalError() }
        
        var separatorIndex: Int?
        var integerValue = ""
        integerValue.reserveCapacity(value.count)
        for (index, character) in value.enumerated() {
            if character.isNumber {
                integerValue.append(character)
            } else if character == separator {
                guard separatorIndex == nil else { fatalError() }
                separatorIndex = index
            } else {
                fatalError()
            }
        }
        
        var decimalPlaces: UInt = 0
        if let separatorIndex = separatorIndex {
            decimalPlaces = UInt(abs(separatorIndex - (value.count - 1)))
        }
        
        let count = integerValue.count
        Self.removeTrailingZeroes(from: &integerValue)
        decimalPlaces -= UInt(count - integerValue.count)
        
        var prettifiedValue = value
        Self.removeLeadingZeroes(from: &prettifiedValue)
        Self.removeTrailingZeroes(from: &prettifiedValue)
        while prettifiedValue.hasSuffix(".0") || prettifiedValue.hasSuffix(".") {
            prettifiedValue.removeLast()
        }
        
        self.integerValue = integerValue
        self.decimalPlaces = decimalPlaces
        self.value = prettifiedValue
    }
    
    private init(integerValue: String, decimalPlaces: UInt) {
        self.integerValue = integerValue
        self.decimalPlaces = decimalPlaces
        
        Self.removeLeadingZeroes(from: &self.integerValue)
        
        let count = self.integerValue.count
        Self.removeTrailingZeroes(from: &self.integerValue)
        self.decimalPlaces -= UInt(count - self.integerValue.count)
        
        var value = self.integerValue
        let decimalPlacesInt = Int(self.decimalPlaces)
        let leadingZeroes = decimalPlacesInt + 1 - value.count
        if leadingZeroes > 0 {
            value.insert(contentsOf: String(repeating: "0", count: leadingZeroes), at: value.startIndex)
        }
        value.insert(separator, at: value.index(value.endIndex, offsetBy: -decimalPlacesInt))
        self.value = value
    }
}


// MARK: // Private
// MARK: Addition
private extension RationalNumber {
    static func add(_ lhs: Self, _ rhs: Self) -> Self {
        var (greaterIntValue, smallerIntValue): (String, String)
        let decimalPlaces: UInt
        
        (greaterIntValue, smallerIntValue, decimalPlaces) = {
            if lhs.decimalPlaces == rhs.decimalPlaces { return (lhs.integerValue, rhs.integerValue, lhs.decimalPlaces) }
            var (numToShift, otherNum) = lhs.decimalPlaces < rhs.decimalPlaces ? (lhs, rhs) : (rhs, lhs)
            numToShift.shiftLeft(by: otherNum.decimalPlaces - numToShift.decimalPlaces)
            
            if numToShift.integerValue.count < otherNum.integerValue.count {
                return (otherNum.integerValue, numToShift.integerValue, otherNum.decimalPlaces)
            }
            return (numToShift.integerValue, otherNum.integerValue, otherNum.decimalPlaces)
        }()
        
        var integerValue = ""
        integerValue.reserveCapacity(greaterIntValue.count + 1)
        let prepend: (Character) -> () = { integerValue.insert($0, at: integerValue.startIndex) }
        var carryOver: Character = "0"
        
        while let x = greaterIntValue.popLast() {
            let y = smallerIntValue.popLast() ?? "0"
            let sum = x.adding(y, carryOver)
            prepend(sum.value)
            carryOver = sum.carryOver
        }
        
        if carryOver != "0" { prepend(carryOver) }
        
        return RationalNumber(integerValue: integerValue, decimalPlaces: decimalPlaces)
    }
}


// MARK: Helpers
private extension RationalNumber {
    static func removeLeadingZeroes(from value: inout String) {
        while value.hasPrefix("00") { value.removeFirst() }
    }
    
    static func removeTrailingZeroes(from value: inout String) {
        while value.hasSuffix("00") { value.removeLast() }
    }
    
    mutating func shiftLeft(by decimalPlaces: UInt) {
        if decimalPlaces == 0 { return }
        self.integerValue += String(repeating: "0", count: Int(decimalPlaces))
        self.decimalPlaces += decimalPlaces
    }
}
