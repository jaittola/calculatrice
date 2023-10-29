import SwiftUI

struct HelpView: View {
    @Environment(\.dismiss) var dismiss

    var keypadModel: KeypadModel

    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Spacer()
                    Button("Close") { dismiss() }
                }
                HelpTitle(title: "HelpTitle")
                HelpParagraph(bodyText: "GenericHelpBody")
                HelpTitle(title: "HelpFunctions")
                HelpKeypad(keypad: keypadModel)

                Spacer()
            }
            .padding([.horizontal], 12)
        }
        .padding([.vertical], 12)
    }
}

struct HelpTitle: View {
    var title: String

    var body: some View {
        Text(LocalizedStringKey(title))
            .font(.headline)
            .frame(maxWidth: .infinity, alignment: .leading)
            .multilineTextAlignment(.leading)
            .padding([.vertical], 4)

    }
}

struct HelpParagraph: View {
    var bodyText: String

    var body: some View {
        Text(LocalizedStringKey(bodyText))
            .frame(maxWidth: .infinity, alignment: .leading)
            .multilineTextAlignment(.leading)
            .padding([.top], 2)
            .padding([.bottom], 8)
    }
}

struct HelpKeypad: View {
    var keypad: KeypadModel

    var body: some View {
        let helpItems = createHelpItems(keypad)
        VStack {
            ForEach(helpItems) { item in
                HelpItemView(item: item)
            }
        }
    }
}

struct HelpItemView: View {
    var item: HelpItem

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            Text(item.calcFunc)
                .padding([.all], 10)
                .frame(minWidth: 80)
                .background(Styles2.keyBackgroundColor)
                .foregroundColor(item.funcColor)
            VStack(alignment: .leading) {
                Text(LocalizedStringKey(item.helpTextKey))
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding([.bottom], 10)
    }
}

struct HelpItem: Identifiable {
    typealias ID = String
    var id: String

    let calcFunc: String
    let funcColor: Color
    let helpTextKey: String

    init(calcFunc: String, funcColor: Color, helpTextKey: String) {
        self.id = calcFunc
        self.calcFunc = calcFunc
        self.funcColor = funcColor
        self.helpTextKey = helpTextKey
    }
}

private func createHelpItems(_ keypad: KeypadModel) -> [HelpItem] {
    keypad.keyRows.flatMap { row in
        row.keys
            .flatMap { key in
                [keyFuncToHelpItem(key.op?.symbol,
                                   key.mainTextColor?.asColor() ?? Styles2.keypadMainTextColor,
                                   key.op?.helpTextKey),
                 keyFuncToHelpItem(key.opMod1?.symbol, Styles2.mod1TextColor, key.opMod1?.helpTextKey),
                 keyFuncToHelpItem(key.opMod2?.symbol, Styles2.mod2TextColor, key.opMod2?.helpTextKey)]
            }
            .compactMap { hi in hi }
    }
}

private func keyFuncToHelpItem(_ symbol: String?,
                               _ color: Color,
                               _ helpTextKey: String?) -> HelpItem? {
    if let symbol = symbol,
       let helpTextKey = helpTextKey,
       !symbol.isEmpty,
       !helpTextKey.isEmpty {
        HelpItem(calcFunc: symbol,
                 funcColor: color,
                 helpTextKey: helpTextKey)
    } else {
        nil
    }
}

#Preview("HelpView") {
    HelpView(keypadModel: BasicKeypadModel())
}
