import UIKit
import SnapKit

class CalculatorViewController: UIViewController {
    private let stack = Stack()
    private let keypadModel = BasicKeypadModel()
    private let calculatorMode = CalculatorMode()
    private let keypadView = KeypadView(frame: .zero)
    private let display = Display(frame: .zero)
    private var window: UIWindow {
        SceneDelegate.window!
    }
    private static let displayPortion = 1.0/3.8

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()

        display.inputDisplay.onPaste = { [weak self] text in self?.onPaste(text) }

        keypadView.onKeyPressed = { [weak self] key in self?.onKeyPressed(key) }
        keypadView.render(keypadModel)
        updateViews()
    }

    private func setupLayout() {
        view.addSubview(display)
        view.addSubview(keypadView)

        display.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(window.safeAreaInsets.top + Styles.margin)
            make.leading.trailing.equalToSuperview().inset(Styles.margin)
            make.height.equalToSuperview().multipliedBy(Self.displayPortion)
        }

        keypadView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(Styles.margin)
            make.top.equalTo(display.snp.bottom).offset(Styles.keypadMargin)
            make.bottom.equalToSuperview().inset(window.safeAreaInsets.bottom + Styles.margin)
        }
    }

    private func onKeyPressed(_ key: Key) {
        stack.selectedId = display.stackDisplay.selectedItem?.id ?? -1
        do {
            try key.activeOp(calculatorMode, stack)
            if key.resetModAfterClick {
                calculatorMode.resetMods()
            }
        } catch {
            showError()
        }
        updateViews()
    }

    private func updateViews() {
        if stack.input.isEmpty {
            display.inputDisplay.text = " "
        } else {
            display.inputDisplay.text = stack.input.value.stringValue
        }

        display.stackDisplay.setStack(stack.content)
        display.statusRow.setMode(calculatorMode)
    }

    private func onPaste(_ text: String?) {
        guard let text = text else { return }
        stack.input.paste(text)
        updateViews()
    }

    private func showError() {
        let alert = UIAlertController(title: "Error",
                                      message: "Invalid calculation",
                                      preferredStyle: .alert)
        let ok = UIAlertAction(title: "Ok", style: .default)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
}
