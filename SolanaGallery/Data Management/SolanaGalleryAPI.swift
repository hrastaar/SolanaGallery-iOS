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
    
    /// This function returns an array of CollectionCount objects, each representing a Solana NFT collection in the wallet address provided.
    ///
    /// - Parameter wallet: A Solana wallet address string. Bonfida domains are not supported.
    /// - Returns: Completion that provides an optional array of CollectionCount objects
    public func getNftCollectionCounts(wallet: String, completion: @escaping ([CollectionCount]?, Error?) -> Void) -> Void {
        let endpoint = self.getNftCollectionCountsEndpoint(wallet: wallet)
        guard let url = URL(string: endpoint) else {
            completion(nil, URLError(.badURL))
            return
        }
        
        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { data, response, err in
            if let err = err {
                print(err.localizedDescription)
                completion(nil, SolanaGalleryAPIError(error: err))
            }
            guard let data = data,
                  let collectionCounts = try? JSONDecoder().decode([CollectionCount].self, from: data) else {
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
    public func fetchCollectionStats(collectionSymbol: String, completion: @escaping (CollectionStats?, Error?) -> Void) -> Void {
        let endpoint = self.getNftCollectionStatsEndpoint(collectionName: collectionSymbol)
        guard let url = URL(string: endpoint) else {
            completion(nil, URLError(.badURL))
            return
        }
        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { data, response, err in
            if let err = err {
                print("Error fetching collection stats for \(collectionSymbol)")
                completion(nil, SolanaGalleryAPIError(error: err, message: err.localizedDescription))
                return
            }
            guard let data = data,
                  let collectionStats = try? JSONDecoder().decode(CollectionStats.self, from: data) else {
                completion(nil, SolanaGalleryAPIError(errorType: .responseParsing))
                return
            }
            completion(collectionStats, nil)
            return
        }
        task.resume()
    }
    
    /// This function returns an array of collection listings for the collection provided
    ///
    /// - Parameter collectionSymbol: Collection symbol (representing a collection)
    /// - Returns: Completion that provides an array of 20 current Magiceden listings
    public func fetchCollectionListings(collectionSymbol: String, completion: @escaping ([CollectionListing]?, Error?) -> Void) -> Void {
        let endpoint = self.getNftCollectionListingsEndpoint(collectionName: collectionSymbol)
        guard let url = URL(string: endpoint) else {
            completion(nil, URLError(.badURL))
            return
        }
        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { data, response, err in
            if let err = err {
                print(err.localizedDescription)
                completion(nil, SolanaGalleryAPIError(error: err))
                return
            }
            guard let data = data,
                  let collectionListings = try? JSONDecoder().decode([CollectionListing].self, from: data) else {
                completion(nil, SolanaGalleryAPIError(errorType: .responseParsing))
                return
            }
            
            // Sort resulting listings by price (ascending)
            let sortedListings = collectionListings.sorted { listingA, listingB in
                return listingA.price < listingB.price
            }
            completion(sortedListings, nil)
            return
        }
        task.resume()
    }
    
    /// This function returns an array of CollectionSearchResult objects that partially match the search text provided.
    ///
    /// - Parameter searchText: Search text string
    /// - Returns: Completion that provides an array of all collections that match the search text
    public func fetchCollectionsList(searchText: String, completion: @escaping ([CollectionSearchResult]?, Error?) -> Void) -> Void {
        let endpoint = getSearchCollectionsEndpoint(searchText: searchText)
        guard let url = URL(string: endpoint) else {
            completion(nil, URLError(.badURL))
            return
        }
        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { data, response, err in
            if let err = err {
                print(err.localizedDescription)
                completion(nil, URLError(.unknown))
                return
            }
            guard let data = data,
                  let collectionSearchResults = try? JSONDecoder().decode([CollectionSearchResult].self, from: data) else {
                completion(nil, SolanaGalleryAPIError(errorType: .responseParsing))
                return
            }
            completion(collectionSearchResults, nil)
            return
        }
        task.resume()
    }
    
    private func getNftCollectionCountsEndpoint(wallet: String) -> String {
        return SOLANA_GALLERY_API_BASE_URL + WALLET_ENDPOINT_EXTENSION + wallet + GET_NFT_COLLECTION_COUNTS;
    }
    
    private func getNftCollectionStatsEndpoint(collectionName: String) -> String {
        return SOLANA_GALLERY_API_BASE_URL + COLLECTION_STATS_ENDPOINT + collectionName
    }
    
    private func getNftCollectionListingsEndpoint(collectionName: String) -> String {
        return SOLANA_GALLERY_API_BASE_URL + COLLECTION_LISTING_ENDPOINT + collectionName
    }

    private func getSearchCollectionsEndpoint(searchText: String) -> String {
        return SOLANA_GALLERY_API_BASE_URL + COLLECTION_SEARCH_EXTENSION + (searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")
    }
    
    private let SOLANA_GALLERY_API_BASE_URL = "https://rastaar.com/"
    private let WALLET_ENDPOINT_EXTENSION = "solana/wallet/"
    private let COLLECTION_STATS_ENDPOINT = "solana/stats/"
    private let COLLECTION_LISTING_ENDPOINT = "solana/listings/"
    private let GET_NFT_COLLECTION_COUNTS = "/get_nft_collection_counts"
    private let COLLECTION_SEARCH_EXTENSION = "solana/search/collections/"
    
    static let MagicedenListingUrlPrefix = "https://magiceden.io/item-details/"
    static let MagicedenCollectionUrlPrefix = "https://magiceden.io/marketplace/"
}
