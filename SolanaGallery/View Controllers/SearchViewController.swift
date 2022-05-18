//
//  SearchViewController.swift
//  SolanaGallery
//
//  Created by Rastaar Haghi on 5/4/22.
//

import UIKit
import RxSwift
import RxCocoa

class SearchViewController: UIViewController {
    static let cellIdentifier = "CollectionSearchResultTableViewCell"
    
    let searchTextField: UITextField = {
        let textField = UITextField(frame: .zero)
        textField.placeholder = "Search for a collection"
        textField.backgroundColor = .secondarySystemFill
        textField.layer.cornerRadius = 10
        textField.adjustsFontSizeToFitWidth = true
        textField.font = UIFont.primaryFont(size: 15)

        return textField
    }()
    
    let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(CollectionSearchResultTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.alpha = 0.0
        tableView.allowsMultipleSelectionDuringEditing = false
        return tableView
    }()
    
    let collectionSearchViewModel = CollectionSearchViewModel()
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindTableView()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground

        view.addSubview(searchTextField)
        view.addSubview(tableView)
        
        searchTextField.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 100, paddingLeft: 10, paddingBottom: 10, paddingRight: 10, width: view.bounds.width * 0.75, height: 50, enableInsets: false)
        
        tableView.anchor(top: searchTextField.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 10, paddingLeft: 10, paddingBottom: 10, paddingRight: 10, width: 0, height: 0, enableInsets: false)
        
        searchTextField.rx.controlEvent(.allEditingEvents)
            .subscribe(onNext: { event in
                guard let searchText = self.searchTextField.text else {
                    return
                }
                self.collectionSearchViewModel.filterSearchResults(searchInput: searchText)
            }).disposed(by: disposeBag)
    }
    
    private func bindTableView() {
        collectionSearchViewModel.collectionSearchResults.bind(
            to: tableView.rx.items(
                cellIdentifier: SearchViewController.cellIdentifier,
                cellType: CollectionSearchResultTableViewCell.self)
        ) { row, model, cell in
            cell.updateData(with: model)
        }.disposed(by: disposeBag)
        
        collectionSearchViewModel.collectionSearchResults.subscribe { observer in
            if (observer.isCompleted) {
                print(observer)
            }
        }
        
        tableView.rx.modelSelected(CollectionSearchResult.self).bind { collection in
            print(collection.symbol)
        }.disposed(by: disposeBag)
    }
}
