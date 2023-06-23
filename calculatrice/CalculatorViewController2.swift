import UIKit
import SwiftUI

class CalculatorViewController2: UIHostingController<CalculatorMain> {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    init() {
        let view = CalculatorMain()
        super.init(rootView: view)
    }

    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
