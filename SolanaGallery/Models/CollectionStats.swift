//
//  CollectionStats.swift
//  SolanaGallery
//
//  Created by Rastaar Haghi on 4/27/22.
//

import Foundation

struct CollectionStats: Decodable {
    let symbol: String
    let floorPrice: Double
    let listedCount: Int
    let lastUpdated: Int64
}
