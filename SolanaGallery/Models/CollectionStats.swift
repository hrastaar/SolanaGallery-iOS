//
//  CollectionStats.swift
//  SolanaGallery
//
//  Created by Rastaar Haghi on 4/27/22.
//

import Foundation

struct CollectionStats: Codable {
    let symbol: String
    let floorPrice: Double
    let listedCount: Int
    let lastUpdated: Int64
    
    private enum CodingKeys: String, CodingKey {
        case symbol, floorPrice, listedCount, lastUpdated
    }
}
