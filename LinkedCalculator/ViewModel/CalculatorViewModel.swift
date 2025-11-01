import Foundation
import SwiftUI

final class CalculatorViewModel: ObservableObject {
    @Published private(set) var calculations: [Calculation] = []
    @Published private(set) var previewResult: String = "0"
    @Published private(set) var tokens: [ExpressionToken] = []
    @Published private(set) var currentInput: String = ""

    private var aliasCounter: Int = 0
    private var aliasStore: [String: Calculation] = [:]
    private var aliasColors: [String: Color] = [:]
    private var colorIndex: Int = 0
    private var shouldResetOnNextDigit: Bool = false

    private let resultFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 8
        formatter.minimumFractionDigits = 0
        formatter.usesGroupingSeparator = true
        return formatter
    }()

    private let palette: [Color] = [
        Color(red: 76 / 255, green: 217 / 255, blue: 100 / 255),
        Color(red: 90 / 255, green: 200 / 255, blue: 250 / 255),
        Color(red: 255 / 255, green: 149 / 255, blue: 0 / 255),
        Color(red: 255 / 255, green: 59 / 255, blue: 48 / 255),
        Color(red: 88 / 255, green: 86 / 255, blue: 214 / 255),
        Color(red: 255 / 255, green: 204 / 255, blue: 0 / 255)
    ]

    // MARK: - Public API

    var clearButtonTitle: String {
        (tokens.isEmpty && currentInput.isEmpty) ? "AC" : "C"
    }

    func handle(_ button: CalculatorButton) {
        switch button {
        case .digit(let value):
            appendDigit(value)
        case .decimal:
            appendDecimal()
        case .operation(let operation):
            appendOperation(operation)
        case .equals:
            commitCalculation()
        case .clear:
            clear()
        case .plusMinus:
            toggleSign()
        case .percent:
            applyPercent()
        }
        updatePreview()
    }

    func insertLink(for calculation: Calculation) {
        if shouldResetOnNextDigit {
            tokens = []
            currentInput = ""
            shouldResetOnNextDigit = false
        }

        if !currentInput.isEmpty {
            tokens.append(.number(currentInput))
            currentInput = ""
        }

        tokens.append(.link(calculation.alias))
        updatePreview()
    }

    func color(for alias: String) -> Color {
        aliasColors[alias] ?? palette.first ?? .green
    }

    func displayValue(for alias: String) -> String {
        guard let calculation = aliasStore[alias] else { return alias }
        return format(calculation.result)
    }

    func formatted(_ value: Decimal) -> String {
        format(value)
    }

    func presentationTokens() -> [ExpressionToken] {
        var items = tokens
        if !currentInput.isEmpty {
            items.append(.number(currentInput))
        }
        return items
    }

    func expressionText() -> Text {
        let segments = presentationTokens()
        guard !segments.isEmpty else {
            return Text(" ")
        }

        return segments.enumerated().reduce(Text("")) { partial, element in
            let (index, token) = element
            let spacer = index == 0 ? "" : " "
            switch token {
            case .number(let value):
                return partial + Text(spacer + value).foregroundColor(.white)
            case .operation(let op):
                return partial + Text(spacer + op.displaySymbol).foregroundColor(.keypadAccent)
            case .link(let alias):
                let color = color(for: alias)
                let display = displayValue(for: alias)
                return partial + Text(spacer + display).foregroundColor(color)
            }
        }
    }

    // MARK: - Private helpers

    private func appendDigit(_ value: Int) {
        prepareForNewInputIfNeeded()
        if currentInput == "0" {
            currentInput = "\(value)"
        } else {
            currentInput.append("\(value)")
        }
    }

    private func appendDecimal() {
        prepareForNewInputIfNeeded()
        if currentInput.isEmpty {
            currentInput = "0."
        } else if !currentInput.contains(".") {
            currentInput.append(".")
        }
    }

    private func appendOperation(_ operation: CalculatorOperation) {
        if shouldResetOnNextDigit {
            shouldResetOnNextDigit = false
        }

        commitCurrentInput()

        if let last = tokens.last, case .operation = last {
            tokens.removeLast()
        }

        tokens.append(.operation(operation))
    }

    private func commitCalculation() {
        let evaluationTokens = sanitizedTokens(appendingCurrentInput: true)
        guard !evaluationTokens.isEmpty else { return }

        guard let evaluation = evaluate(tokens: evaluationTokens) else { return }

        let alias = nextAlias()
        let calculation = Calculation(
            alias: alias,
            tokens: evaluationTokens,
            result: evaluation.result,
            resolvedExpression: evaluation.resolvedExpression
        )

        calculations.append(calculation)
        aliasStore[alias] = calculation
        aliasColors[alias] = nextColor()

        let plain = plainString(from: evaluation.result)
        tokens = []
        currentInput = plain
        shouldResetOnNextDigit = true
        previewResult = format(evaluation.result)
    }

    private func clear() {
        tokens = []
        currentInput = ""
        previewResult = "0"
        shouldResetOnNextDigit = false
    }

    private func toggleSign() {
        if !currentInput.isEmpty {
            if currentInput.hasPrefix("-") {
                currentInput.removeFirst()
            } else {
                currentInput = "-" + currentInput
            }
            return
        }

        guard let lastIndex = tokens.lastIndex(where: { token in
            if case .number = token { return true }
            return false
        }) else { return }

        if case .number(let value) = tokens[lastIndex] {
            if value.hasPrefix("-") {
                let positive = String(value.dropFirst())
                tokens[lastIndex] = .number(positive)
            } else {
                tokens[lastIndex] = .number("-" + value)
            }
        }
    }

    private func applyPercent() {
        if !currentInput.isEmpty {
            guard let value = Decimal(string: currentInput, locale: Locale(identifier: "en_US_POSIX")) else { return }
            let percentValue = value / 100
            currentInput = plainString(from: percentValue)
            return
        }

        guard let lastIndex = tokens.lastIndex(where: { token in
            if case .number = token { return true }
            return false
        }) else { return }

        if case .number(let value) = tokens[lastIndex],
           let decimalValue = Decimal(string: value, locale: Locale(identifier: "en_US_POSIX")) {
            let percentValue = decimalValue / 100
            tokens[lastIndex] = .number(plainString(from: percentValue))
        }
    }

    private func prepareForNewInputIfNeeded() {
        if shouldResetOnNextDigit {
            tokens = []
            currentInput = ""
            shouldResetOnNextDigit = false
        }
    }

    private func commitCurrentInput() {
        if !currentInput.isEmpty {
            tokens.append(.number(currentInput))
            currentInput = ""
        }
    }

    private func sanitizedTokens(appendingCurrentInput: Bool) -> [ExpressionToken] {
        var items = tokens
        if appendingCurrentInput, !currentInput.isEmpty {
            items.append(.number(currentInput))
        }
        if let last = items.last, case .operation = last {
            items.removeLast()
        }
        return items
    }

    private func evaluate(tokens: [ExpressionToken]) -> (result: Decimal, resolvedExpression: String)? {
        guard !tokens.isEmpty else { return nil }
        let resolvedExpression = expressionString(for: tokens, resolved: true)
        guard let value = ExpressionEvaluator.evaluate(expression: resolvedExpression) else { return nil }
        return (value, resolvedExpression)
    }

    private func expressionString(for tokens: [ExpressionToken], resolved: Bool) -> String {
        tokens.map { token in
            switch token {
            case .number(let value):
                return value
            case .operation(let op):
                return resolved ? op.expressionSymbol : op.displaySymbol
            case .link(let alias):
                if resolved, let replacement = resolvedValue(for: alias) {
                    return replacement
                }
                return alias
            }
        }.joined(separator: " ")
    }

    private func resolvedValue(for alias: String) -> String? {
        guard let calculation = aliasStore[alias] else { return nil }
        let value = plainString(from: calculation.result)
        if value.contains("-") {
            return "(\(value))"
        }
        return value
    }

    private func updatePreview() {
        let evaluationTokens = sanitizedTokens(appendingCurrentInput: true)

        if let evaluation = evaluate(tokens: evaluationTokens) {
            previewResult = format(evaluation.result)
        } else if !currentInput.isEmpty {
            previewResult = currentInput
        } else {
            previewResult = "0"
        }
    }

    private func nextAlias() -> String {
        aliasCounter += 1
        return "L\(aliasCounter)"
    }

    private func nextColor() -> Color {
        guard !palette.isEmpty else { return .green }
        let color = palette[colorIndex % palette.count]
        colorIndex += 1
        return color
    }

    private func format(_ value: Decimal) -> String {
        let number = NSDecimalNumber(decimal: value)
        return resultFormatter.string(from: number) ?? number.stringValue
    }

    private func plainString(from value: Decimal) -> String {
        NSDecimalNumber(decimal: value).stringValue
    }
}
