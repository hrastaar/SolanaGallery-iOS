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
        let homepageVC = UINavigationController(rootViewController: HomePageViewController())
        homepageVC.tabBarItem.image = UIImage(systemName: "house")
        homepageVC.tabBarItem.title = "Home"
        
        let watchlistVC = UINavigationController(rootViewController: WatchlistViewController())
        watchlistVC.tabBarItem.image = UIImage(systemName: "bookmark")
        watchlistVC.tabBarItem.title = "Watchlist"
        
        let searchVC = UINavigationController(rootViewController: SearchViewController())
        searchVC.tabBarItem.image = UIImage(systemName: "magnifyingglass")
        searchVC.tabBarItem.title = "Search"
        
        tabBar.tintColor = .label
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont.primaryFont(size: 12)], for: .normal)

        
        setViewControllers([homepageVC, searchVC, watchlistVC], animated: true)
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
