//
//  UIViewControllerExt.swift
//  DahdTeam
//
//  Created by Muhammad Hassan on 2020-05-14.
//  Copyright © 2020 Muhammad Hassan. All rights reserved.
//

import UIKit

// MARK: - UIViewController Extension's
extension UIViewController {
    // Not using static as it wont be possible to override to provide custom storyboardID then
    class var storyboardId: String {
        return "\(self)"
    }

    static func loadVCFromNib() -> Self {
        func instantiateFromNib<T: UIViewController>() -> T {
            return T.init(nibName: String(describing: T.self), bundle: nil)
        }

        return instantiateFromNib()
    }
    
    /// This method provides a convinient way to add child view controller
    ///
    /// - Parameters:
    ///   - childViewController: Target child controller
    ///   - placeholder: Target placeholder
    ///   - frame: Target frame to add child controller. If not provided
    ///            placeholder.bounds will be used as frame
    func add(childViewController: UIViewController, to placeholder: UIView, frame: CGRect? = nil) {
        childViewController.willMove(toParent: self)
        self.addChild(childViewController)

        let targetFrame = frame ?? placeholder.bounds
        childViewController.view.frame = targetFrame
        placeholder.addSubview(childViewController.view)

        childViewController.didMove(toParent: self)
    }
    
    /// This method provides a convinient way to embed child view controller, and it's view with constraints
    ///
    /// - Parameters:
    ///   - childViewController: Target child controller
    ///   - placeholder: Target placeholder
    func embed(childViewController: UIViewController, to placeholder: UIView) {
        childViewController.willMove(toParent: self)
        self.addChild(childViewController)

        placeholder.addAndFill(childViewController.view)
        placeholder.backgroundColor = .clear

        childViewController.didMove(toParent: self)
    }

    func removeFromParentController() {
        self.willMove(toParent: nil)
        self.view.removeFromSuperview()
        self.removeFromParent()
        self.didMove(toParent: nil)
    }
    
//    static func instantiate(fromStoryboard storyboard: AppStoryboard) -> Self {
//        return storyboard.viewController(viewControllerClass: self)
//    }
//    
    func readJSONFromFile(fileName: String) -> [String: Any]? {
        var json: [String: Any]?
        if let path = Bundle.main.path(forResource: fileName, ofType: "json") {
            do {
                let fileUrl = URL(fileURLWithPath: path)
                // Getting data from JSON file using the file URL
                let data = try Data(contentsOf: fileUrl, options: .mappedIfSafe)
                json = try? JSONSerialization.jsonObject(with: data) as? [String : Any]
            } catch {
                // Handle error here
            }
        }
        return json
    }
    
    func topMostViewController() -> UIViewController {
        
        if let presented = self.presentedViewController {
            return presented.topMostViewController()
        }
        
        if let navigation = self as? UINavigationController {
            return navigation.visibleViewController?.topMostViewController() ?? navigation
        }
        
        if let tab = self as? UITabBarController {
            return tab.selectedViewController?.topMostViewController() ?? tab
        }
        
        return self
    }
    
    /**
     *  Height of status bar + navigation bar (if navigation bar exist)
     */

    var topbarHeight: CGFloat {
        return UIApplication.shared.statusBarFrame.size.height + (self.navigationController?.navigationBar.frame.height ?? 0.0)
    }

    func textFieldDefaultSettings(fields: [UITextField],
                                cornerRadius: CGFloat = 0,
                                borderWidth: CGFloat = 0,
                                borderColor: UIColor = .white) {

        fields.forEach {

            // Left Padding
            $0.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 40))
            $0.leftViewMode = .always

            // Border
            $0.clipsToBounds = true
            $0.layer.cornerRadius = cornerRadius
            $0.layer.borderWidth = borderWidth
            $0.layer.borderColor = borderColor.cgColor
        }
    }
}

extension UINavigationController {
    var rootViewController: UIViewController? {
        return viewControllers.first
    }
}
