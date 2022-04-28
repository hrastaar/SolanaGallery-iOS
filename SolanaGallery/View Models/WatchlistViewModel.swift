//
//  WatchlistViewModel.swift
//  SolanaGallery
//
//  Created by Rastaar Haghi on 4/27/22.
//

import Foundation

class WatchlistViewModel {
    let collectionStats: CollectionStats
    
    init(withCollectionStats stats: CollectionStats) {
        self.collectionStats = stats
    }
    
    func watchlistItemLabelText() -> String {
        return self.collectionStats.symbol + ", floor: " + String(self.collectionStats.floorPrice) + ", # listed: " + String(self.collectionStats.listedCount)
    }
}
