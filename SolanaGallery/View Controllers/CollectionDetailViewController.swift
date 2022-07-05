//
//  CollectionDetailViewController.swift
//  SolanaGallery
//
//  Created by Rastaar Haghi on 5/4/22.
//

import UIKit
import SafariServices
import RxSwift
import RxCocoa

class CollectionDetailViewController: UIViewController, UIScrollViewDelegate {

    let collectionSymbol: String
    let collectionName: String
        
    let collectionDetailViewModel = CollectionDetailViewModel()
    let watchlistViewModel = WatchlistViewModel.sharedInstance
    
    let disposeBag = DisposeBag()
    
    let statisticsView: UIView = {
        let view = UIView()
        
        view.backgroundColor = ColorManager.primaryCellColor
        view.layer.cornerRadius = 20
        
        return view
    }()
    
    var buyCollectionButton: UIButton?
    var watchlistButton: UIButton?
    
    var listingsScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceHorizontal = true
        scrollView.backgroundColor = .clear
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    init(collectionSymbol: String, collectionName: String) {
        self.collectionSymbol = collectionSymbol
        self.collectionName = collectionName
        super.init(nibName: nil, bundle: nil)
        collectionDetailViewModel.fetchCollectionDetailsInfo(collectionSymbol: collectionSymbol)
        _ = watchlistViewModel.isInWatchlist(collectionSymbol: collectionSymbol)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = ColorManager.backgroundColor
        self.navigationController?.navigationBar.backItem?.title = ""
        setupNavigationTitle()
        // Create UIView that displays basic collection statistics
        setupStatisticsView()
        
        self.buyCollectionButton = setupBuyCollectionButton()
        
        // Create button that toggles adding a collection to watchlist
        self.watchlistButton = setupWatchlistButton()

        // Construct stack view with live listings once data fetched
        collectionDetailViewModel.listings.subscribe { listingEvent in
            guard let elements = listingEvent.element else {
                return
            }
            self.fillListingStackView(with: elements)
        }.disposed(by: disposeBag)

    }
    
    @objc func toggleWatchlistStatus() {
        watchlistViewModel.toggleCollectionInWatchlist(collectionSymbol: self.collectionSymbol)
    }
    
    private func setupStatisticsView() {
        view.addSubview(statisticsView)
        statisticsView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 10, paddingLeft: 10, paddingBottom: 10, paddingRight: 10, width: 0, height: 80, enableInsets: false)
        
        // Create information labels and provide default values
        let floorValueLabel = UILabel()
        floorValueLabel.textColor = .white
        
        let listedCountValueLabel = UILabel()
        listedCountValueLabel.textColor = .white
        
        let floorValueCategoryLabel = UILabel()
        floorValueCategoryLabel.textColor = .white
        
        let listedCountCategoryLabel = UILabel()
        listedCountCategoryLabel.textColor = .white
        
        DispatchQueue.main.async {
            floorValueLabel.text = "0◎"
            floorValueLabel.font = .primaryFont(size: 14)
            
            listedCountValueLabel.text = "0"
            listedCountValueLabel.font = .primaryFont(size: 14)
            
            floorValueCategoryLabel.text = "Floor Price"
            floorValueCategoryLabel.font = .primaryFont(size: 14)
            
            listedCountCategoryLabel.text = "Number of NFT's Listed"
            listedCountCategoryLabel.font = .primaryFont(size: 14)
        }
        
        // Add binding to update statistics whenever model values change
        collectionDetailViewModel.stats.bind(onNext: { stats in
            guard let stats = stats else {
                return
            }
            let floorPriceString = String(format:"%.2f◎", stats.floorPrice)
            let listedCountString = String(stats.listedCount)
            DispatchQueue.main.async {
                floorValueLabel.text = floorPriceString
                listedCountValueLabel.text = listedCountString
            }

        }).disposed(by: disposeBag)
        
        let floorValueStackView = UIStackView(arrangedSubviews: [floorValueLabel, floorValueCategoryLabel])
        floorValueStackView.axis = .vertical
        floorValueStackView.alignment = .center
        floorValueStackView.spacing = 10
        statisticsView.addSubview(floorValueStackView)
        
        floorValueStackView.anchor(top: nil, left: statisticsView.leftAnchor, bottom: nil, right: statisticsView.centerXAnchor, paddingTop: 10, paddingLeft: 10, paddingBottom: 10, paddingRight: 10, width: 0, height: 0, enableInsets: false)
        floorValueStackView.centerYAnchor.constraint(equalTo: statisticsView.centerYAnchor).isActive = true

        let listedCountStackView = UIStackView(arrangedSubviews: [listedCountValueLabel, listedCountCategoryLabel])
        listedCountStackView.axis = .vertical
        listedCountStackView.alignment = .center
        listedCountStackView.spacing = 10
        statisticsView.addSubview(listedCountStackView)
        
