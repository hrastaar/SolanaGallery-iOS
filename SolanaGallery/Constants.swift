//
//  Constants.swift
//  SolanaGallery
//
//  Created by Rastaar Haghi on 5/26/22.
//

import Foundation

struct Constants {
    enum TextField {
        static let CornerRadius = 20.0
    }

    enum Button {
        static let CornerRadius = 20.0
    }

    enum TableView {
        static let CornerRadius = 5.0
    }

    static func getMagicEdenListingUrl(with tokenMint: String) -> URL? {
        let urlString = SolanaGalleryAPI.magicedenListingUrlPrefix + tokenMint
        return URL(string: urlString)
    }

    static func getMagicEdenCollectionUrl(with collectionSymbol: String) -> URL? {
        let urlString = SolanaGalleryAPI.magicedenCollectionUrlPrefix + collectionSymbol
        return URL(string: urlString)
    }
}
