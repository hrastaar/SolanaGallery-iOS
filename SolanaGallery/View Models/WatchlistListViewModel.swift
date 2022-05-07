//
//  WatchlistListViewModel.swift
//  SolanaGallery
//
//  Created by Rastaar Haghi on 5/6/22.
//

import Foundation
import RxSwift

final class WatchlistListViewModel {
    private let solanaGalleryAPI = SolanaGalleryAPI.sharedInstance
    private let disposeBag = DisposeBag()
    func fetchWatchlistViewModels(watchlistItems: [WatchlistItem]) -> Observable<[WatchlistViewModel]> {
        for collection in watchlistItems {
            guard let collectionName = collection.collectionName else {
                continue
            }
            SolanaGalleryAPI.sharedInstance.fetchCollectionStat(collectionName: collectionName).subscribe(onNext: { stat in
                let watchlistViewModel = WatchlistViewModel(withCollectionStats: stat, coreDataItem: collection)
            }).disposed(by: disposeBag)
        }
    }
}
