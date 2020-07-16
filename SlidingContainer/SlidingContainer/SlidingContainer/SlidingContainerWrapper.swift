//
//  SlidingContainerWrapper.swift
//  DahdTeam
//
//  Created by Muhammad Hassan on 2020-05-14.
//  Copyright © 2020 Muhammad Hassan. All rights reserved.
//

import UIKit

public protocol SlidingContainerWrapperProtocol: AnyObject {
    func show(container: SlidingContainerProtocol)
}

class SlidingContainerWrapper: BaseSlidingController {
    private var containersStack: [SlidingContainerProtocol] = []
    private var minimumContentHeight: CGFloat?

    public var onDismiss: (() -> Void)?

    public init() {
        super.init(bundle: Bundle.main)
    }

    required init?(coder aDecoder: NSCoder) {
        return nil
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        self.view.layoutIfNeeded()

        guard let firstContainer = containersStack.first as? UIViewController else { return }
        self.embed(childViewController: firstContainer, to: view)
        view.accessibilityViewIsModal = true
    }

    private func dismissIfNeeded() {
        guard containersStack.count > 0 else { return }

        containersStack.removeLast()

        // Set the top most controller's accessibility elements visible.
        if let controller = containersStack.first as? UIViewController {
            controller.view.accessibilityElementsHidden = false
            UIAccessibility.post(notification: .screenChanged, argument: controller.view)
        }
        guard containersStack.count == 0 else { return }

        self.dismiss(animated: true, completion: nil)
        onDismiss?()
    }
}

// MARK: - SlidingContainerWrapperProtocol methods
extension SlidingContainerWrapper: SlidingContainerWrapperProtocol {
    public func show(container: SlidingContainerProtocol) {

        // As we are adding another controller, so hide the accessibility of current
        // controller on top.
        if let controller = containersStack.first as? UIViewController {
            controller.view.accessibilityElementsHidden = true
            UIAccessibility.post(notification: .screenChanged, argument: controller.view)
        }

        containersStack.append(container)
        container.onDismiss = { [weak self] in self?.dismissIfNeeded() }

        if containersStack.count == 1 {
            container.delegate = self
        } else if containersStack.count > 1 {
            container.setBgOverlay(alpha: 0)
        }
        if let minimumContentHeight = minimumContentHeight {
            container.set(minimumHeight: minimumContentHeight)
        }

        guard self.isViewLoaded, let container = container as? UIViewController else { return }
        self.embed(childViewController: container, to: view)
    }
}

// MARK: - SlidingContainerDelegate methods
extension SlidingContainerWrapper: SlidingContainerDelegate {
    public func container(_ container: SlidingContainerProtocol, didUpdate contentHeight: CGFloat) {
        guard contentHeight > 0 else { return }
        minimumContentHeight = contentHeight
    }
}
