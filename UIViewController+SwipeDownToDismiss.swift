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
        /// pan gesture stopped, it did not meet the required conditionas. view is reverted to its original transform
        case cancelled
    }
    
    typealias SwipeDownStatusChange = (SwipeDownStatus) -> Void
    
    /// if true, view's y-axis swipe offset is half the true offset (appears to be stickier to top)
    let isSticky: Bool
    /// if true, the view fades relative to the y-axis offset
    let shouldViewFade: Bool
    /// duration of when view transform to original position or if out of bounds (swipe down action triggered)
    let animationDuration: TimeInterval
    /// minimum velocity required to trigger swipe down action
    let minimumVelocityToDismiss: CGFloat
    /// minimum vertical offset, in terms of percent of the screen's height, required to trigger swipe down action. values range: 0.0 - 0.9
    let minimumScreenPercentageOffsetToDismiss: CGFloat
    /// closure that gets called when there is a `SwipeDownStatus` change
    let statusChange: SwipeDownStatusChange
    
    init(
        isSticky: Bool,
        shouldViewFade: Bool,
        animationDuration: TimeInterval = 0.2,
        minimumVelocityToDismiss: CGFloat = 1300,
        minimumScreenPercentageOffsetToDismiss: CGFloat = 0.30,
        statusChange: @escaping SwipeDownStatusChange
    ) {
        self.isSticky = isSticky
        self.shouldViewFade = shouldViewFade
        self.animationDuration = animationDuration
        self.minimumVelocityToDismiss = minimumVelocityToDismiss
        self.minimumScreenPercentageOffsetToDismiss = min(max(0, minimumScreenPercentageOffsetToDismiss), 0.9)
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
        // if no configuration, something is wrong, thus abort
        guard let configuration = swipeDownConfiguration else { return }
    
        let viewSize = view.frame.size
    
        /// closure that  transforms the view, as well if to do a fading effect, if needed
        let moveViewVerticallyTo: (CGFloat) -> Void = { [weak self] y in
            let transform = CGAffineTransform(translationX: 0, y: y)
            self?.view.transform = transform
            if configuration.shouldViewFade {
                self?.view.alpha = (viewSize.height - y) / viewSize.height
            }
        }
        
        /// closure to handle moving view to its original position, along with notifying status change with `.cancelled`
        let cancelAndReset: () -> Void = {
            configuration.statusChange(.cancelled)
            UIView.animate(withDuration: configuration.animationDuration, animations: {
                moveViewVerticallyTo(0)
            })
        }
        
        switch panGesture.state {
        case .began, .changed: // move view to follow the pan gesture
            let translation = panGesture.translation(in: view)
            
            // get the adjusted y-axis translation, in case configuration has isSticky true
            let adjustedTranslationY = configuration.adjustVerticalTranslation(translation.y)
            moveViewVerticallyTo(adjustedTranslationY)
            
        case .ended: // decide if far enought to close or fully appear back up
            let translation = panGesture.translation(in: view)
            let velocity = panGesture.velocity(in: view)
            let dismissConditionsMet = (translation.y > viewSize.height * configuration.minimumScreenPercentageOffsetToDismiss) ||
            (velocity.y > configuration.minimumVelocityToDismiss)
            
            if dismissConditionsMet {
                // notify dismiss is initiated
                configuration.statusChange(.initiated)
                
                UIView.animate(withDuration: configuration.animationDuration, animations: {
                    moveViewVerticallyTo(viewSize.height)
                }, completion: { isCompleted in
                    if isCompleted {
                        // notify view is fully dismissed
                        configuration.statusChange(.completed)
                    }
                })
            } else { // reposition view back to top
                cancelAndReset()
            }
            
        default: // undetermined, reposition view back to top
            cancelAndReset()
        }
    }
}
