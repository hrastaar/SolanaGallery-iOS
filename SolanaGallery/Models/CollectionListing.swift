//
//  CollectionListing.swift
//  SolanaGallery
//
//  Created by Rastaar Haghi on 5/27/22.
//

import Foundation

struct CollectionListing: Decodable {
    let tokenMint: String
    let seller: String
    let image: String
    let price: Double
    let moonrank: Int?
    let howrare: Int?
    let collectionSize: Int?
    
    private enum CodingKeys : String, CodingKey {
        case collectionSize = "expectedPieces",
             tokenMint,
             seller,
             image,
             price,
             moonrank,
             howrare
    }
    
    func getMagicedenListingUrlString() -> String {
        return "https://magiceden.io/item-details/" + tokenMint
    }
    
    func getShortenedTokenMintString() -> String {
        if tokenMint.count > 8 {
            return tokenMint.prefix(4) + "..." + tokenMint.suffix(4)
        } else {
            return tokenMint
        }
    }
    
    func getShortenedSellerAddressString() -> String {
        if seller.count > 8 {
            return seller.prefix(4) + "..." + seller.suffix(4)
        } else {
            return seller
        }
    }
}
