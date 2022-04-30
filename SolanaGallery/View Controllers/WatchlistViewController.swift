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
                            let watchlistViewModel = WatchlistViewModel(withCollectionStats: stats)
                            self.watchlistItems.append(watchlistViewModel)
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        } else {
                            print("HERE with collection: ", collectionName)
                        }

                    }
                }
            }
        } catch {
            print("error getting watchlist items")
        }

    }
    
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
    
    func removeCollectionFromWatchList(item: WatchlistItem) {
        context.delete(item)
        
        do {
            try context.save()
        } catch {
            print("error deleting collection from watchlist")
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension WatchlistViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return watchlistItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! WatchlistTableViewCell
        cell.updateData(with: watchlistItems[indexPath.row])
        return cell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCell.EditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCell.EditingStyle.delete) {
            // handle delete (by removing the data from your array and updating the tableview)
            print("delete")
        }
    }
}
