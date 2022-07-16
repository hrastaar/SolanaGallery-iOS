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
    
    let SolanaGalleryApi = SolanaGalleryAPI.sharedInstance
            
    func fetchCollectionDetailsInfo(collectionSymbol: String) {
        SolanaGalleryApi.fetchCollectionStats(collectionSymbol: collectionSymbol) { stats, err in
            if let err = err {
                print("CollectionDetailsViewModel failed to fetch collection stats")
                print(err.localizedDescription)
                self.stats.onError(err)
            }
            self.stats.onNext(stats)
        }
        
        SolanaGalleryApi.fetchCollectionListings(collectionSymbol: collectionSymbol) { listings, err in
            if let err = err {
                print(err.localizedDescription)
                self.listings.onNext([])
            }
            guard let listings = listings else {
                return
            }
            self.listings.onNext(listings)
        }
    }
}
