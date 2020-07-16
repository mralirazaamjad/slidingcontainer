//
//  SlidingContainer.swift
//  DahdTeam
//
//  Created by Muhammad Hassan on 2020-05-14.
//  Copyright © 2020 Muhammad Hassan. All rights reserved.
//

import UIKit

public protocol SlidingContainerDelegate: AnyObject {
    func container(_ container: SlidingContainerProtocol, didUpdate contentHeight: CGFloat)
}

public protocol SlidingContainerProtocol: AnyObject {
    /// Instance that conforms to SlidingContainerDelegate
    var delegate: SlidingContainerDelegate? { get set }
    
    /// Callback, that will be triggered, once container is hidden
    var onDismiss: (() -> Void)? { get set }
    
    /// Property to enable disable tap geature. Default is true.
    /// Make sure to set this variable afte the view is displayed.
    /// For eg:
    ///     viewController1.present(viewController2, animated: true, completion: {
    ///        container.enableTapGesture = false
    ///     })
    ///
    var enableTapGesture: Bool { get set }
    
    /// This method would configure background overlay alpha
    ///
    /// - Parameter bgOverlayAlpha: CGFloat value from 0 to 1
    func setBgOverlay(alpha: CGFloat)
    
    /// This method will constraint all content to be equal or greater than provided value
    ///
    /// - Parameter minimumHeight: CGFloat value
    func set(minimumHeight: CGFloat)
    
    /// This method will hide control, that is responsible for dragging whole container down (to close it).
    func hidePanGestureControl()
    
    /// This method will embed instance of UIViewController to container.
    /// Please make sure, that UIView of provided UIViewController has height <= Screen.bounds.height - 20.
    /// Otherwise, there will be constraints issue
    ///
    /// - Parameter controller: instance of UIViewController
    func embed(_ controller: UIViewController)
    
    /// This method will embed instance of UIView to container.
    /// Please make sure, that provided UIView has height <= Screen.bounds.height - 20.
    /// Otherwise, there will be constraints issue
    ///
    /// - Parameter controller: instance of UIView
    func embed(_ view: UIView)
    
    /// This method will hide container animated
    func hide()
    
    /// This func will show close button in the right top corner of the container
    func showCloseBtn()
    
    /// This func will assign preffered background color to the container view
    ///
    /// - Parameter bgColor: instance of UIColor
    func set(_ prefferedBgColor: UIColor)
}

/// This is generic component, that should be used to show different content,
/// in container, that pops up from the bottom.
class SlidingContainer: BaseSlidingController {
    
    @IBOutlet private weak var bgOverlay: UIView?
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var containerPlaceholder: UIView!
    @IBOutlet private weak var closeButton: UIButton!
    
    @IBOutlet private weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var bottomConstraint: NSLayoutConstraint?
    @IBOutlet private weak var topConstraint: NSLayoutConstraint?
    
    @IBOutlet private weak var tapGestureRecognizer: UITapGestureRecognizer!
    @IBOutlet private weak var panGestureRecognizer: UIPanGestureRecognizer!
    
    private var embeddedView: UIView?
    private var embeddedViewController: UIViewController?
    
    private var panGestureControlIsHidden: Bool = false
    private var initialPoint: CGPoint?
    private var preconfiguredBgOverlayAlpha: CGFloat?
    private var preconfiguredHeight: CGFloat?
    private var isCloseButtonHidden: Bool = true
    private var prefferedBgColor: UIColor = .white
    
    public var onDismiss: (() -> Void)?
    public weak var delegate: SlidingContainerDelegate?
    public var containerBackgroundColor: UIColor = .white {
        didSet {
            containerView?.backgroundColor = containerBackgroundColor
        }
    }
    
    public var enableTapGesture = true {
        didSet {
            if self.tapGestureRecognizer != nil {
                self.tapGestureRecognizer.isEnabled = enableTapGesture
            }
        }
    }
    
    public init() {
        super.init(bundle: Bundle.main)
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        bgOverlay?.alpha = preconfiguredBgOverlayAlpha ?? 0
        containerView?.backgroundColor = containerBackgroundColor
        bottomConstraint?.priority = .defaultLow
        topConstraint?.priority = .defaultHigh
        closeButton.isHidden = isCloseButtonHidden
        
        prepareContainer()
        preparedEmbededViews()
        registerKeyboardEvents()
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        show()
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        delegate?.container(self, didUpdate: containerView.frame.height)
    }
    deinit { unregisterKeyboardEvents() }
    
    // MARK: - Preparations
    private func prepareContainer() {
        panGestureRecognizer.isEnabled = !panGestureControlIsHidden
        
        containerView.layer.cornerRadius = 8
        containerView.clipsToBounds = true
        
        containerView.backgroundColor = prefferedBgColor
    }
    
    /// convert subview frame into superview frame
    /// - Parameter subViewframe: frame of a subview
    public func frameOf(subViewframe: CGRect) -> CGRect {
        guard let embeddedView = embeddedViewController?.view else { return CGRect.zero }
        
        return embeddedView.convert(subViewframe, to: view)
    }
    
