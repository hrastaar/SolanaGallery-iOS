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
        SolanaGalleryApi.fetchCollectionStats(collectionSymbol: collectionSymbol) { stats in
            self.stats.onNext(stats)
        }
        
        SolanaGalleryApi.fetchCollectionListings(collectionSymbol: collectionSymbol) { listings in
            guard let listings = listings else {
                return
            }
            self.listings.onNext(listings)
        }
    }
}
