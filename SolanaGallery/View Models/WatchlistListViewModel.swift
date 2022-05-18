//
//  WatchlistListViewModel.swift
//  SolanaGallery
//
//  Created by Rastaar Haghi on 5/12/22.
//

import Foundation
import RxSwift

class WatchlistListViewModel {
    var watchlistItems = PublishSubject<[WatchlistViewModel]>()
    
    let SolanaGalleryApiInstance = SolanaGalleryAPI.sharedInstance
        
    func fetchWatchlistData(watchlistItems: [WatchlistItem]) {
        let dispatchGroup = DispatchGroup()
        
        var watchlistItemsResponse = [WatchlistViewModel]()
        for item in watchlistItems {
            guard let collectionName = item.collectionName else {
                continue
            }
            dispatchGroup.enter()
            self.SolanaGalleryApiInstance.fetchCollectionStats(collectionName: collectionName) { stats in
                guard let stats = stats else {
                    print("Failed to fetch stats for collection: \(collectionName)")
                    dispatchGroup.leave()
                    return
                }
                watchlistItemsResponse.append(WatchlistViewModel(withCollectionStats: stats, coreDataItem: item))
                self.watchlistItems.onNext(watchlistItemsResponse)
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .global(qos: .userInitiated)) {
            print("Successfully fetched collection stats for \(watchlistItems.count) collections")
            self.watchlistItems.onCompleted()
        }
    }
}
