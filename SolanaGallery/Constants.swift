//
//  Constants.swift
//  SolanaGallery
//
//  Created by Rastaar Haghi on 5/26/22.
//

import Foundation

struct Constants {
    struct UI {
        struct TextField {
            static let CornerRadius = 20.0
        }
        struct Button {
            static let CornerRadius = 20.0
        }
        struct TableView {
            static let CornerRadius = 20.0
        }
    }
    static func constructMagicedenListingUrl(with tokenMint: String) -> URL? {
        let urlString = self.MagicedenListingUrlPrefix + tokenMint
        return URL(string: urlString)
    }
    static let MagicedenListingUrlPrefix = "https://magiceden.io/item-details/"
}
