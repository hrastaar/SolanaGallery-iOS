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
    let blockTime: Int64

    var priceString: String {
        switch type {
        case .bid:
            return "Someone bid " + String(format: "%.2f◎", price)
        case .cancelBid:
            return "Someone cancelled their bid"
        case .list:
            return "An NFT owner listed their item for " + String(format: "%.2f◎", price)
        case .delist:
            return "An NFT owner delisted their item"
        case .buyNow:
            return "Someone purchased an NFT for " + String(format: "%.2f◎", price)
        default:
            return "N/A"
        }
    }

    var dateString: String {
        let date = Date(timeIntervalSince1970: TimeInterval(blockTime))
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy HH:mm"
        formatter.timeZone = TimeZone(abbreviation: "PST")
        return formatter.string(from: date) + " PST"
    }
}

enum CollectionActivityType: Decodable, CustomStringConvertible, Equatable {
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

    var description: String {
        switch self {
        // Use Internationalization, as appropriate.
        case .bid: return "Bid"
        case .cancelBid: return "Bid Cancelled"
        case .list: return "Item Listed"
        case .delist: return "Item Delisted"
        case .buyNow: return "Buy Now"
        default: return "Unknown"
        }
    }
}
