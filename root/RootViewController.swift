//
//  RootViewController.swift
//  SwipeDownExtension
//
//  Created by Dawid on 1/29/23.
//

import UIKit
import SwiftUI

private enum Constants {
    static let rulerAnimationDuration = 0.4
}

class RootViewController: UIViewController {
    private var rulerViewHostingController: UIHostingController<RulerView>?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        addConfigurationsView()
    }
}

private extension RootViewController {
    func addConfigurationsView() {
        let configurationsView = ConfigurationsView(testAction: { [weak self] configurationsView in
            self?.presentRandomAsset(configurationsView: configurationsView)
        })
        
        let hostingController = UIHostingController(rootView: configurationsView)
        addChild(hostingController)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)

        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostingController.view.leftAnchor.constraint(equalTo: view.leftAnchor),
            hostingController.view.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }
    
    func presentRandomAsset(configurationsView: ConfigurationsView) {
        let navigationController = UINavigationController(rootViewController: AssetViewController.random)
        navigationController.isNavigationBarHidden = true
        let swipeDownConfiguration = SwipeDownConfiguration(
            isSticky: configurationsView.isSticky,
            shouldViewFade: configurationsView.shouldViewFade,
            animationDuration: configurationsView.animationDuration,
            minimumVelocityToDismiss: configurationsView.minimumVelocityToDismiss,
            minimumScreenPercentageOffsetToDismiss: configurationsView.minimumScreenPercentageOffsetToDismiss) { [weak self] state in
                let timeString = DateFormatter.time.string(from: Date())
                switch state {
                case .initiated:
                    print("🏁 \(timeString) : SWIPE DOWN INITIATED")
                    self?.removeRulerView()
                case .completed:
                    print("✅ \(timeString) : SWIPE DOWN COMPLETED")
                    self?.dismiss(animated: true)
                case .cancelled:
                    print("❌ \(timeString) : SWIPE DOWN CANCELLED")
                }
            }
        
        showRulerView()
        navigationController.addSwipeDownToDismiss(with: swipeDownConfiguration)
        navigationController.modalPresentationStyle = .overFullScreen
        present(navigationController, animated: true)
    }
    
    func showRulerView() {
        // if there is already one, abort
        guard rulerViewHostingController == nil else { return }
        
        let hostingController = UIHostingController(rootView: RulerView())
        hostingController.view.alpha = 0
        addChild(hostingController)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)

        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostingController.view.leftAnchor.constraint(equalTo: view.leftAnchor),
            hostingController.view.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
        
        UIView.animate(withDuration: Constants.rulerAnimationDuration) {
            hostingController.view.alpha = 1.0
        }
        rulerViewHostingController = hostingController
    }
    
    func removeRulerView() {
        UIView.animate(withDuration: Constants.rulerAnimationDuration, animations: {
            self.rulerViewHostingController?.view.alpha = 0
        }, completion: { isComplete in
            guard isComplete else { return }
            self.rulerViewHostingController?.view.removeFromSuperview()
            self.rulerViewHostingController?.removeFromParent()
            self.rulerViewHostingController = nil
        })
    }
}

private extension DateFormatter {
    static let time: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss.SSS"
        return dateFormatter
    }()
}