        listedCountStackView.anchor(top: nil, left: statisticsView.centerXAnchor, bottom: nil, right: statisticsView.rightAnchor, paddingTop: 10, paddingLeft: 10, paddingBottom: 10, paddingRight: 10, width: 0, height: 0, enableInsets: false)
        listedCountStackView.centerYAnchor.constraint(equalTo: statisticsView.centerYAnchor).isActive = true
    }
    
    private func setupWatchlistButton() -> UIButton {
        let watchlistActionButton = UIButton()
        watchlistActionButton.layer.cornerRadius = Constants.UI.Button.CornerRadius
        watchlistActionButton.backgroundColor = ColorManager.primaryCellColor
        watchlistActionButton.titleLabel?.textColor = .white
        watchlistActionButton.titleLabel?.font = .primaryFont(size: 16)
        watchlistActionButton.titleLabel?.textAlignment = .center
        view.addSubview(watchlistActionButton)
        
        // Apply constraints to button
        watchlistActionButton.anchor(top: statisticsView.bottomAnchor, left: nil, bottom: nil, right: view.rightAnchor, paddingTop: 10, paddingLeft: 0, paddingBottom: 10, paddingRight: 10, width: 100, height: 40, enableInsets: false)
        
        watchlistViewModel.isOnWatchlist.map { $0 ? "Unfollow" : "Follow" }.bind(to: watchlistActionButton.rx.title()).disposed(by: disposeBag)
        _ = watchlistViewModel.isInWatchlist(collectionSymbol: collectionSymbol)
        watchlistActionButton.isUserInteractionEnabled = true
        watchlistActionButton.addTarget(self, action: #selector(toggleWatchlistStatus), for: .touchUpInside)
        
        return watchlistActionButton
    }
    
    private func setupBuyCollectionButton() -> UIButton {
        let buyOnMagicEdenButton = UIButton()
        buyOnMagicEdenButton.layer.cornerRadius = Constants.UI.Button.CornerRadius
        buyOnMagicEdenButton.backgroundColor = ColorManager.primaryCellColor
        buyOnMagicEdenButton.titleLabel?.textColor = .white
        buyOnMagicEdenButton.titleLabel?.font = .primaryFont(size: 16)
        buyOnMagicEdenButton.titleLabel?.textAlignment = .center
        buyOnMagicEdenButton.setTitle("Buy on MagicEden", for: .normal)
        view.addSubview(buyOnMagicEdenButton)
        
        // Apply constraints to button
        buyOnMagicEdenButton.anchor(top: statisticsView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 10, paddingLeft: 10, paddingBottom: 10, paddingRight: 10, width: 150, height: 40, enableInsets: false)

        buyOnMagicEdenButton.isUserInteractionEnabled = true
        buyOnMagicEdenButton.addTarget(self, action: #selector(openMagicEdenCollectionSafariPage), for: .touchUpInside)
        
        return buyOnMagicEdenButton
    }
    
    // Creates scroll view containing current listings (fetched from Magiceden)
    private func fillListingStackView(with collectionListings: [CollectionListing]) {
        DispatchQueue.main.async {
            self.view.addSubview(self.listingsScrollView)
            self.listingsScrollView.topAnchor.constraint(equalTo: self.watchlistButton?.bottomAnchor ?? self.statisticsView.bottomAnchor, constant: 10).isActive = true
            self.listingsScrollView.heightAnchor.constraint(equalToConstant: 250).isActive = true
            self.listingsScrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 12.5).isActive = true
            self.listingsScrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -12.5).isActive = true
            
            // Stack view that contains listing views
            let stackView = UIStackView()
            stackView.axis = .horizontal
            stackView.distribution = .equalSpacing
            stackView.spacing = 15
            stackView.alignment = .fill
            stackView.translatesAutoresizingMaskIntoConstraints = false
            self.listingsScrollView.addSubview(stackView)

            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.topAnchor.constraint(equalTo: self.listingsScrollView.topAnchor).isActive = true
            stackView.leadingAnchor.constraint(equalTo: self.listingsScrollView.leadingAnchor).isActive = true
            stackView.trailingAnchor.constraint(equalTo: self.listingsScrollView.trailingAnchor).isActive = true
            stackView.bottomAnchor.constraint(equalTo: self.listingsScrollView.bottomAnchor).isActive = true
            stackView.heightAnchor.constraint(equalTo: self.listingsScrollView.heightAnchor).isActive = true
        
            for collectionListing in collectionListings {
                let listingView = ListingView(listing: collectionListing, frame: .init(x: 0, y: 0, width: 400, height: stackView.bounds.height))
                listingView.translatesAutoresizingMaskIntoConstraints = false
                
                let gesture = UITapGestureRecognizer(target: self, action:  #selector(self.openMagicEdenListingSafariPage(_:)))
                listingView.addGestureRecognizer(gesture)
                stackView.addArrangedSubview(listingView)
            }
        }
    }
    
    private func setupNavigationTitle() {
        let label = UILabel()
        label.textColor = .white
        label.text = collectionName
        label.textAlignment = .center
        self.navigationItem.titleView = label
        label.translatesAutoresizingMaskIntoConstraints = false
    }
    
    // Action for when a ListingView is pressed, opens SFSafariViewController for listing
    @objc
    func openMagicEdenListingSafariPage(_ sender: UITapGestureRecognizer? = nil) {
        guard let listingView = sender?.view as? ListingView else {
            return
        }
        let listingUrlString = Constants.getMagicEdenListingUrl(with: listingView.listing.tokenMint)
        
        if let url = listingUrlString {
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = true

            let vc = SFSafariViewController(url: url, configuration: config)
            present(vc, animated: true)
        }
    }
    
    @objc
    func openMagicEdenCollectionSafariPage(_ sender: UITapGestureRecognizer? = nil) {
        if let url = Constants.getMagicEdenCollectionUrl(with: collectionSymbol) {
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = true

            let vc = SFSafariViewController(url: url, configuration: config)
            present(vc, animated: true)
        }
    }
}
