//
//  SolanaGalleryAPI.swift
//  SolanaGallery
//
//  Created by Rastaar Haghi on 4/27/22.
//

import Foundation

class SolanaGalleryAPI {
    static let sharedInstance = SolanaGalleryAPI()
    
    let BASE_URL = "https://rastaar.com/";
    let WALLET_ENDPOINT_EXTENSION = "solana/wallet/";
    let COLLECTION_ENDPOINT = "solana/stats/"
    let GET_NFT_COLLECTION_COUNTS = "/get_nft_collection_counts"
    
    public func getNftCollectionCounts(wallet: String, completion: @escaping ([CollectionCount]) -> ()) {
        let endpoint = getNftCollectionCountsEndpoint(wallet: wallet)
        guard let url = URL(string: endpoint) else {
            return
        }
        
        let urlRequest = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, err in
            if let data = data {
                guard let collectionCounts = try? JSONDecoder().decode([CollectionCount].self, from: data) else {
                    print("Error: couldn't decode data into [CollectionCount]")
                    return
                }
                completion(collectionCounts)
            }
        }
        task.resume()
    }
    
    public func getNftCollectionStats(collectionName: String, completion: @escaping (CollectionStats?) -> ()) {
        let endpoint = getNftCollectionStatsEndpoint(collectionName: collectionName)
        guard let url = URL(string: endpoint) else {
            return
        }
        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { data, response, err in
            if let data = data {
                if let collectionStats = try? JSONDecoder().decode(CollectionStats.self, from: data)  {
                    completion(collectionStats)
                } else {
                    print("Couldn't decode data for collection \(collectionName)")
                    completion(nil)
                }
            } else {
                print("Failed to fetch data for collection \(collectionName)")
                completion(nil)
            }
        }
        task.resume()
    }
    
    public func fetchCollectionStatsAndCreateWatchlistViewModels(collections: [WatchlistItem], completion: @escaping ([WatchlistViewModel]?) -> ()) {
        var watchlistItems = [WatchlistViewModel]()
        
        let dispatchGroup = DispatchGroup()
        
        for collection in collections {
            if let collectionName = collection.collectionName {
                dispatchGroup.enter()
                getNftCollectionStats(collectionName: collectionName) { stats in
                    if let stats = stats {
                        let watchlistViewModel = WatchlistViewModel(withCollectionStats: stats, coreDataItem: collection)
                        watchlistItems.append(watchlistViewModel)
                    }
                    dispatchGroup.leave()
                }
            }
        }

        // Wait for all collection stats requests to complete
        dispatchGroup.wait()
        watchlistItems.sort {
            $1.getCollectionNameString() > $0.getCollectionNameString()
        }
        completion(watchlistItems)
    }
    
    private func getNftCollectionCountsEndpoint(wallet: String) -> String {
        return BASE_URL + WALLET_ENDPOINT_EXTENSION + wallet + GET_NFT_COLLECTION_COUNTS;
    }
    
    private func getNftCollectionStatsEndpoint(collectionName: String) -> String {
        return BASE_URL + COLLECTION_ENDPOINT + collectionName
    }
}

extension SolanaGalleryAPI {
    
}
