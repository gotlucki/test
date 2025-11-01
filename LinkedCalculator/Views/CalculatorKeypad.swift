import SwiftUI

struct CalculatorKeypad: View {
    @ObservedObject var viewModel: CalculatorViewModel

    private let columns: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: 12), count: 4)

    private var buttons: [CalculatorButton] {
        [
            .clear, .plusMinus, .percent, .operation(.divide),
            .digit(7), .digit(8), .digit(9), .operation(.multiply),
            .digit(4), .digit(5), .digit(6), .operation(.subtract),
            .digit(1), .digit(2), .digit(3), .operation(.add),
            .digit(0), .decimal, .equals
        ]
    }

    var body: some View {
        VStack(spacing: 12) {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(buttons, id: \.self) { button in
                    KeypadButtonView(
                        title: title(for: button),
                        backgroundColor: button.backgroundColor,
                        foregroundColor: button.foregroundColor
                    ) {
                        viewModel.handle(button)
                    }
                    .gridCellColumns(button == .digit(0) ? 2 : 1)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .padding(.bottom, 32)
        .background(Color.keypadBackground)
    }

    private func title(for button: CalculatorButton) -> String {
        switch button {
        case .clear:
            return viewModel.clearButtonTitle
        case .plusMinus:
            return "?"
        case .percent:
            return "%"
        case .operation(let op):
            return op.displaySymbol
        case .digit(let value):
            return "\(value)"
        case .decimal:
            return "."
        case .equals:
            return "="
        }
    }
}
