import SwiftUI

struct KeypadView: View {
    @ObservedObject
    var calculatorMode: CalculatorMode

    var onKeyPressed: (_ key: Key) -> Void

    var body: some View {
        let keypadModel = calculatorMode.keypadModel

        Grid(horizontalSpacing: 1, verticalSpacing: 1) {
            ForEach(keypadModel.keyRows) { keyRow in
                GridRow {
                    ForEach(keyRow.keys) { key in
                        KeyView(key: key,
                                 onPressed: onKeyPressed)
                    }
                }
            }
        }
    }
}

struct KeypadView_Previews: PreviewProvider {
    static var previews: some View {
        KeypadView(calculatorMode: CalculatorMode(),
                    onKeyPressed: { key in print("Pressed key \(key.id)")})
    }
}

struct KeyView: View {
    var key: Key?
    var onPressed: (_ key: Key) -> Void

    var body: some View {
        let hPadding: CGFloat = (key?.isTightLayout ?? false) ? 2 : 6

        ZStack {
            Styles.keypadBackgroundColor
            Button(action: {
                guard let key = key else { return }
                onPressed(key)
            }) {
                VStack {
                    HStack {
                        Mod1Label(label: key?.opMod1?.symbol)
                        Spacer()
                        Mod2Label(label: key?.opMod2?.symbol)
                    }
                    .padding([.horizontal], hPadding)
                    .padding([.bottom], 4)
                    Spacer()
                    MainLabel(label: key?.op?.symbol,
                              labelColor: key?.mainTextColor)
                }
                .padding([.vertical], 4)
            }
            .buttonStyle(KeyViewStyle())
        }
    }
}

struct KeyView_Previews: PreviewProvider {
    static var previews: some View {
        KeyView(key: Key.pow(),
                 onPressed: { _ in })
        .frame(maxWidth: 50, maxHeight: 50)
    }
}

struct KeyViewStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ?
                        Styles.keyPressedBackgroundColor : Styles.keyBackgroundColor)
            .scaleEffect(configuration.isPressed ? 0.85 : 1,
                         anchor: .center)
            .animation(.interactiveSpring(response: 0.1, blendDuration: 0.1),
                       value: configuration.isPressed)
    }

}

struct MainLabel: View {
    var label: String?
    var labelColor: Color?

    var body: some View {
        KeyLabel(label: label,
                 font: Styles.keypadMainFont,
                 color: labelColor ?? Styles.keypadMainTextColor)
    }
}

struct Mod1Label: View {
    var label: String?

    var body: some View {
        KeyLabel(label: label,
                 font: Styles.keypadModFont,
                 color: Styles.mod1TextColor)
    }
}

struct Mod2Label: View {
    var label: String?

    var body: some View {
        KeyLabel(label: label,
                 font: Styles.keypadModFont,
                 color: Styles.mod2TextColor)
    }
}

struct KeyLabel: View {
    var label: String?
    var font: Font
    var color: Color

    var body: some View {
        Text(label ?? "")
            .font(font)
            .foregroundColor(color)
    }
}
