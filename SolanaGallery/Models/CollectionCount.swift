//
//  CollectionCount.swift
//  SolanaGallery
//
//  Created by Rastaar Haghi on 4/27/22.
//

import Foundation

struct CollectionCount: Codable {
    let collectionName: String
    let count: Int

    private enum CodingKeys: String, CodingKey {
        case collectionName = "collection", count
    }
}
