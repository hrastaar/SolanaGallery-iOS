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
                guard let collectionStats = try? JSONDecoder().decode(CollectionStats.self, from: data) else {
                    print("Error: couldn't decode data into CollectionStats")
                    return
                }
                completion(collectionStats)
            }
        }
        task.resume()
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
