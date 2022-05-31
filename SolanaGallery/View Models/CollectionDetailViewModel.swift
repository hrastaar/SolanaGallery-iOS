//
//  CollectionDetailViewModel.swift
//  SolanaGallery
//
//  Created by Rastaar Haghi on 5/23/22.
//

import UIKit
import RxSwift

class CollectionDetailViewModel {
    let stats = PublishSubject<CollectionStats?>()
    let listings = PublishSubject<[CollectionListing]>()
    
    let isOnWatchlist = PublishSubject<Bool>()
    
    let SolanaGalleryApi = SolanaGalleryAPI.sharedInstance
        
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    init() {
        isOnWatchlist.onNext(false)
    }

    func fetchCollectionDetailsInfo(collectionSymbol: String) {
        // Check if collection is in watchlist
        isOnWatchlist.onNext(isInWatchlist(collectionSymbol: collectionSymbol))
        
        SolanaGalleryApi.fetchCollectionStats(collectionName: collectionSymbol) { stats in
            self.stats.onNext(stats)
        }
        
        SolanaGalleryApi.fetchCollectionListings(collectionName: collectionSymbol) { listings in
            guard let listings = listings else {
                return
            }
            self.listings.onNext(listings)
            self.listings.onCompleted()
        }
    }
    
    func isInWatchlist(collectionSymbol: String) -> Bool {
        guard let items = try? context.fetch(WatchlistItem.fetchRequest()) else {
            return false
        }
        let isInWatchlist = !(items.filter {$0.collectionName == collectionSymbol}).isEmpty
        isOnWatchlist.onNext(isInWatchlist)
        return isInWatchlist
    }
    
    func toggleCollectionInWatchlist(collectionSymbol: String) {
        guard let items = try? context.fetch(WatchlistItem.fetchRequest()) else {
            return
        }
        
        let isInWatchlist = !(items.filter {$0.collectionName == collectionSymbol}).isEmpty
        if isInWatchlist {
            // Remove from watchlist
            print("Removing from watchlist")
            removeCollectionFromWatchlist(collectionName: collectionSymbol)
        } else {
            // Add to watchlist
            print("Adding to watchlist")
            addCollectionToWatchlist(collectionName: collectionSymbol)
        }
        _ = self.isInWatchlist(collectionSymbol: collectionSymbol)
    }
    
    private func addCollectionToWatchlist(collectionName: String) {
        do {
            let items = try context.fetch(WatchlistItem.fetchRequest())
            
            // check if collection is duplicate
            if !(items.filter {$0.collectionName == collectionName}).isEmpty {
                return
            }
            let newItem = WatchlistItem(context: context)
            newItem.collectionName = collectionName
            newItem.order = Int16(items.count)
            
            try context.save()
        } catch {
            print(error)
        }
    }
    
    private func removeCollectionFromWatchlist(collectionName: String) {
        do {
            let items = try context.fetch(WatchlistItem.fetchRequest())
            items.forEach { item in
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
