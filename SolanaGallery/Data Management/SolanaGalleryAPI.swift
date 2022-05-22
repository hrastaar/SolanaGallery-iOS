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
    public func getNftCollectionCounts(wallet: String, completion: @escaping ([CollectionCount]?) -> Void) -> Void {
        let endpoint = self.getNftCollectionCountsEndpoint(wallet: wallet)
        guard let url = URL(string: endpoint) else {
            completion(nil)
            return
        }
        
        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { data, response, err in
            guard let data = data else {
                completion(nil)
                return
            }
            guard let collectionCounts = try? JSONDecoder().decode([CollectionCount].self, from: data) else {
                completion(nil)
                return
            }
            completion(collectionCounts)
        }
        
        task.resume()
    }
    
    /// This function returns collection statistics for the collection provided
    ///
    /// - Parameter wallet: A Solana wallet address string object. Bonfida domains are not supported.
    /// - Returns: Completion that provides collection stats (if available)
    public func fetchCollectionStats(collectionName: String, completion: @escaping (CollectionStats?) -> Void) -> Void {
        let endpoint = self.getNftCollectionStatsEndpoint(collectionName: collectionName)
        guard let url = URL(string: endpoint) else {
            completion(nil)
            return
        }
        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { data, _, _ in
            guard let data = data else {
                completion(nil)
                return
            }
            guard let collectionStats = try? JSONDecoder().decode(CollectionStats.self, from: data) else {
                print("Couldn't decode data into CollectionStats for \(collectionName)")
                completion(nil)
                return
            }
            completion(collectionStats)
            return
        }
        task.resume()
    }
    
    /// This function returns an array of CollectionSearchResult objects that partially match the search text provided.
    ///
    /// - Parameter searchText: Search text string
    /// - Returns: Completion that provides an array of all collections that match the search text
    public func fetchCollectionsList(searchText: String, completion: @escaping ([CollectionSearchResult]?) -> Void) -> Void {
        let endpoint = getSearchCollectionsEndpoint(searchText: searchText)
        guard let url = URL(string: endpoint) else {
            completion(nil)
            return
        }
        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { data, _, _ in
            guard let data = data else {
                completion(nil)
                return
            }
            
            guard let collectionSearchResults = try? JSONDecoder().decode([CollectionSearchResult].self, from: data) else {
                print("Couldn't decode data into CollectionSearchResults")
                completion(nil)
                return
            }
            completion(collectionSearchResults)
            return
        }
        task.resume()
    }
    
    private func getNftCollectionCountsEndpoint(wallet: String) -> String {
        return BASE_URL + WALLET_ENDPOINT_EXTENSION + wallet + GET_NFT_COLLECTION_COUNTS;
    }
    
    private func getNftCollectionStatsEndpoint(collectionName: String) -> String {
        return BASE_URL + COLLECTION_ENDPOINT + collectionName
    }

    private func getSearchCollectionsEndpoint(searchText: String) -> String {
        return BASE_URL + COLLECTION_SEARCH_EXTENSION + searchText
    }
    
    private let BASE_URL = "https://rastaar.com/";
    private let WALLET_ENDPOINT_EXTENSION = "solana/wallet/";
    private let COLLECTION_ENDPOINT = "solana/stats/"
    private let GET_NFT_COLLECTION_COUNTS = "/get_nft_collection_counts"
    private let COLLECTION_SEARCH_EXTENSION = "solana/search/collections/"
}
