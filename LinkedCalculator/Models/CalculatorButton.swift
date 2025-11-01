import SwiftUI

enum CalculatorButton: Hashable {
    case clear
    case plusMinus
    case percent
    case operation(CalculatorOperation)
    case digit(Int)
    case decimal
    case equals

    var backgroundColor: Color {
        switch self {
        case .clear, .plusMinus, .percent:
            return Color.keypadFunction
        case .operation, .equals:
            return Color.keypadAccent
        case .digit, .decimal:
            return Color.keypadPrimary
        }
    }

    var foregroundColor: Color {
        switch self {
        case .clear, .plusMinus, .percent:
            return Color.black
        default:
            return Color.white
        }
    }
}
