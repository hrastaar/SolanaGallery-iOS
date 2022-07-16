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
        SolanaGalleryApiInstance.getNftCollectionCounts(wallet: wallet) { counts, err in
            if let err = err {
                print(err.localizedDescription)
                self.collections.onNext([])
                return
            }
            var collectionDataArr = [PortfolioCollectionViewModel]()
            guard let collectionCounts = counts else {
                self.collections.onNext(collectionDataArr)
                return
            }
            
            let dispatchGroup = DispatchGroup()
            
            for collectionCount in collectionCounts {
                dispatchGroup.enter()
                self.SolanaGalleryApiInstance.fetchCollectionStats(collectionSymbol: collectionCount.collection) { stats, err in
                    if let err = err {
                        print("Error occurred when fetching collection stats for \(collectionCount.collection)")
                        print(err.localizedDescription)
                        dispatchGroup.leave()
                        return
                    }
                    guard let stats = stats else {
                        print("Failed to fetch stats for collection \(collectionCount.collection)")
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
                self.collections.onNext(collectionDataArr)
            }
        }
    }
}
