//
//  UIViewExtension.swift
//  DahdTeam
//
//  Created by Muhammad Hassan on 2020-05-14.
//  Copyright © 2020 Muhammad Hassan. All rights reserved.
//

import UIKit

extension UIView {
    
    class func loadFromXib<T: UIView>() -> T? {
        return Bundle(for: self).loadNibNamed(self.className, owner: nil, options: nil)?.first as? T
    }
    
    var width: CGFloat {
        return frame.size.width
    }
    
    var height: CGFloat {
        return frame.size.height
    }
    
    func setHeightAnchor() {
        heightAnchor.constraint(equalToConstant: height).isActive = true
    }
    
    func setHeight(_ height: CGFloat) {
        var newFrame = frame
        newFrame.size.height = height
        frame = newFrame
    }
    
    /// This method will embed a provided subview, with constraints
    ///
    /// - Parameter subview: Target subview to embed
    func addAndFill(_ subview: UIView) {
        subview.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(subview)
        
        subview.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
        subview.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor).isActive = true
        subview.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor).isActive = true
        subview.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor).isActive = true
    }
    
    /// This method will embed a provided subview, with constraints
    ///
    /// - Parameter subview: Target subview to embed
    func addSubView(_ subview: UIView, viewBounds: CGRect = .zero) {
        subview.frame = viewBounds
        addWithAnimation(subview: subview)
    }
    
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }

    func roundCorners(_ corners: CACornerMask, radius: CGFloat) {
        self.layer.cornerRadius = radius
        self.layer.maskedCorners = corners
    }
    
    func addWithAnimation(subview: UIView) {
        UIView.transition(with: self, duration: 0.25, options: [.transitionCrossDissolve], animations: {
          self.addSubview(subview)
        }, completion: nil)
    }
    
    func removeWithAnimation(subview: UIView) {
        UIView.transition(with: self, duration: 0.25, options: [.transitionCrossDissolve], animations: {
          subview.removeFromSuperview()
        }, completion: nil)
    }
    
    func setViewBorder(borderColor: UIColor, cornerRadius: CGFloat, borderWidth: CGFloat) {
        self.clipsToBounds = true
        self.layer.cornerRadius = cornerRadius
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = borderColor.cgColor
    }
}

public extension UIView {

    /// Border color of view; also inspectable from Storyboard.
    @IBInspectable var borderColor: UIColor? {
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }

        set {
            guard let color = newValue else {
                layer.borderColor = nil
                return
            }

            layer.borderColor = color.cgColor
        }
    }

    /// Border width of view; also inspectable from Storyboard.
    @IBInspectable var borderWidth: CGFloat {
        get { return layer.borderWidth }
        set { layer.borderWidth = newValue }
    }

    /// Corner radius of view; also inspectable from Storyboard.
    @IBInspectable var cornerRadius: CGFloat {
        get { return layer.cornerRadius }

        set {
            layer.masksToBounds = true
            layer.cornerRadius = newValue
        }
    }

    func dropShadow(of color: UIColor = .lightGray) {
        addShadow(ofColor: color, radius: 3, offset: CGSize(width: 0.5, height: 0.5), opacity: 1.0)
    }

    /// Add shadow to view.
    ///
    /// - Parameters:
    ///   - color: shadow color (default is #137992).
    ///   - radius: shadow radius (default is 3).
    ///   - offset: shadow offset (default is .zero).
    ///   - opacity: shadow opacity (default is 0.5).
    func addShadow(
        ofColor color: UIColor = .black,
        radius: CGFloat = 3,
        offset: CGSize = .zero,
        opacity: Float = 0.5)
    {
        layer.shadowColor = color.cgColor
        layer.shadowRadius = radius
        layer.shadowOffset = offset
        layer.shadowOpacity = opacity
        layer.masksToBounds = false
    }
}
