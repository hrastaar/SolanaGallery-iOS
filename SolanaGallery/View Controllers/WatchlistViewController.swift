//
//  WatchlistViewController.swift
//  SolanaGallery
//
//  Created by Rastaar Haghi on 4/27/22.
//

import UIKit
import RxSwift

class WatchlistViewController: UIViewController {
    let watchlistListViewModel = WatchlistViewModel()
    let disposeBag = DisposeBag()

    private let refreshControl = UIRefreshControl()
    
    var tableView: UITableView = {
        var tableView = UITableView(frame: .zero)
        tableView.register(WatchlistTableViewCell.self, forCellReuseIdentifier: WatchlistTableViewCell.ReuseIdentifier)
        tableView.allowsMultipleSelectionDuringEditing = false
        tableView.layer.cornerRadius = Constants.UI.TableView.CornerRadius
        tableView.backgroundColor = .clear
        tableView.separatorColor = .clear
        
        return tableView
    }()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        // Configure tableview data source (using rxswift/rxcocoa)
        self.bindTableData()
        
        // Setup refresh control
        self.initializeTableViewRefreshControl()
        
        // Fetch watchlist collection data
        self.syncWatchlistCollections()
    }
    
    private func setupUI() {
        view.backgroundColor = ColorManager.backgroundColor
        setupNavigationTitle()
        
        view.addSubview(tableView)
        tableView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 10, paddingLeft: 10, paddingBottom: 10, paddingRight: 10, width: 0, height: 0, enableInsets: false)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        refreshWatchlist(self)
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
        // Reactively manage watch list items based on WatchlistListViewModel
        watchlistListViewModel.watchlistItems.bind(
            to: tableView.rx.items(
                cellIdentifier: WatchlistTableViewCell.ReuseIdentifier,
                cellType: WatchlistTableViewCell.self)
        ) { row, model, cell in
            cell.updateData(with: model)
        }.disposed(by: disposeBag)
        
        // Provide collection detail view controller if pressed
        tableView.rx.itemSelected
            .subscribe(onNext: {
                guard let cell = self.tableView.cellForRow(at: $0) as? WatchlistTableViewCell,
                    let watchlistViewModel = cell.watchlistViewModel else {
                  print("Couldn't identify cell pressed")
                  return
                }
                
                let detailVC = CollectionDetailViewController(collectionSymbol: watchlistViewModel.collectionStats.symbol, collectionName: watchlistViewModel.getCollectionNameString())
                self.navigationController?.pushViewController(detailVC, animated: true)

                self.tableView.deselectRow(at: $0, animated: true)
            }).disposed(by: disposeBag)
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
    
    private func setupNavigationTitle() {
        let label = UILabel()
        label.text = "Watchlist"
        label.textAlignment = .center
        self.navigationItem.titleView = label
        label.translatesAutoresizingMaskIntoConstraints = false
        label.anchor(top: navigationController?.navigationBar.topAnchor, left: navigationController?.navigationBar.leftAnchor, bottom: navigationController?.navigationBar.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: navigationController?.navigationBar.bounds.width ?? 0, height: 0, enableInsets: false)
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
}
