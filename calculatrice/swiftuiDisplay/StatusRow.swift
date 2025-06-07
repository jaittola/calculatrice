import SwiftUI

struct StatusRow: View {
    @ObservedObject
    var calculatorMode: CalculatorMode

    var body: some View {
        HStack(spacing: 12) {
            Spacer()
            StatusRowItem(title: "DEG", isActive: calculatorMode.angle == .Deg)
            StatusRowItem(title: "RAD", isActive: calculatorMode.angle == .Rad)
            StatusRowItem(title: "Alt 1",
                          isActive: calculatorMode.keypadMode == .Mod1,
                          activeLabelColor: Styles.mod1TextColor)
            StatusRowItem(title: "Alt 2",
                          isActive: calculatorMode.keypadMode == .Mod2,
                          activeLabelColor: Styles.mod2TextColor)
            Spacer()
        }
        .background(.white)
        .frame(maxWidth: .infinity)
    }
}

struct StatusRow2_Previews: PreviewProvider {
    static var previews: some View {
        StatusRow(calculatorMode: CalculatorMode())
    }
}

struct StatusRowItem: View {
    var title: String
    var isActive: Bool
    var activeLabelColor: Color = Styles.activeLabelColor

    var body: some View {
        Text(title)
            .font(Styles.inputDisplayLabelFont)
            .foregroundColor(isActive ? activeLabelColor : Styles.inactiveLabelColor)
            .background(isActive ? Styles.windowBackgroundColor : Styles.displayBackgroundColor)
    }
}

struct StatusRowItem_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            StatusRowItem(title: "Deg", isActive: false)
            StatusRowItem(title: "Rad", isActive: true)
            StatusRowItem(title: "Alt 1",
                          isActive: true,
                          activeLabelColor: Styles.mod2TextColor)
        }
    }
}
