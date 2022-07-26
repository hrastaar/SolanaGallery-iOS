//
//  WatchlistItem+CoreDataProperties.swift
//  SolanaGallery
//
//  Created by Rastaar Haghi on 4/27/22.
//
//

import CoreData
import Foundation

public extension WatchlistItem {
    @nonobjc class func fetchRequest() -> NSFetchRequest<WatchlistItem> {
        return NSFetchRequest<WatchlistItem>(entityName: "WatchlistItem")
    }

    @NSManaged var collectionName: String?
}

extension WatchlistItem: Identifiable {}
