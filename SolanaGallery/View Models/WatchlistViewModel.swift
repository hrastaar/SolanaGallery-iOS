//
//  WatchlistViewModel.swift
//  SolanaGallery
//
//  Created by Rastaar Haghi on 5/12/22.
//

import Foundation
import RxSwift

class WatchlistViewModel {
    var watchlistItems = PublishSubject<[WatchlistCollectionViewModel]>()
    
    let SolanaGalleryApiInstance = SolanaGalleryAPI.sharedInstance
        
    func fetchWatchlistData(watchlistItems: [WatchlistItem]) {
        let dispatchGroup = DispatchGroup()
        
        var watchlistItemsResponse = [WatchlistCollectionViewModel]()
        for item in watchlistItems {
            guard let collectionName = item.collectionName else {
                continue
            }
            dispatchGroup.enter()
            self.SolanaGalleryApiInstance.fetchCollectionStats(collectionSymbol: collectionName) { stats in
                guard let stats = stats else {
                    print("Failed to fetch stats for collection \(collectionName)")
                    dispatchGroup.leave()
                    return
                }
                watchlistItemsResponse.append(WatchlistCollectionViewModel(withCollectionStats: stats, coreDataItem: item))
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .global(qos: .userInitiated)) {
            watchlistItemsResponse.sort { a, b in
                return a.getCollectionNameString() < b.getCollectionNameString()
            }
            self.watchlistItems.onNext(watchlistItemsResponse)
            print("Successfully fetched collection stats for \(watchlistItems.count) collections")
        }
    }
}
