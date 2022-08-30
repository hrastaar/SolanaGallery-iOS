//
//  WatchlistViewModel.swift
//  SolanaGallery
//
//  Created by Rastaar Haghi on 5/12/22.
//

import RxSwift
import UIKit

class WatchlistViewModel {
    static let sharedInstance = WatchlistViewModel()

    var watchlistItems = PublishSubject<[WatchlistCollectionViewModel]>()
    let isOnWatchlist = PublishSubject<Bool>()

    let solanaGalleryApi = SolanaGalleryAPI.sharedInstance

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    init() { isOnWatchlist.onNext(false) }

    func fetchWatchlistData() {
        do {
            let watchlistItems = try context.fetch(WatchlistItem.fetchRequest())

            let dispatchGroup = DispatchGroup()

            var watchlistItemsResponse = [WatchlistCollectionViewModel]()
            for item in watchlistItems {
                guard let collectionName = item.collectionName else {
                    continue
                }
                dispatchGroup.enter()
                solanaGalleryApi.fetchCollectionStats(collectionSymbol: collectionName) { stats, err in
                    if let err = err {
                        print("WatchlistViewModel failed to fetch collection stats.")
                        print(err.localizedDescription)
                        dispatchGroup.leave()
                        return
                    }
                    guard let stats = stats else {
                        print("Failed to fetch stats for collection \(collectionName)")
                        dispatchGroup.leave()
                        return
                    }
                    watchlistItemsResponse.append(
                        WatchlistCollectionViewModel(withCollectionStats: stats)
                    )
                    dispatchGroup.leave()
                }
            }

            dispatchGroup.notify(queue: .global(qos: .userInitiated)) {
                watchlistItemsResponse.sort { first, second in
                    first.getCollectionNameString() < second.getCollectionNameString()
                }
                self.watchlistItems.onNext(watchlistItemsResponse)
                print("Successfully fetched collection stats for \(watchlistItems.count) collections")
            }
        } catch {
            print(error)
        }
    }

    func isInWatchlist(collectionSymbol: String) -> Bool {
        guard let items = try? context.fetch(WatchlistItem.fetchRequest()) else {
            return false
        }
        let isInWatchlist = !(items.filter { $0.collectionName == collectionSymbol }).isEmpty
        isOnWatchlist.onNext(isInWatchlist)
        return isInWatchlist
    }

    func toggleCollectionInWatchlist(collectionSymbol: String) {
        guard let items = try? context.fetch(WatchlistItem.fetchRequest()) else {
            return
        }

        let isInWatchlist = !(items.filter { $0.collectionName == collectionSymbol }).isEmpty
        if isInWatchlist {
            // Remove from watchlist
            print("Removing \(collectionSymbol) from watchlist")
            removeCollectionFromWatchlist(collectionName: collectionSymbol)
        } else {
            // Add to watchlist
            print("Adding \(collectionSymbol) to watchlist")
            addCollectionToWatchlist(collectionName: collectionSymbol)
        }
        _ = self.isInWatchlist(collectionSymbol: collectionSymbol)
    }

    private func addCollectionToWatchlist(collectionName: String) {
        do {
            let watchlistItems = try context.fetch(WatchlistItem.fetchRequest())

            // check if collection is duplicate
            if !(watchlistItems.filter { $0.collectionName == collectionName }).isEmpty {
                return
            }
            let newItem = WatchlistItem(context: context)
            newItem.collectionName = collectionName

            try context.save()
        } catch {
            print(error)
        }
    }

    private func removeCollectionFromWatchlist(collectionName: String) {
        do {
            let watchlistItems = try context.fetch(WatchlistItem.fetchRequest())
            watchlistItems.forEach { item in
                if item.collectionName == collectionName {
                    context.delete(item)
                }
            }
            try context.save()
        } catch {
            print(error)
        }
    }
}
