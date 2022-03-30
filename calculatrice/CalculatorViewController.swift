import UIKit
import SnapKit

class CalculatorViewController: UIViewController {
    private let stack = Stack()
    private let keypadModel = BasicKeypadModel()
    private let calculatorMode = CalculatorMode()
    private let keypadView = KeypadView(frame: .zero)
    private let inputDisplay = InputDisplay(frame: .zero)
    private let stackDisplay = StackDisplay(frame: .zero)
    private var window: UIWindow {
        SceneDelegate.window!
    }
    private let margin = 10.0

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        setupLayout()

        inputDisplay.onPaste = { [weak self] text in self?.onPaste(text) }

        keypadView.onKeyPressed = { [weak self] key in self?.onKeyPressed(key) }
        keypadView.render(keypadModel)
        updateViews()
    }

    private func setupLayout() {
        view.addSubview(stackDisplay)
        view.addSubview(inputDisplay)
        view.addSubview(keypadView)

        stackDisplay.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(window.safeAreaInsets.top + margin)
            make.leading.trailing.equalToSuperview().inset(margin)
            make.height.equalToSuperview().dividedBy(4)
        }

        inputDisplay.snp.makeConstraints { make in
            make.top.equalTo(stackDisplay.snp.bottom).offset(margin)
            make.leading.trailing.equalToSuperview().inset(margin)
            make.height.lessThanOrEqualToSuperview().dividedBy(10)
        }

        keypadView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(margin)
            make.top.equalTo(inputDisplay.snp.bottom).offset(margin)
            make.bottom.equalToSuperview().inset(window.safeAreaInsets.bottom + margin)
        }
    }

    private func onKeyPressed(_ key: Key) {
        stack.selectedId = stackDisplay.selectedItem?.id ?? -1
        key.activeOp(calculatorMode)(stack, calculatorMode)
        if key.resetModAfterClick {
            calculatorMode.resetMods()
        }
        updateViews()
    }

    private func updateViews() {
        if stack.input.isEmpty {
            inputDisplay.text = " "
        } else {
            inputDisplay.text = stack.input.value.stringValue
        }

        stackDisplay.setStack(stack.content)
        inputDisplay.setMode(calculatorMode)
    }

    private func onPaste(_ text: String?) {
        guard let text = text else { return }
        stack.input.paste(text)
        updateViews()
    }
}
