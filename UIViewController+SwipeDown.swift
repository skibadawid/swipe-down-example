//
//  UIViewController+SwipeDown.swift
//  SwipeDownExtension
//
//  Created by Dawid on 1/29/23.
//

import UIKit

struct SwipeDownConfiguration {
    
    enum SwipeDownStatus {
        /// swipe down action conditions met, view will transform verticallty down
        case initiated
        /// view is completely out of bounds
        case completed
        /// swipe down started but not triggered. view reverted to original transform
        case cancelled
    }
    
    typealias SwipeDownStatusChange = (SwipeDownStatus) -> Void
    
    /// it true, view's y-axis swipe offset is half the true offset (appears to be stickier to top)
    let isSticky: Bool
    /// if true, the view fades relative to the y-axis offset
    let shouldFade: Bool
    /// minimum velocity to trigger swipe down action
    let minimumVelocityToHide: CGFloat
    /// minimum ratio of the screen to
    let minimumScreenRatioToHide: CGFloat
    /// duration of when view transform to original position or if out of bounds (swipe down action triggered)
    let animationDuration: TimeInterval
    /// closure that gets called when there is a `SwipeDownStatus` change
    let statusChange: SwipeDownStatusChange
    
    init(
        isSticky: Bool,
        shouldFade: Bool,
        animationDuration: TimeInterval = 0.2,
        minimumVelocityToHide: CGFloat = 1300,
        minimumScreenRatioToHide: CGFloat = 0.30,
        statusChange: @escaping SwipeDownStatusChange
    ) {
        self.isSticky = isSticky
        self.shouldFade = shouldFade
        self.animationDuration = animationDuration
        self.minimumVelocityToHide = minimumVelocityToHide
        self.minimumScreenRatioToHide = minimumScreenRatioToHide
        self.statusChange = statusChange
    }
    
    /// changes the actual vertical translation in case `configuration.isSticky == true`
    func adjustVerticalTranslation(_ y: CGFloat) -> CGFloat {
        if isSticky {
            return max(0, y/2)
        }
        return max(0, y)
    }
}

// keys used for objc_setAssociatedObject / objc_getAssociatedObject
private var panGestureKey = "ViewController.SwipeDownPanGestureKey"
private var configurationKey = "ViewController.SwipeDownConfigurationKey"

extension UIViewController {
    /// adds a swipe down to dismiss functionality to the view controller's `view`. the vertical offset of the pan will affect the view's alpha
    func addSwipeDownToDismiss(with configuration: SwipeDownConfiguration) {
        removeSwipeDownToDismiss()
        
        let panGestureToAdd = UIPanGestureRecognizer(target: self, action: #selector(onPan))
        view.addGestureRecognizer(panGestureToAdd)
        swipeDownConfiguration = configuration
        panGesture = panGestureToAdd
    }
    
    /// removes a swipe down functionality, if there is one
    func removeSwipeDownToDismiss() {
        panGesture.map { view.removeGestureRecognizer($0) }
        panGesture = nil
        swipeDownConfiguration = nil
    }
}

private extension UIViewController {
    /// `optional` - pan gesture used for swipe down
    var panGesture: UIPanGestureRecognizer? {
        get { getPanGesture() }
        set { setPanGesture(newValue) }
    }
    
    func getPanGesture() -> UIPanGestureRecognizer? {
        objc_getAssociatedObject(self, &panGestureKey) as? UIPanGestureRecognizer
    }
    
    func setPanGesture(_ panGesture: UIPanGestureRecognizer?) {
        objc_setAssociatedObject(self, &panGestureKey, panGesture, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    /// `optional` - configuration for swipe down
    var swipeDownConfiguration: SwipeDownConfiguration? {
        get { getSwipeDownConfiguration() }
        set { setSwipeDownConfiguration(newValue) }
    }
    
    func getSwipeDownConfiguration() -> SwipeDownConfiguration? {
        objc_getAssociatedObject(self, &configurationKey) as? SwipeDownConfiguration
    }
    
    func setSwipeDownConfiguration(_ configuration: SwipeDownConfiguration?) {
        objc_setAssociatedObject(self, &configurationKey, configuration, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    @objc func onPan(_ panGesture: UIPanGestureRecognizer) {
        // if no configuration, something is wrong, abort
        guard let configuration = swipeDownConfiguration else { return }
        
        let viewSize = view.frame.size
        let moveViewVerticallyTo: (CGFloat) -> Void = { [weak self] y in
            let transform = CGAffineTransform(translationX: 0, y: y)
            self?.view.transform = transform
            if configuration.shouldFade {
                self?.view.alpha = (viewSize.height - y) / viewSize.height
            }
        }
        let cancelAndReset: () -> Void = {
            configuration.statusChange(.cancelled)
            UIView.animate(withDuration: configuration.animationDuration, animations: {
                moveViewVerticallyTo(0)
            })
        }
        
        switch panGesture.state {
        case .began, .changed: // move view to follow the finger
            let translation = panGesture.translation(in: view)
            let adjustedTranslationY = configuration.adjustVerticalTranslation(translation.y)
            moveViewVerticallyTo(adjustedTranslationY)
            
        case .ended: // decide if far enought to close or fully appear back up
            let translation = panGesture.translation(in: view)
            let velocity = panGesture.velocity(in: view)
            let isClosing = (translation.y > viewSize.height * configuration.minimumScreenRatioToHide) ||
            (velocity.y > configuration.minimumVelocityToHide)
            
            if isClosing { // move the view below completely and trigger completion handler
                // notify dismiss is initiated
                configuration.statusChange(.initiated)
                
                UIView.animate(withDuration: configuration.animationDuration, animations: {
                    moveViewVerticallyTo(viewSize.height)
                }, completion: { isCompleted in
                    if isCompleted {
                        // notify dismiss is complete
                        configuration.statusChange(.completed)
                    }
                })
            } else { // reposition view back to top
                cancelAndReset()
            }
            
        default: // undetermined, make it fully appear
            cancelAndReset()
        }
    }
}
