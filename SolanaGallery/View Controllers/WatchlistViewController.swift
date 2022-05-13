//
//  WatchlistViewController.swift
//  SolanaGallery
//
//  Created by Rastaar Haghi on 4/27/22.
//

import UIKit
import RxSwift

class WatchlistViewController: UIViewController {

    let watchlistListViewModel = WatchlistListViewModel()
    let disposeBag = DisposeBag()

    static let cellIdentifier = "WatchlistTableViewCell"
    private let refreshControl = UIRefreshControl()

    var tableView: UITableView = {
        var tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(WatchlistTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.allowsMultipleSelectionDuringEditing = false

        return tableView
    }()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Watchlist"
        view.backgroundColor = .systemBackground

        view.addSubview(tableView)
        
        self.bindTableData()
        
        self.initializeTableViewRefreshControl()

        self.syncWatchlistCollections()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.tableView.frame = self.view.bounds
    }

    
    // Removes current watchlistItems from tableview and fetches up-to-date collection statistics via SolanaGalleryAPI
    private func syncWatchlistCollections() {
        do {
            let collections = try context.fetch(WatchlistItem.fetchRequest())
            watchlistListViewModel.fetchWatchlistData(watchlistItems: collections)
        } catch {
            print(error)
        }
    }
}

extension WatchlistViewController {

    private func bindTableData() {
        watchlistListViewModel.watchlistItems.bind(
            to: tableView.rx.items(
                cellIdentifier: WatchlistViewController.cellIdentifier,
                cellType: WatchlistTableViewCell.self)
        ) { row, model, cell in
            cell.updateData(with: model)
        }.disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .subscribe(onNext: {
                guard let cell = self.tableView.cellForRow(at: $0) as? WatchlistTableViewCell,
                    let watchlistViewModel = cell.watchlistViewModel else {
                  print("Couldn't identify cell pressed")
                  return
                }

                let detailVC = CollectionDetailViewController(watchlistViewModel: watchlistViewModel)
                self.navigationController?.pushViewController(detailVC, animated: true)

                self.tableView.deselectRow(at: $0, animated: true)
            }).disposed(by: disposeBag)
        
        tableView.rx.itemDeleted
            .subscribe(onNext: {
                guard let cell = self.tableView.cellForRow(at: $0) as? WatchlistTableViewCell,
                    let watchlistViewModel = cell.watchlistViewModel else {
                    print("Couldn't identify cell pressed")
                    return
                }
                self.removeCollectionFromWatchList(collectionName: watchlistViewModel.collectionStats.symbol)
            }).disposed(by: disposeBag)
    }
    
    private func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    private func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCell.EditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCell.EditingStyle.delete) {
            // handle delete (by removing the data from your array and updating the tableview)
            print("Delete operation invoked on indexPatch \(indexPath.row)")
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    private func reloadTableView() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    private func initializeTableViewRefreshControl() {
        // Add Refresh Control to Table View
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        // Configure Refresh Control
        refreshControl.tintColor = UIColor().getSolanaPurpleColor()
        refreshControl.attributedTitle = NSAttributedString("Refreshing Watchlist Data")

        refreshControl.addTarget(self, action: #selector(refreshWatchlist(_:)), for: .valueChanged)
    }
    
    @objc private func refreshWatchlist(_ sender: Any) {
        syncWatchlistCollections()
        DispatchQueue.main.async {
            self.refreshControl.endRefreshing()
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
    func removeCollectionFromWatchList(collectionName: String) {
        do {
            let collections = try context.fetch(WatchlistItem.fetchRequest())
            watchlistListViewModel.fetchWatchlistData(watchlistItems: collections)
            
            let itemsToDelete = collections.filter { $0.collectionName == collectionName }

            guard let itemToDelete = itemsToDelete.first else {
                return
            }
            context.delete(itemToDelete)
            try context.save()
            
            self.watchlistListViewModel.removeItemsFromWatchlist(collectionName: collectionName)
        } catch {
            print(error)
        }
    }
    
    private func populateWithCollections() {
        addCollectionToWatchlist(collectionName: "atadians")
        addCollectionToWatchlist(collectionName: "okay_bears")
        addCollectionToWatchlist(collectionName: "quantum_traders")
        addCollectionToWatchlist(collectionName: "solstein")
        addCollectionToWatchlist(collectionName: "thugbirdz")
        addCollectionToWatchlist(collectionName: "meerkat_millionaires_country_club")
        addCollectionToWatchlist(collectionName: "naked_meerkats_beach_club")
    }
}
