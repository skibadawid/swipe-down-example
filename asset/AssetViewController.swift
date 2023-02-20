//
//  AssetViewController.swift
//  SwipeDownExtension
//
//  Created by Dawid on 1/29/23.
//

import UIKit

class AssetViewController: UIViewController {
    private let imageView = UIImageView(frame: .zero)
    
    static var random: AssetViewController {
        AssetViewController(asset: .random)
    }
    
    init(asset: Asset) {
        imageView.image = asset.image
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(imageView)
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            imageView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}
