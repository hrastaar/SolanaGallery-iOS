//
//  CollectionDetailViewController.swift
//  SolanaGallery
//
//  Created by Rastaar Haghi on 5/4/22.
//

import UIKit

class CollectionDetailViewController: UIViewController {

    let watchlistViewModel: WatchlistViewModel
    
    init(watchlistViewModel: WatchlistViewModel) {
        self.watchlistViewModel = watchlistViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print("Loading CollectionDetailViewController for symbol \(watchlistViewModel.getCollectionNameString())")
        view.backgroundColor = .systemBackground
        title = watchlistViewModel.getCollectionNameString()
    }
}
