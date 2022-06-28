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
    
    static func getMagicEdenListingUrl(with tokenMint: String) -> URL? {
        let urlString = SolanaGalleryAPI.MagicedenListingUrlPrefix + tokenMint
        return URL(string: urlString)
    }
    
    static func getMagicEdenCollectionUrl(with collectionSymbol: String) -> URL? {
        let urlString = SolanaGalleryAPI.MagicedenCollectionUrlPrefix + collectionSymbol
        return URL(string: urlString)
    }
}
