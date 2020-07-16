//
//  BaseSlidingController.swift
//  DahdTeam
//
//  Created by Muhammad Hassan on 2020-05-14.
//  Copyright © 2020 Muhammad Hassan. All rights reserved.
//

import UIKit

class BaseSlidingController: UIViewController {

    public enum LoadType {
        case programmatically
        case xib
        case xibWith(suffix: String)
    }

    override public var prefersStatusBarHidden: Bool {
        return false
    }

    override open var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // MARK: - Life cycle
    // Pass Bundle.mtCommon to "bundle" in order to load xib files located inside framework
    public init(loadType: LoadType = .xib, bundle: Bundle = .main) {
        var nibName: String

        switch loadType {
        case .programmatically:
            super.init(nibName: nil, bundle: bundle)
            return
        case .xib:
            nibName = type(of: self).className
        case let .xibWith(suffix):
            nibName = type(of: self).className + suffix
        }

        super.init(nibName: nibName, bundle: bundle)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    var visibleViewHeight: CGFloat {
        var height = self.view.bounds.size.height - UIApplication.shared.statusBarFrame.size.height
        height -= self.navigationController?.navigationBar.frame.size.height ?? 0.0
        height -= (self.tabBarController?.tabBar.bounds.size.height ?? 0.0)
        return height
    }
}

extension NSObject {
    class var className: String {
        return String(describing: self)
    }
}
