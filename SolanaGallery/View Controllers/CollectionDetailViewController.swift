//
//  CollectionDetailViewController.swift
//  SolanaGallery
//
//  Created by Rastaar Haghi on 5/4/22.
//

import UIKit
import RxSwift
import RxCocoa

class CollectionDetailViewController: UIViewController {

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
        watchlistActionButton.titleLabel?.textColor = .white
        watchlistActionButton.titleLabel?.font = .primaryFont(size: 14)
        view.addSubview(watchlistActionButton)
        watchlistActionButton.anchor(top: statisticsView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 15, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: 0, height: 25, enableInsets: false)
        collectionDetailViewModel.isOnWatchlist.map { $0 ? "Watching" : "Add to Watchlist" }.bind(to: watchlistActionButton.rx.title()).disposed(by: disposeBag)
        _ = collectionDetailViewModel.isInWatchlist(collectionSymbol: collectionSymbol)
        watchlistActionButton.isUserInteractionEnabled = true
        watchlistActionButton.addTarget(self, action: #selector(toggleWatchlistStatus), for: .touchUpInside)
    }
}
