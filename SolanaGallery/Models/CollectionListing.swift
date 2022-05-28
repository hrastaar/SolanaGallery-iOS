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
}
