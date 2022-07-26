//
//  PortfolioCollectionViewModel.swift
//  SolanaGallery
//
//  Created by Rastaar Haghi on 5/8/22.
//

import Foundation
import RxSwift

struct PortfolioCollectionViewModel {
    let collectionCount: CollectionCount
    let collectionStats: CollectionStats

    init(collectionCount: CollectionCount, collectionStats: CollectionStats) {
        self.collectionCount = collectionCount
        self.collectionStats = collectionStats
    }

    func getCollectionNameString() -> String {
        var collectionName = collectionStats.symbol
        collectionName = collectionName.replacingOccurrences(of: "_", with: " ")
        return collectionName.capitalized
    }

    func getFloorPriceString() -> String {
        return String(format: "Floor Price\n%.2f◎", collectionStats.floorPrice)
    }

    func getCollectionCount() -> String {
        return "Count: \(collectionCount.count)"
    }

    func getCollectionTotalValueDouble() -> Double {
        return collectionStats.floorPrice * Double(collectionCount.count)
    }

    func getCollectionTotalValueString() -> String {
        return String(format: "Total Value\n%.2f◎", getCollectionTotalValueDouble())
    }

    func getCollectionTotalValueTruncatedString() -> String {
        return String(getCollectionNameString().prefix(20))
    }
}
