//
//  WatchlistItem+CoreDataProperties.swift
//  SolanaGallery
//
//  Created by Rastaar Haghi on 4/27/22.
//
//

import Foundation
import CoreData


extension WatchlistItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WatchlistItem> {
        return NSFetchRequest<WatchlistItem>(entityName: "WatchlistItem")
    }

    @NSManaged public var collectionName: String?
}

extension WatchlistItem : Identifiable {

}
