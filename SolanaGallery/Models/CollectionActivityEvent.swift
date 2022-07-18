//
//  CollectionActivityEvent.swift
//  SolanaGallery
//
//  Created by Rastaar Haghi on 7/17/22.
//

import Foundation

struct CollectionActivityEvent: Decodable {
    let signature: String
    let type: CollectionActivityType
    let source: String
    let tokenMint: String
    let price: Double
}

enum CollectionActivityType: Decodable {
    case bid, cancelBid, list, delist, buyNow
    case unknown(value: String)
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let status = try? container.decode(String.self)
        switch status {
              case "bid": self = .bid
              case "cancelBid": self = .cancelBid
              case "list": self = .list
              case "delist": self = .delist
              case "buyNow": self = .buyNow
              default:
                 self = .unknown(value: status ?? "unknown")
          }
    }
}
