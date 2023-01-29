//
//  UIFont_Extension.swift
//  SolanaGallery
//
//  Created by Rastaar Haghi on 5/1/22.
//

import UIKit

extension UIFont {
    static let FONT_FAMILY_NAME = "D-DIN"
    static func primaryFont(size: CGFloat) -> UIFont {
        return UIFont(name: FONT_FAMILY_NAME, size: size)!
    }
}
