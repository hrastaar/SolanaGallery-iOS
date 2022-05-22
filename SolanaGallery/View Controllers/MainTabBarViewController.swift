//
//  MainTabBarViewController.swift
//  SolanaGallery
//
//  Created by Rastaar Haghi on 4/28/22.
//

import UIKit

class MainTabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBarViewControllers()
    }
    
    private func setupTabBarViewControllers() {
        
        let searchVC = UINavigationController(rootViewController: SearchViewController())
        searchVC.tabBarItem.image = UIImage(systemName: "magnifyingglass")
        searchVC.tabBarItem.title = "Search"
        
        let walletTrackerVC = UINavigationController(rootViewController: WalletTrackerViewController())
        walletTrackerVC.tabBarItem.title = "Portfolio"

        let watchlistVC = UINavigationController(rootViewController: WatchlistViewController())
        watchlistVC.tabBarItem.image = UIImage(systemName: "bookmark")
        watchlistVC.tabBarItem.title = "Watchlist"
        
        tabBar.tintColor = .label
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont.primaryFont(size: 12)], for: .normal)

        setViewControllers([searchVC, walletTrackerVC, watchlistVC], animated: true)
    }
    
    private func setupNavigationTitle(with titleName: String) -> UILabel {
        let label = UILabel()
        label.text = titleName
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        label.anchor(top: navigationController?.navigationBar.topAnchor, left: navigationController?.navigationBar.leftAnchor, bottom: navigationController?.navigationBar.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: navigationController?.navigationBar.bounds.width ?? 0, height: 0, enableInsets: false)
        return label
    }
}
