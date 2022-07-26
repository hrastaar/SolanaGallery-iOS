//
//  WatchlistViewController.swift
//  SolanaGallery
//
//  Created by Rastaar Haghi on 4/27/22.
//

import NVActivityIndicatorView
import RxSwift
import UIKit

class WatchlistViewController: UIViewController {
    let watchlistListViewModel = WatchlistViewModel.sharedInstance

    let disposeBag = DisposeBag()

    private let refreshControl = UIRefreshControl()
    var loadingView: NVActivityIndicatorView?

    var tableView: UITableView = {
        var tableView = UITableView(frame: .zero)

        tableView.register(WatchlistTableViewCell.self, forCellReuseIdentifier: WatchlistTableViewCell.ReuseIdentifier)
        tableView.allowsMultipleSelectionDuringEditing = false
        tableView.layer.cornerRadius = Constants.UI.TableView.CornerRadius
        tableView.backgroundColor = .clear
        tableView.separatorColor = .clear
        tableView.showsVerticalScrollIndicator = false

        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Configure UI elements
        setupUI()

        // Configure tableview data source
        bindTableData()

        // Setup refresh control
        initializeTableViewRefreshControl()

        // Fetch watchlist collection data
        watchlistListViewModel.fetchWatchlistData()
    }
}

// MARK: Data Binding Implementation

extension WatchlistViewController {
    private func bindTableData() {
        // Reactively manage watch list items based on WatchlistListViewModel
        watchlistListViewModel.watchlistItems.bind(
            to: tableView.rx.items(
                cellIdentifier: WatchlistTableViewCell.ReuseIdentifier,
                cellType: WatchlistTableViewCell.self
            )
        ) { _, model, cell in
            cell.updateData(with: model)
        }.disposed(by: disposeBag)

        // Provide collection detail view controller if pressed
        tableView.rx.itemSelected
            .subscribe(onNext: {
                guard let cell = self.tableView.cellForRow(at: $0) as? WatchlistTableViewCell,
                      let watchlistViewModel = cell.watchlistViewModel
                else {
                    print("Couldn't identify cell pressed")
                    return
                }

                let detailVC = CollectionDetailViewController(collectionSymbol: watchlistViewModel.collectionStats.symbol, collectionName: watchlistViewModel.getCollectionNameString())

                self.navigationController?.pushViewController(detailVC, animated: true)

                self.tableView.deselectRow(at: $0, animated: true)
            }).disposed(by: disposeBag)
    }
}

// MARK: UI Implementation

extension WatchlistViewController {
    private func setupUI() {
        view.backgroundColor = ColorManager.backgroundColor
        setupNavigationTitle()

        view.addSubview(tableView)
        tableView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 10, paddingLeft: 10, paddingBottom: 10, paddingRight: 10, width: 0, height: 0, enableInsets: false)

        loadingView = NVActivityIndicatorView(frame: .init(x: view.bounds.width / 2.0 - 50, y: view.bounds.height / 2.0 - 50, width: 100.0, height: 100.0), type: .ballClipRotateMultiple, color: UIColor().getSolanaPurpleColor(), padding: 0)
        loadingView?.layer.zPosition = .greatestFiniteMagnitude

        guard let loadingView = loadingView else {
            print("Failed to create loading view")
            return
        }
        view.addSubview(loadingView)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    override func viewWillAppear(_: Bool) {
        refreshWatchlist(self)
    }

    private func initializeTableViewRefreshControl() {
        // Add Refresh Control to Table View
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        refreshControl.tintColor = .clear
        refreshControl.addTarget(self, action: #selector(refreshWatchlist(_:)), for: .valueChanged)
    }

    private func setupNavigationTitle() {
        let label = UILabel()
        label.textColor = .white
        label.text = "Watchlist"
        label.textAlignment = .center
        navigationItem.titleView = label
        label.translatesAutoresizingMaskIntoConstraints = false
    }

    @objc
    private func refreshWatchlist(_: Any) {
        DispatchQueue.main.async {
            self.loadingView?.startAnimating()
            self.refreshControl.endRefreshing()
            self.tableView.alpha = 0
        }
        watchlistListViewModel.fetchWatchlistData()

        watchlistListViewModel.watchlistItems.subscribe(onNext: { _ in
            DispatchQueue.main.async {
                self.loadingView?.stopAnimating()
                self.tableView.alpha = 1.0
            }
        }, onError: { _ in
            print("Error occurred when fetching watchlist items.")
            DispatchQueue.main.async {
                self.loadingView?.stopAnimating()
                self.tableView.alpha = 1.0
            }
        }).disposed(by: disposeBag)
    }
}
