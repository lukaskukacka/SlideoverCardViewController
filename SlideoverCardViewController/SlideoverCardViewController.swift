//
//  ContainerViewController.swift
//  SlideoverCardViewController
//
//  Created by Lukas Kukacka on 31/08/2019.
//  Copyright © 2019 Lukas Kukacka. All rights reserved.
//

import UIKit

public protocol SlideoverCardViewControllerChild where Self: UIViewController {

    var collapsedHeight: CGFloat { get }

}

public class SlideoverCardViewController: UIViewController {

    public var topViewController: SlideoverCardViewControllerChild {
        didSet {
            self.setUpChildViewController(old: oldValue, new: self.topViewController, in: self.topContainerView)
        }
    }
    public var bottomViewController: SlideoverCardViewControllerChild {
        didSet {
            self.setUpChildViewController(old: oldValue, new: self.bottomViewController, in: self.bottomContainerView)
        }
    }

    public private(set) lazy var dragHandleViewPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.handleDragHandlePan(_:)))

    public var dragHandleView: UIView? {
        didSet {
            oldValue?.removeGestureRecognizer(self.dragHandleViewPanGestureRecognizer)
            self.dragHandleView?.isUserInteractionEnabled = true
            self.dragHandleView?.addGestureRecognizer(self.dragHandleViewPanGestureRecognizer)
        }
    }

    private let topContainerView: UIView = SlideoverCardViewController.makeContainerView(identifier: "Top Container View")
    private let bottomContainerView: UIView = SlideoverCardViewController.makeContainerView(identifier: "Bottom Container View")

    private var topContainerHeightConstraint: NSLayoutConstraint!
    private var containersYEdgeConstraint: NSLayoutConstraint { return self.topContainerHeightConstraint }

    private struct Config {
        struct TouchHandling {
            static let minFlickVelocityToSwitchState: CGFloat = 100
        }
        struct Animation {
            static let expandSnappingDuration: TimeInterval = 0.4
        }
    }

    init(topViewController: SlideoverCardViewControllerChild, bottomViewController: SlideoverCardViewControllerChild) {
        self.topViewController = topViewController
        self.bottomViewController = bottomViewController
        super.init(nibName: nil, bundle: nil)
    }

    public init() {
        self.topViewController = EmptyChild()
        self.bottomViewController = EmptyChild()
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        self.topViewController = EmptyChild()
        self.bottomViewController = EmptyChild()
        super.init(coder: aDecoder)
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        self.setUpContainerViews()
        self.setUpChildViewController(old: self.topViewController, new: self.topViewController, in: self.topContainerView)
        self.setUpChildViewController(old: self.bottomViewController, new: self.bottomViewController, in: self.bottomContainerView)
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if !self.dragHandleViewPanGestureRecognizer.isTouchDown {
            self.snapToExpandedStateBasedOnCurrentPosition()
        }
    }
}

// MARK: Public interface

public extension SlideoverCardViewController {

    func expand(to newExpandedChild: SlideoverCardViewControllerChild, animated: Bool = false) {
        self._expand(to: newExpandedChild, animated: animated)
    }

    func expandTop(animated: Bool = false) {
        self.expand(to: self.topViewController, animated: animated)
    }

    func expandBottom(animated: Bool = false) {
        self.expand(to: self.bottomViewController, animated: animated)
    }


}

// MARK: Helpers

private extension SlideoverCardViewController {

    func containerView(for child: SlideoverCardViewControllerChild) -> UIView {
        assert(child == self.topViewController || child == self.bottomContainerView)
        if child == self.topViewController {
            return self.topContainerView
        } else {
            return self.bottomContainerView
        }
    }
}

// MARK: View's setup

private extension SlideoverCardViewController {

    static func makeContainerView(identifier: String) -> UIView {
        let view = UIView()
        view.accessibilityIdentifier = identifier
        view.backgroundColor = .clear
        return view
    }

    func setUpContainerViews() {
        for containerView in [self.topContainerView, self.bottomContainerView] {
            containerView.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(containerView)
        }

        self.topContainerHeightConstraint = self.topContainerView.heightAnchor.constraint(equalToConstant: self.topViewController.collapsedHeight)

        NSLayoutConstraint.activate([
            self.topContainerView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.topContainerView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            self.topContainerView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            self.topContainerHeightConstraint,

            self.bottomContainerView.topAnchor.constraint(equalTo: self.topContainerView.bottomAnchor),
            self.bottomContainerView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            self.bottomContainerView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            self.bottomContainerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
            ])
    }

    func setUpChildViewController(old: SlideoverCardViewControllerChild, new: SlideoverCardViewControllerChild, in containerView: UIView) {
        old.willMove(toParent: nil)
        old.view.removeFromSuperview()
        old.removeFromParent()

        self.addChild(new)
        self.view.addSubview(new.view)
        new.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            new.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            new.view.leftAnchor.constraint(equalTo: containerView.leftAnchor),
            new.view.rightAnchor.constraint(equalTo: containerView.rightAnchor),
            new.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
            ])
        new.didMove(toParent: self)
    }
}

// MARK: User interaction

private extension SlideoverCardViewController {

