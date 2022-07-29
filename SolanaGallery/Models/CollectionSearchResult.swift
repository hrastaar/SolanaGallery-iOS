//
//  CollectionSearchResult.swift
//  SolanaGallery
//
//  Created by Rastaar Haghi on 5/16/22.
//

import Foundation

struct CollectionSearchResult: Decodable, Hashable {
    let symbol: String
    let name: String
    let image: String
}
