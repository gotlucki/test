import Foundation

struct Calculation: Identifiable, Hashable {
    let id: UUID
    let alias: String
    let tokens: [ExpressionToken]
    let result: Decimal
    let resolvedExpression: String
    let timestamp: Date

    init(alias: String, tokens: [ExpressionToken], result: Decimal, resolvedExpression: String, timestamp: Date = Date()) {
        self.id = UUID()
        self.alias = alias
        self.tokens = tokens
        self.result = result
        self.resolvedExpression = resolvedExpression
        self.timestamp = timestamp
    }

    var linkedAliases: [String] {
        var seen: Set<String> = []
        return tokens.compactMap { token in
            if case .link(let alias) = token, !seen.contains(alias) {
                seen.insert(alias)
                return alias
            }
            return nil
        }
    }
}
