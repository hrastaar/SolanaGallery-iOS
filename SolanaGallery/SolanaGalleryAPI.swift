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
    
    public func getNftCollectionCounts(wallet: String) -> Observable<[CollectionCount]> {
        return Observable.create { observer -> Disposable in
            let endpoint = self.getNftCollectionCountsEndpoint(wallet: wallet)
            guard let url = URL(string: endpoint) else {
                observer.onError(NSError(domain: "Failed to create URL", code: -1, userInfo: nil))
                return Disposables.create { }
            }
            
            let urlRequest = URLRequest(url: url)
            let task = URLSession.shared.dataTask(with: urlRequest) { data, response, err in
                guard let data = data else {
                    observer.onError(NSError(domain: "no data", code: -1, userInfo: nil))
                    return
                }
                guard let collectionCounts = try? JSONDecoder().decode([CollectionCount].self, from: data) else {
                    print("Error: couldn't decode data into [CollectionCount]")
                    return
                }
                observer.onNext(collectionCounts)
            }
            
            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
        }

    }
    
    public func fetchCollectionStats(collectionName: String) -> Observable<CollectionStats> {
        return Observable.create { observer -> Disposable in
            let endpoint = self.getNftCollectionStatsEndpoint(collectionName: collectionName)
            guard let url = URL(string: endpoint) else {
                observer.onError(NSError(domain: "Failed to create URL", code: -1, userInfo: nil))
                return Disposables.create { }
            }
            let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { data, _, _ in
                guard let data = data else {
                    observer.onError(NSError(domain: "no data", code: -1, userInfo: nil))
                    return
                }
                
                do {
                    let collectionStats = try JSONDecoder().decode(CollectionStats.self, from: data)
                    observer.onNext(collectionStats)
                } catch {
                    observer.onError(error)
                }
            }
            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
        }

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
