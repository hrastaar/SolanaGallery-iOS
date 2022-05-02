//
//  WatchlistViewModel.swift
//  SolanaGallery
//
//  Created by Rastaar Haghi on 4/27/22.
//

import Foundation

class WatchlistViewModel {
    let collectionStats: CollectionStats
    let coreDataItem: WatchlistItem
    
    init(withCollectionStats stats: CollectionStats, coreDataItem: WatchlistItem) {
        self.collectionStats = stats
        self.coreDataItem = coreDataItem
    }
    
    func getCollectionNameString() -> String {
        var collectionName = collectionStats.symbol
        collectionName = collectionName.replacingOccurrences(of: "_", with: " ")
        return collectionName.capitalized
    }
    
    func getFloorPriceString() -> String {
        return String(format: "Floor Price\n%.2f◎", collectionStats.floorPrice)
    }
    
    func getListedCountString() -> String {
        return "# Listed\n" + String(collectionStats.listedCount)
    }
    
    func getLastUpdatedString() -> String {
        let timestamp = Double(collectionStats.lastUpdated)
        let date = Date(timeIntervalSince1970: timestamp)
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateStyle = .full
        
        return dateFormatter.string(from: date)
    }
}
