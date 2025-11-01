import Foundation

struct ExpressionEvaluator {
    static func evaluate(expression: String) -> Decimal? {
        let sanitized = expression
            .replacingOccurrences(of: "?", with: "/")
            .replacingOccurrences(of: "?", with: "*")

        let nsExpression = NSExpression(format: sanitized)
        guard let value = nsExpression.expressionValue(with: nil, context: nil) as? NSNumber else { return nil }
        return Decimal(value.doubleValue)
    }
}
