import SwiftUI

struct HelpView: View {
    @Binding var showingHelp: Bool

    var showGeneralHelpText: Bool = true

    var keypadModel: KeypadModel

    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Spacer()
                    Button("Close") { showingHelp = false }
                }
                if showGeneralHelpText {
                    HelpTitle(title: "HelpTitle")
                    HelpParagraph(bodyText: "GenericHelpBody")
                }
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
        .padding(.top, 4)
    }
}

struct HelpItemView: View {
    var item: HelpItem

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            Text(item.calcFunc)
                .padding([.all], 10)
                .frame(minWidth: 80)
                .background(Styles.keyBackgroundColor)
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
                                   key.mainTextColor ?? Styles.keypadMainTextColor,
                                   key.op?.helpTextKey),
                 keyFuncToHelpItem(key.opMod1?.symbol, Styles.mod1TextColor, key.opMod1?.helpTextKey),
                 keyFuncToHelpItem(key.opMod2?.symbol, Styles.mod2TextColor, key.opMod2?.helpTextKey)]
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
    struct HelpViewPreview: View {

        @State var showingHelp: Bool = false

        var body: some View {
            HelpView(showingHelp: $showingHelp, keypadModel: BasicKeypadModel())
        }
    }

    return HelpViewPreview()
}

#Preview("HelpForMatrixes") {
    struct HelpViewPreview: View {

        @State var showingHelp: Bool = false

        var body: some View {
            HelpView(showingHelp: $showingHelp,
                     showGeneralHelpText: false,
                     keypadModel: MatrixKeypadModel())
        }
    }

    return HelpViewPreview()
}
