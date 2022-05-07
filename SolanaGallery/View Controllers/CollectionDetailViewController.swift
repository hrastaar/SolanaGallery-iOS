//
//  CollectionDetailViewController.swift
//  SolanaGallery
//
//  Created by Rastaar Haghi on 5/4/22.
//

import UIKit

class CollectionDetailViewController: UIViewController {

    let collectionSymbol: String
    
    init(collectionSymbol: String) {
        self.collectionSymbol = collectionSymbol
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print("Loading CollectionDetailViewController for symbol \(self.collectionSymbol)")
        view.backgroundColor = .systemBackground
        title = self.collectionSymbol
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