    private func preparedEmbededViews() {
        if let embeddedView = embeddedView {
            containerPlaceholder.addAndFill(embeddedView)
        } else if let embeddedViewController = embeddedViewController {
            embed(childViewController: embeddedViewController, to: containerPlaceholder)
        } else {
            preconditionFailure("This should never happen. SlidingContainer can't be created without embedded view")
        }
    }
    
    @IBAction private func onClose(_ sender: Any) {
        hide()
    }
    
    // MARK: - Private actions
    @IBAction private func onTapOutside(_ sender: Any) {
        hide()
    }
    
    @IBAction private func onGestureAction(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began, .possible:
            initialPoint = gesture.translation(in: view)
        case .changed:
            let point = gesture.translation(in: view)
            
            guard let initialPoint = initialPoint else { return }
            let diffY = point.y - initialPoint.y
            
            // We restrict swipe up action. User can only drag down this component.
            containerView.transform = diffY > 0 ? CGAffineTransform(translationX: 0, y: diffY) : .identity
            self.updateBgOverlay(alpha: 1 - (diffY / containerView.bounds.height))
        case .ended, .cancelled, .failed:
            let point = gesture.translation(in: view)
            
            guard let initialPoint = initialPoint else { return }
            let diffY = point.y - initialPoint.y
            let middleY = containerView.height / 2
            
            // Depending where gesture stops, we hide or show back container
            diffY > middleY ? hide() : show()
            
            self.initialPoint = nil
        default:
            break
        }
    }
    
    private func show() {
        bottomConstraint?.priority = UILayoutPriority(rawValue: 999)
        topConstraint?.priority = .defaultLow
        
        if let preconfiguredHeight = preconfiguredHeight {
            heightConstraint.constant = preconfiguredHeight
            heightConstraint.priority = UILayoutPriority(rawValue: 999)
        }
        
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       options: .beginFromCurrentState,
                       animations: {
                        self.containerView.transform = .identity
                        self.updateBgOverlay(alpha: 1)
                        self.view.layoutIfNeeded()
        },
                       completion: nil)
    }
    
    private func updateBgOverlay(alpha: CGFloat) {
        guard preconfiguredBgOverlayAlpha == nil else { return }
        bgOverlay?.alpha = alpha
    }
}

// MARK: - SlidingContainerProtocol methods
extension SlidingContainer: SlidingContainerProtocol {
    public func set(_ prefferedBgColor: UIColor) {
        self.prefferedBgColor = prefferedBgColor
    }
    
    public func set(minimumHeight: CGFloat) {
        preconfiguredHeight = minimumHeight
    }
    
    public func setBgOverlay(alpha: CGFloat) {
        preconfiguredBgOverlayAlpha = alpha
    }
    
    public func hidePanGestureControl() {
        panGestureControlIsHidden = true
    }
    
    public func embed(_ controller: UIViewController) {
        embeddedViewController = controller
    }
    
    public func embed(_ view: UIView) {
        embeddedView = view
    }
    
    public func hide() {
        bottomConstraint?.priority = .defaultLow
        topConstraint?.priority = .defaultHigh
        heightConstraint?.priority = .defaultLow
        
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       options: .beginFromCurrentState,
                       animations: {
                        self.updateBgOverlay(alpha: 0)
                        self.view.layoutIfNeeded()
        },
                       completion: { _ in
                        
                        if self.parent == nil {
                            self.dismiss(animated: false, completion: self.onDismiss)
                        } else {
                            self.removeFromParentController()
                            self.onDismiss?()
                        }
        })
    }
    
    public func showCloseBtn() {
        isCloseButtonHidden = false
    }
}

// MARK: Keybaord Handling
extension SlidingContainer {
    
    /// Register's keyboard hide and show events
    private func registerKeyboardEvents() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    private func unregisterKeyboardEvents() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
            let rate = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber {
            let keyboardSize = keyboardFrame.size
            
            // Get Bottom margin from device
            let bottomToDevice: CGFloat = UIScreen.main.bounds.size.height - containerPlaceholder.convert(containerPlaceholder.bounds, to: nil).maxY
            let heightBottomConstraint = keyboardSize.height - bottomToDevice
            
            // Only set constraint height if height needs to be increased i.e keyboard size increased
            guard heightBottomConstraint > bottomConstraint?.constant ?? 0 else { return }
            
            bottomConstraint?.constant = heightBottomConstraint
            UIView.animate(withDuration: rate.doubleValue, animations: {
                let view = self.parent?.view ?? self.view
                view?.layoutIfNeeded()
            })
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        var animationDuration: Double = 0.3
        if let rate = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber {
            animationDuration = rate.doubleValue
        }
        
        // Set bottom constraint to default which is zero
        bottomConstraint?.constant = 0
        UIView.animate(withDuration: animationDuration, animations: {
            let view = self.parent?.view ?? self.view
            view?.layoutIfNeeded()
        })
    }
}
