//
//  WatchlistViewController.swift
//  SolanaGallery
//
//  Created by Rastaar Haghi on 4/27/22.
//

import UIKit

class WatchlistViewController: UIViewController {

    let cellIdentifier = "WatchlistTableViewCell"
    
    var tableView: UITableView = {
        var tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var watchlistItems = [WatchlistViewModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Watchlist"
        view.backgroundColor = .systemBackground

        view.addSubview(tableView)

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(WatchlistTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.allowsMultipleSelectionDuringEditing = false

        syncWatchlistCollections()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.tableView.frame = self.view.bounds
    }
    
    private func syncWatchlistCollections() {
        self.watchlistItems.removeAll()
        do {
            let collections = try context.fetch(WatchlistItem.fetchRequest())
            for collection in collections {
                if let collectionName = collection.collectionName {
                    SolanaGalleryAPI.sharedInstance.getNftCollectionStats(collectionName: collectionName) { stats in
                        if let stats = stats {
                            let watchlistViewModel = WatchlistViewModel(withCollectionStats: stats, coreDataItem: collection)
                            self.watchlistItems.append(watchlistViewModel)
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        }

                    }
                }
            }
        } catch {
            print("error getting watchlist items")
        }

    }
}
// MARK: UITableView Extension

extension WatchlistViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return watchlistItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! WatchlistTableViewCell

        cell.updateData(with: watchlistItems[indexPath.row])

        return cell
    }
    
    private func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    private func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCell.EditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCell.EditingStyle.delete) {
            // handle delete (by removing the data from your array and updating the tableview)
            print("delete")
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            let item = watchlistItems[indexPath.row]
            watchlistItems.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            removeCollectionFromWatchList(item: item.coreDataItem)
        }
    }
}

// MARK: CoreData Save Interactions
extension WatchlistViewController {
    // Save new collection to CoreData
    func addCollectionToWatchlist(collectionName: String) {
        do {
            let items = try context.fetch(WatchlistItem.fetchRequest())
            
            // check if collection is duplicate
            if !(items.filter {$0.collectionName == collectionName}).isEmpty {
                return
            }
            let newItem = WatchlistItem(context: context)
            newItem.collectionName = collectionName
            newItem.order = Int16(items.count)
            
            try context.save()
        } catch {
            print("error saving watchlist item")
        }
    }
    
    // Remove a collection from CoreData (call when delete action in WatchlistTableViewCell)
    func removeCollectionFromWatchList(item: WatchlistItem) {
        context.delete(item)
        do {
            try context.save()
        } catch {
            print("error deleting collection from watchlist")
        }
    }
}
