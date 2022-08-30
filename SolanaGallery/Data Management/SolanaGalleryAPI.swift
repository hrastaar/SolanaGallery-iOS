//
//  SolanaGalleryAPI.swift
//  SolanaGallery
//
//  Created by Rastaar Haghi on 4/27/22.
//

import Foundation
import RxSwift

class SolanaGalleryAPI {
    static let sharedInstance = SolanaGalleryAPI()

    /// This function returns an array of CollectionCount objects, each representing a Solana NFT collection in the
    /// wallet address provided.
    ///
    /// - Parameter wallet: A Solana wallet address string. Bonfida domains are not supported.
    /// - Returns: Completion that provides an optional array of CollectionCount objects
    public func getNftCollectionCounts(
        wallet: String,
        completion: @escaping ([CollectionCount]?, Error?) -> Void
    ) {
        let endpoint = getNftCollectionCountsEndpoint(wallet: wallet)
        guard let url = URL(string: endpoint) else {
            completion(nil, URLError(.badURL))
            return
        }

        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { data, _, err in
            if let err = err {
                print(err.localizedDescription)
                completion(nil, SolanaGalleryAPIError(error: err))
            }
            guard let data = data,
                  let collectionCounts = try? JSONDecoder().decode([CollectionCount].self, from: data)
            else {
                completion(nil, SolanaGalleryAPIError(errorType: .responseParsing))
                return
            }
            completion(collectionCounts, nil)
        }

        task.resume()
    }

    /// This function returns collection statistics for the collection provided
    ///
    /// - Parameter wallet: A Solana wallet address string object. Bonfida domains are not supported.
    /// - Returns: Completion that provides collection stats (if available)
    public func fetchCollectionStats(
        collectionSymbol: String,
        completion: @escaping (CollectionStats?, Error?) -> Void
    ) {
        let endpoint = getNftCollectionStatsEndpoint(collectionName: collectionSymbol)
        guard let url = URL(string: endpoint) else {
            completion(nil, URLError(.badURL))
            return
        }
        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { data, _, err in
            if let err = err {
                print("Error fetching collection stats for \(collectionSymbol)")
                completion(nil, SolanaGalleryAPIError(error: err, message: err.localizedDescription))
                return
            }
            guard let data = data,
                  let collectionStats = try? JSONDecoder().decode(CollectionStats.self, from: data)
            else {
                completion(nil, SolanaGalleryAPIError(errorType: .responseParsing))
                return
            }
            completion(collectionStats, nil)
        }
        task.resume()
    }

    /// This function returns an array of collection listings for the collection provided
    ///
    /// - Parameter collectionSymbol: Collection symbol (representing a collection)
    /// - Returns: Completion that provides an array of 20 current Magiceden listings
    public func fetchCollectionListings(
        collectionSymbol: String,
        completion: @escaping ([CollectionListing]?, Error?) -> Void
    ) {
        let endpoint = getNftCollectionListingsEndpoint(collectionName: collectionSymbol)
        guard let url = URL(string: endpoint) else {
            completion(nil, URLError(.badURL))
            return
        }
        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { data, _, err in
            if let err = err {
                print(err.localizedDescription)
                completion(nil, SolanaGalleryAPIError(error: err))
                return
            }
            guard let data = data,
                  let collectionListings = try? JSONDecoder().decode([CollectionListing].self, from: data)
            else {
                completion(nil, SolanaGalleryAPIError(errorType: .responseParsing))
                return
            }

            // Sort resulting listings by price (ascending)
            let sortedListings = collectionListings.sorted { listingA, listingB in
                listingA.price < listingB.price
            }
            completion(sortedListings, nil)
        }
        task.resume()
    }

    public func fetchCollectionActivities(
        collectionSymbol: String,
        numberOfActivities: Int,
        completion: @escaping ([CollectionActivityEvent]?, Error?) -> Void
    ) {
        let endpoint = getNftCollectionActivitiesEndpoint(
            collectionSymbol: collectionSymbol,
            desiredCount: numberOfActivities
        )
        guard let url = URL(string: endpoint) else {
            completion(nil, URLError(.badURL))
            return
        }
        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { data, _, err in
            if let err = err {
                print(err.localizedDescription)
                completion(nil, SolanaGalleryAPIError(error: err))
                return
            }
            guard let data = data,
                  let collectionActivities = try? JSONDecoder().decode([CollectionActivityEvent].self, from: data)
            else {
                completion(nil, SolanaGalleryAPIError(errorType: .responseParsing))
                return
            }
            completion(collectionActivities, nil)
        }
        task.resume()
    }

    /// This function returns an array of CollectionSearchResult objects that partially match the search text provided.
    ///
    /// - Parameter searchText: Search text string
    /// - Returns: Completion that provides an array of all collections that match the search text
    public func fetchCollectionsList(
        searchText: String,
        completion: @escaping ([CollectionSearchResult]?, Error?) -> Void
    ) {
        let endpoint = getSearchCollectionsEndpoint(searchText: searchText)
        guard let url = URL(string: endpoint) else {
            completion(nil, URLError(.badURL))
            return
        }
        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { data, _, err in
            if let err = err {
                print(err.localizedDescription)
                completion(nil, URLError(.unknown))
                return
            }
            guard let data = data,
                  let collectionSearchResults = try? JSONDecoder().decode([CollectionSearchResult].self, from: data)
            else {
                completion(nil, SolanaGalleryAPIError(errorType: .responseParsing))
                return
            }
            completion(collectionSearchResults, nil)
        }
        task.resume()
    }

    private func getNftCollectionCountsEndpoint(wallet: String) -> String {
        return solanaGalleryApiBaseUrl + walletEndpoint + wallet + getNftCollectionCounts
    }

    private func getNftCollectionStatsEndpoint(collectionName: String) -> String {
        return solanaGalleryApiBaseUrl + statsEndpoint + collectionName
    }

    private func getNftCollectionListingsEndpoint(collectionName: String) -> String {
        return solanaGalleryApiBaseUrl + listingsEndpoint + collectionName
    }

    private func getNftCollectionActivitiesEndpoint(collectionSymbol: String, desiredCount: Int) -> String {
        let countString = String(desiredCount)
        return solanaGalleryApiBaseUrl + activitiesEndpoint + collectionSymbol + "/0/" + countString
    }

    private func getSearchCollectionsEndpoint(searchText: String) -> String {
        let translatedSearchText = searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        return solanaGalleryApiBaseUrl + collectionSearchResults + translatedSearchText
    }

    private let solanaGalleryApiBaseUrl = "https://rastaar.com/"
    private let walletEndpoint = "solana/wallet/"
    private let statsEndpoint = "solana/stats/"
    private let listingsEndpoint = "solana/listings/"
    private let activitiesEndpoint = "solana/activities/"
    private let getNftCollectionCounts = "/get_nft_collection_counts"
    private let collectionSearchResults = "solana/search/collections/"

    static let magicedenListingUrlPrefix = "https://magiceden.io/item-details/"
    static let magicedenCollectionUrlPrefix = "https://magiceden.io/marketplace/"
}
