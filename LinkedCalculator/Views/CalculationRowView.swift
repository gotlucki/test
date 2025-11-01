import SwiftUI

struct CalculationRowView: View {
    let calculation: Calculation
    let resultColor: Color
    let colorProvider: (String) -> Color
    let displayValueProvider: (String) -> String
    let formattedResultProvider: (Decimal) -> String
    let onLink: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text(calculation.alias.uppercased())
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(resultColor)

                Spacer()

                Text(formattedResultProvider(calculation.result))
                    .font(.system(size: 32, weight: .semibold, design: .default))
                    .foregroundColor(resultColor)
            }

            expressionText
                .font(.system(size: 20, weight: .medium, design: .default))

            if !calculation.linkedAliases.isEmpty {
                HStack(spacing: 8) {
                    Text("?????:")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    ForEach(calculation.linkedAliases, id: \.self) { alias in
                        let color = colorProvider(alias)
                        Text(displayValueProvider(alias))
                            .font(.caption.weight(.semibold))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(color.opacity(0.2))
                            .foregroundColor(color)
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 18)
        .background(Color.keypadSecondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(resultColor.opacity(0.25), lineWidth: 1)
        )
        .onTapGesture(perform: onLink)
    }

    private var expressionText: Text {
        guard !calculation.tokens.isEmpty else { return Text(" ") }

        return calculation.tokens.enumerated().reduce(Text("")) { partial, element in
            let (index, token) = element
            let spacer = index == 0 ? "" : " "
            switch token {
            case .number(let value):
                return partial + Text(spacer + value).foregroundColor(.white)
            case .operation(let operation):
                return partial + Text(spacer + operation.displaySymbol).foregroundColor(.keypadAccent)
            case .link(let alias):
                let color = colorProvider(alias)
                let display = displayValueProvider(alias)
                return partial + Text(spacer + display).foregroundColor(color)
            }
        }
    }
}
