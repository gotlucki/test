import SwiftUI

struct CalculatorView: View {
    @StateObject private var viewModel = CalculatorViewModel()

    var body: some View {
        GeometryReader { _ in
            ZStack {
                Color.keypadBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    CalculatorDisplay(viewModel: viewModel)

                    historySection
                        .frame(maxWidth: .infinity)
                        .frame(maxHeight: .infinity)

                    CalculatorKeypad(viewModel: viewModel)
                }
            }
        }
    }

    private var historySection: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("??????? ??????????")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.top, 8)

                    if viewModel.calculations.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("????? ???????? ???? ??????????.")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.6))
                            Text("??????? ?? ????????? ? ???????, ????? ??????? ??? ? ????? ????????.")
                                .font(.footnote)
                                .foregroundColor(.white.opacity(0.4))
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.keypadSecondaryBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    } else {
                        ForEach(viewModel.calculations) { calculation in
                            CalculationRowView(
                                calculation: calculation,
                                resultColor: viewModel.color(for: calculation.alias),
                                colorProvider: viewModel.color(for:),
                                displayValueProvider: viewModel.displayValue(for:),
                                formattedResultProvider: viewModel.formatted(_:)
                            ) {
                                viewModel.insertLink(for: calculation)
                            }
                            .id(calculation.id)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
            .background(Color.black.opacity(0.85))
            .onChange(of: viewModel.calculations) { calculations in
                guard let last = calculations.last else { return }
                withAnimation(.easeInOut(duration: 0.3)) {
                    proxy.scrollTo(last.id, anchor: .bottom)
                }
            }
        }
    }
}
