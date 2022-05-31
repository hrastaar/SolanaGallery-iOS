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
    
    let colorManager = ColorManager.sharedInstance
    
    let collectionDetailViewModel = CollectionDetailViewModel()
    let disposeBag = DisposeBag()
    let statisticsView: UIView = {
        let view = UIView()
        view.backgroundColor = ColorManager.sharedInstance.primaryCellColor
        view.layer.cornerRadius = 20
        
        return view
    }()
    
    var watchlistButton: UIButton?
    
    var listingsScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceHorizontal = true
        scrollView.backgroundColor = .clear
        return scrollView
    }()
    
    init(collectionSymbol: String, collectionName: String) {
        self.collectionSymbol = collectionSymbol
        self.collectionName = collectionName
        super.init(nibName: nil, bundle: nil)
        collectionDetailViewModel.fetchCollectionDetailsInfo(collectionSymbol: collectionSymbol)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = colorManager.backgroundColor
        title = collectionName
        // Create UIView that displays basic collection statistics
        setupStatisticsView()
        // Create button that toggles adding a collection to watchlist
        setupWatchlistButton()

        // Construct stack view with live listings once data fetched
        collectionDetailViewModel.listings.subscribe { listingEvent in
            guard let elements = listingEvent.element else {
                return
            }
            self.fillListingStackView(with: elements)
        }.disposed(by: disposeBag)

    }
    
    @objc func toggleWatchlistStatus() {
        collectionDetailViewModel.toggleCollectionInWatchlist(collectionSymbol: self.collectionSymbol)
    }
    
    private func setupStatisticsView() {
        view.addSubview(statisticsView)
        statisticsView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 10, paddingLeft: 10, paddingBottom: 10, paddingRight: 10, width: 0, height: 80, enableInsets: false)
        
        // Create information labels and provide default values
        let floorValueLabel = UILabel()
        let listedCountValueLabel = UILabel()
        let floorValueCategoryLabel = UILabel()
        let listedCountCategoryLabel = UILabel()
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
    
    private func setupWatchlistButton() {
        let watchlistActionButton = UIButton()
        self.watchlistButton = watchlistActionButton
        watchlistActionButton.titleLabel?.textColor = .white
        watchlistActionButton.titleLabel?.font = .primaryFont(size: 14)
        view.addSubview(watchlistActionButton)
        watchlistActionButton.anchor(top: statisticsView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 15, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: 0, height: 25, enableInsets: false)
        collectionDetailViewModel.isOnWatchlist.map { $0 ? "Watching" : "Add to Watchlist" }.bind(to: watchlistActionButton.rx.title()).disposed(by: disposeBag)
        _ = collectionDetailViewModel.isInWatchlist(collectionSymbol: collectionSymbol)
        watchlistActionButton.isUserInteractionEnabled = true
        watchlistActionButton.addTarget(self, action: #selector(toggleWatchlistStatus), for: .touchUpInside)
    }
    
    private func fillListingStackView(with collectionListings: [CollectionListing]) {
        DispatchQueue.main.async {

            print(collectionListings)
            self.view.addSubview(self.listingsScrollView)
            self.listingsScrollView.topAnchor.constraint(equalTo: self.watchlistButton?.bottomAnchor ?? self.statisticsView.bottomAnchor).isActive = true
            self.listingsScrollView.heightAnchor.constraint(equalToConstant: 250).isActive = true
            self.listingsScrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 12.5).isActive = true
            self.listingsScrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -12.5).isActive = true
            
            
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
                
                let gesture = UITapGestureRecognizer(target: self, action:  #selector(self.handleTap(_:)))
                listingView.addGestureRecognizer(gesture)
                stackView.addArrangedSubview(listingView)
            }
        }
    }
    
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        guard let listingView = sender?.view as? ListingView else {
            return
        }
        let listingUrlString = Constants.constructMagicedenListingUrl(with: listingView.listing.tokenMint)
        
        if let url = listingUrlString {
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = true

            let vc = SFSafariViewController(url: url, configuration: config)
            present(vc, animated: true)
        }
    }
}
