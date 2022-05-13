//
//  PortfolioViewModel.swift
//  SolanaGallery
//
//  Created by Rastaar Haghi on 5/12/22.
//

import Foundation
import RxSwift

class PortfolioViewModel {
    var collections = PublishSubject<[PortfolioCollectionViewModel]>()
    
    private let SolanaGalleryApiInstance = SolanaGalleryAPI.sharedInstance
    
    func fetchWalletPortfolioData(wallet: String) {
        SolanaGalleryApiInstance.getNftCollectionCounts(wallet: wallet) { counts in
            var collectionDataArr = [PortfolioCollectionViewModel]()
            guard let collectionCounts = counts else {
                self.collections.onNext(collectionDataArr)
                self.collections.onCompleted()
                return
            }
            
            let dispatchGroup = DispatchGroup()
            
            for collectionCount in collectionCounts {
                dispatchGroup.enter()
                self.SolanaGalleryApiInstance.fetchCollectionStats(collectionName: collectionCount.collection) { stats in
                    guard let stats = stats else {
                        print("Failed to fetch stats for collection: \(collectionCount.collection)")
                        dispatchGroup.leave()
                        return
                    }
                    collectionDataArr.append(
                        PortfolioCollectionViewModel(collectionCount: collectionCount, collectionStats: stats)
                    )
                    self.collections.onNext(collectionDataArr)
                    dispatchGroup.leave()
                }
            }
            dispatchGroup.notify(queue: .global(qos: .userInitiated)) {
                print("Successfully fetched collection stats for \(collectionDataArr.count) collections")
                self.collections.onCompleted()
            }
        }
    }
}
