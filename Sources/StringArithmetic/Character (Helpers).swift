//
//  Character (Helpers).swift
//  
//
//  Created by Jan Nash on 27.11.20.
//


// MARK: // Internal
extension Character {
    typealias Sum = (carryOver: Character, value: Character)
    
    func adding(_ second: Character, _ third: Character) -> Sum {
        let firstSum = self.adding(second)
        let secondSum = firstSum.value.adding(third)
        let carryOver = firstSum.carryOver.adding(secondSum.carryOver)
        return (carryOver.value, secondSum.value)
    }
    
    func adding(_ other: Character) -> Sum {
        guard self.isNumber, other.isNumber else { fatalError() }
        switch (self, other) {
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
        default:                                                            return adding(other, self)
        }
    }
}
