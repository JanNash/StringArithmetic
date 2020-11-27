//
//  RationalNumber.swift
//  
//
//  Created by Jan Nash on 26.11.20.
//


struct RationalNumber: ExpressibleByStringLiteral, CustomStringConvertible, CustomDebugStringConvertible {
    // Operations
    static func + (lhs: Self, rhs: Self) -> Self { add(lhs, rhs) }
    
    // CustomStringConvertible, CustomDebugStringConvertible
    var description: String { value }
    var debugDescription: String { "RationalNumber<\(integerValue)e-\(decimalPlaces); value: \(value)>" }
    
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
            let sum = add(x, y, carryOver)
            prepend(sum.value)
            carryOver = sum.carryOver
        }
        
        if carryOver != "0" { prepend(carryOver) }
        
        return RationalNumber(integerValue: integerValue, decimalPlaces: decimalPlaces)
    }
    
    // Helpers
    static func add(_ first: Character, _ second: Character, _ third: Character) -> (carryOver: Character, value: Character) {
        let first = add(first, second)
        let second = add(first.value, third)
        let carryOver = add(first.carryOver, second.carryOver)
        return (carryOver.value, second.value)
    }
    
    static func add(_ lhs: Character, _ rhs: Character) -> (carryOver: Character, value: Character) {
        switch (lhs, rhs) {
        case ("0", "0"):                                                    return ("0", "0")
        case ("0", "1"):                                                    return ("0", "1")
        case ("0", "2"), ("1", "1"):                                        return ("0", "2")
        case ("0", "3"), ("1", "2"):                                        return ("0", "3")
        case ("0", "4"), ("1", "3"), ("2", "2"):                            return ("0", "4")
        case ("0", "5"), ("1", "4"), ("2", "3"):                            return ("0", "5")
        case ("0", "6"), ("1", "5"), ("2", "4"), ("3", "3"):                return ("0", "6")
        case ("0", "7"), ("1", "6"), ("2", "5"), ("3", "4"):                return ("0", "7")
        case ("0", "8"), ("1", "7"), ("2", "6"), ("3", "5"), ("4", "4"):    return ("0", "8")
        case ("0", "9"), ("1", "8"), ("2", "7"), ("3", "6"), ("4", "5"):    return ("0", "9")
        case ("1", "9"), ("2", "8"), ("3", "7"), ("4", "6"), ("5", "5"):    return ("1", "0")
        case ("2", "9"), ("3", "8"), ("4", "7"), ("5", "6"):                return ("1", "1")
        case ("3", "9"), ("4", "8"), ("5", "7"), ("6", "6"):                return ("1", "2")
        case ("4", "9"), ("5", "8"), ("6", "7"):                            return ("1", "3")
        case ("5", "9"), ("6", "8"), ("7", "7"):                            return ("1", "4")
        case ("6", "9"), ("7", "8"):                                        return ("1", "5")
        case ("7", "9"), ("8", "8"):                                        return ("1", "6")
        case ("8", "9"):                                                    return ("1", "7")
        case ("9", "9"):                                                    return ("1", "8")
        default:                                                            return add(rhs, lhs)
        }
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
