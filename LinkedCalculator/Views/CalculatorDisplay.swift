import SwiftUI

struct CalculatorDisplay: View {
    @ObservedObject var viewModel: CalculatorViewModel

    var body: some View {
        VStack(alignment: .trailing, spacing: 12) {
            ScrollView(.horizontal, showsIndicators: false) {
                viewModel.expressionText()
                    .font(.system(size: 28, weight: .medium, design: .default))
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.trailing, 4)
            }

            Text(viewModel.previewResult)
                .font(.system(size: 64, weight: .light, design: .default))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
        .padding(.horizontal, 24)
        .padding(.top, 32)
        .padding(.bottom, 24)
        .background(Color.keypadBackground)
    }
}
