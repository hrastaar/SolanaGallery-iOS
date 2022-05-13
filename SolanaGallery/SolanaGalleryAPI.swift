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
                print("Error: couldn't decode data into CollectionStats for \(collectionName)")
                completion(nil)
                return
            }
            completion(collectionStats)
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
    
    let BASE_URL = "https://rastaar.com/";
    let WALLET_ENDPOINT_EXTENSION = "solana/wallet/";
    let COLLECTION_ENDPOINT = "solana/stats/"
    let GET_NFT_COLLECTION_COUNTS = "/get_nft_collection_counts"
}
