import SwiftUI

struct KeypadView2: View {
    let model: KeypadModel
    var onKeyPressed: (_ key: Key) -> Void

    var body: some View {
        Grid(horizontalSpacing: 1, verticalSpacing: 1) {
            ForEach(model.keyRows) { keyRow in
                GridRow {
                    ForEach(keyRow.keys) { key in
                        KeyView2(key: key,
                                 onPressed: onKeyPressed)
                    }
                }
            }
        }
    }
}

struct KeypadView2_Previews: PreviewProvider {
    static var previews: some View {
        KeypadView2(model: BasicKeypadModel(),
                    onKeyPressed: { key in print("Pressed key \(key.id)")})
    }
}

struct KeyView2: View {
    var key: Key?
    var onPressed: (_ key: Key) -> Void

    var body: some View {
        ZStack {
            Styles2.keypadBackgroundColor
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
                    .padding([.horizontal], 4)
                    .padding([.bottom], 4)
                    Spacer()
                    MainLabel(label: key?.op?.symbol,
                              labelColor: key?.mainTextColor)
                }
                .padding([.vertical], 4)
            }
            .buttonStyle(KeyView2Style())
        }
    }
}

struct KeyView2_Previews: PreviewProvider {
    static var previews: some View {
        KeyView2(key: Key.pow(),
                 onPressed: { _ in })
        .frame(maxWidth: 50, maxHeight: 50)
    }
}

struct KeyView2Style: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ?
                        Styles2.keyPressedBackgroundColor : Styles2.keyBackgroundColor)
            .scaleEffect(configuration.isPressed ? 0.85 : 1,
                         anchor: .center)
            .animation(.interactiveSpring(response: 0.1, blendDuration: 0.1),
                       value: configuration.isPressed)
    }

}

struct MainLabel: View {
    var label: String?
    var labelColor: UIColor?

    var body: some View {
        KeyLabel(label: label,
                 font: Styles2.keypadMainFont,
                 color: labelColor != nil ? labelColor!.asColor() : Styles2.keypadMainTextColor)
    }
}

struct Mod1Label: View {
    var label: String?

    var body: some View {
        KeyLabel(label: label,
                 font: Styles2.keypadModFont,
                 color: Styles2.mod1TextColor)
    }
}

struct Mod2Label: View {
    var label: String?

    var body: some View {
        KeyLabel(label: label,
                 font: Styles2.keypadModFont,
                 color: Styles2.mod2TextColor)
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
