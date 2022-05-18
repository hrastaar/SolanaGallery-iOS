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

        view.backgroundColor = .blue
        
        setupTabBarViewControllers()
    }
    
    private func setupTabBarViewControllers() {
        let watchlistVC = UINavigationController(rootViewController: WatchlistViewController())
        watchlistVC.tabBarItem.image = UIImage(systemName: "bookmark")
        watchlistVC.tabBarItem.title = "Watchlist"
        
        let walletTrackerVC = UINavigationController(rootViewController: WalletTrackerViewController())
        walletTrackerVC.tabBarItem.title = "Portfolio"
        
        let searchVC = UINavigationController(rootViewController: SearchViewController())
        searchVC.tabBarItem.image = UIImage(systemName: "magnifyingglass")
        searchVC.tabBarItem.title = "Search"
        
        tabBar.tintColor = .label
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont.primaryFont(size: 12)], for: .normal)

        setViewControllers([searchVC, walletTrackerVC, watchlistVC], animated: true)
    }
}
