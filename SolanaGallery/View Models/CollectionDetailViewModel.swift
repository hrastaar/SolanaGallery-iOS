//
//  CollectionDetailViewModel.swift
//  SolanaGallery
//
//  Created by Rastaar Haghi on 5/23/22.
//

import RxSwift
import UIKit

class CollectionDetailViewModel {
    let stats = PublishSubject<CollectionStats?>()
    let listings = PublishSubject<[CollectionListing]>()
    let activities = PublishSubject<[CollectionActivityEvent]>()

    let solanaGalleryApi = SolanaGalleryAPI.sharedInstance

    func fetchCollectionDetailsInfo(collectionSymbol: String) {
        solanaGalleryApi.fetchCollectionStats(collectionSymbol: collectionSymbol) { stats, err in
            if let err = err {
                print("CollectionDetailsViewModel failed to fetch collection stats")
                print(err.localizedDescription)
                self.stats.onError(err)
            }
            self.stats.onNext(stats)
        }

        solanaGalleryApi.fetchCollectionListings(collectionSymbol: collectionSymbol) { listings, err in
            if let err = err {
                print(err.localizedDescription)
                self.listings.onNext([])
                return
            }
            guard let listings = listings else {
                return
            }
            self.listings.onNext(listings)
        }

        solanaGalleryApi.fetchCollectionActivities(collectionSymbol: collectionSymbol,
                                                   numberOfActivities: 20) { activities, err in
            if let err = err {
                print(err.localizedDescription)
                self.activities.onNext([])
                return
            }
            guard let activities = activities else {
                return
            }
            self.activities.onNext(activities)
        }
    }
}