    @objc
    func handleDragHandlePan(_ gesture: UIPanGestureRecognizer) {
        func move(with gesture: UIPanGestureRecognizer) {
            let translation = gesture.translation(in: self.view)
            self.containersYEdgeConstraint.constant += translation.y
            self.view.layoutIfNeeded()
            gesture.setTranslation(.zero, in: self.view)
        }

        switch gesture.state {
        case .began, .changed:
            move(with: gesture)
        case .ended:
            move(with: gesture)
            let velocity = gesture.velocity(in: self.view)
            let yVelocity = velocity.y

            if self.isConfainersYEdgePositionedInTopHalf &&
                yVelocity > 0 &&
                Config.TouchHandling.minFlickVelocityToSwitchState < abs(yVelocity) {
                // Top half & swiping down fast -> flick down
                self._expand(to: self.bottomViewController, animated: true, velocity: velocity)
            }
            else if !self.isConfainersYEdgePositionedInTopHalf &&
                yVelocity < 0 &&
                Config.TouchHandling.minFlickVelocityToSwitchState < abs(yVelocity) {
                // Bottom half & swiping up fast -> flick down
                self._expand(to: self.topViewController, animated: true, velocity: velocity)
            } else {
                // Swiping slow -> snap to closer state
                self.snapToExpandedStateBasedOnCurrentPosition(animated: true, velocity: velocity)
            }
        case .cancelled, .possible, .failed:
            break
        @unknown default:
            break
        }
    }
}

// MARK: Layout

private extension SlideoverCardViewController {

    var topContainerCollapsedMaxY: CGFloat {
        return self.topViewController.collapsedHeight
    }

    var bottomContainerCollapsedMinY: CGFloat {
        return self.view.bounds.height - self.bottomViewController.collapsedHeight
    }

    var verticalCollapsedStatesMidY: CGFloat {
        return round((self.topContainerCollapsedMaxY + self.bottomContainerCollapsedMinY) / 2)
    }

    var isConfainersYEdgePositionedInTopHalf: Bool {
        return self.containersYEdgeConstraint.constant < self.verticalCollapsedStatesMidY
    }

    func snapToExpandedStateBasedOnCurrentPosition(animated: Bool = false, velocity: CGPoint? = nil) {
        if self.containersYEdgeConstraint.constant < self.verticalCollapsedStatesMidY {
            self._expand(to: self.topViewController, animated: animated, velocity: velocity)
        } else {
            self._expand(to: self.bottomViewController, animated: animated, velocity: velocity)
        }
    }

    func layoutToExpand(_ newExpandedChild: SlideoverCardViewControllerChild) {
        self.containersYEdgeConstraint.constant = self.containersYEdgeConstraintConstant(whileExpandedTo: newExpandedChild)
    }

    func containersYEdgeConstraintConstant(whileExpandedTo expandedChild: SlideoverCardViewControllerChild) -> CGFloat {
        return (expandedChild == self.topViewController) ? self.topContainerCollapsedMaxY : self.bottomContainerCollapsedMinY
    }

    func yDistanceFromCurrentStateToExpandedState(to newExpandedChild: SlideoverCardViewControllerChild) -> CGFloat {
        let currentY = self.containersYEdgeConstraint.constant
        let finalY = self.containersYEdgeConstraintConstant(whileExpandedTo: newExpandedChild)
        return finalY - currentY
    }

    func _expand(to newExpandedChild: SlideoverCardViewControllerChild, animated: Bool = false, velocity: CGPoint? = nil) {
        assert(newExpandedChild == self.topViewController || newExpandedChild == self.bottomViewController, "\(newExpandedChild) is not presented by \(self). Can expand only to top or bottom view controller")

        let initialVelocity: CGFloat? = {
            guard let velocity = velocity else { return nil}
            let distanceToAnimate = self.yDistanceFromCurrentStateToExpandedState(to: newExpandedChild)
            return abs(velocity.y / distanceToAnimate)
        }()

        let animation: SpringAnimation = (
        {
            self.layoutToExpand(newExpandedChild)
            self.view.layoutIfNeeded()
        },
        nil,
        initialVelocity)
        self.execute(animation, using: self.animateExpansitionSnapping(animation:), animated: animated)
    }
}

// MARK: Animations

private typealias SpringAnimation = (animationClosure: () -> Void, completionClosure: ((Bool) -> Void)?, initialVelocity: CGFloat?)
private typealias SpringAnimationFunction = (SpringAnimation) -> Void

private extension SlideoverCardViewController {

    func execute(_ animation: SpringAnimation, using animationFunction: SpringAnimationFunction, animated: Bool) {
        if animated {
            animationFunction(animation)
        } else {
            animation.animationClosure()
            animation.completionClosure?(true)
        }
    }

    func animateExpansitionSnapping(animation: SpringAnimation) {
        UIView.animate(withDuration: Config.Animation.expandSnappingDuration,
                       delay: 0,
                       usingSpringWithDamping: 0.9,
                       initialSpringVelocity: animation.initialVelocity ?? 1,
                       options: [.beginFromCurrentState, .curveEaseInOut],
                       animations: animation.animationClosure,
                       completion: animation.completionClosure)
    }
}

// MARK: - Helper classes

private class EmptyChild: UIViewController, SlideoverCardViewControllerChild {
    let collapsedHeight: CGFloat = 100
}

// MARK: - Extensions

private extension UIPanGestureRecognizer {

    var isTouchDown: Bool {
        switch self.state {
        case .began, .changed, .ended:
            return true
        default:
            return false
        }
    }
}
