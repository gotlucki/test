import SwiftUI

struct KeypadButtonView: View {
    let title: String
    let backgroundColor: Color
    let foregroundColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 32, weight: .medium, design: .default))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .foregroundColor(foregroundColor)
                .minimumScaleFactor(0.5)
                .padding(.vertical, 20)
        }
        .frame(height: 72)
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 36, style: .continuous))
    }
}
