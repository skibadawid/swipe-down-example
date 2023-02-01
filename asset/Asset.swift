//
//  Asset.swift
//  SwipeDownExtension
//
//  Created by Dawid on 1/29/23.
//

import UIKit

enum Asset: String, CaseIterable {
    case bubbles
    case building
    case flower
    case sticker
    case sunset
}

extension Asset {
    static var random: Asset {
        Asset.allCases.randomElement() ?? .bubbles
    }
    
    var image: UIImage? {
        UIImage(named: rawValue)
    }
}
