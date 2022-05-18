//
//  CollectionSearchViewModel.swift
//  SolanaGallery
//
//  Created by Rastaar Haghi on 5/16/22.
//

import Foundation
import RxSwift

class CollectionSearchViewModel {
    var collectionSearchResults = PublishSubject<[CollectionSearchResult]>()

    func filterSearchResults(searchInput: String) {
        SolanaGalleryAPI.sharedInstance.fetchCollectionsList(searchText: searchInput.lowercased()) { searchResults in
            guard let searchResults = searchResults else {
                return
            }
            print(searchResults)
            self.collectionSearchResults.onNext(searchResults)
            self.collectionSearchResults.onCompleted()
        }
    }
}
