import Foundation
import SwiftUI

enum CalculatorOperation: CaseIterable, Equatable {
    case add
    case subtract
    case multiply
    case divide

    var displaySymbol: String {
        switch self {
        case .add: return "+"
        case .subtract: return "?"
        case .multiply: return "?"
        case .divide: return "?"
        }
    }

    var expressionSymbol: String {
        switch self {
        case .add: return "+"
        case .subtract: return "-"
        case .multiply: return "*"
        case .divide: return "/"
        }
    }
}

enum ExpressionToken: Equatable {
    case number(String)
    case link(String)
    case operation(CalculatorOperation)
}
