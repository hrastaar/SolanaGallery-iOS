//
//  CollectionSearchViewModel.swift
//  SolanaGallery
//
//  Created by Rastaar Haghi on 5/16/22.
//

import Foundation
import RxSwift

class CollectionSearchViewModel {
    let collectionSearchResults = PublishSubject<[CollectionSearchResult]>()

    func filterSearchResults(searchInput: String) {
        SolanaGalleryAPI.sharedInstance.fetchCollectionsList(searchText: searchInput.lowercased()) { searchResults in
            guard let searchResults = searchResults else {
                return
            }
            self.collectionSearchResults.onNext(searchResults)
        }
    }
    
    func clearSearchResults() {
        self.collectionSearchResults.onNext([])
    }
}
