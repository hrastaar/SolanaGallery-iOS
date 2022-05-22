//
//  SearchViewController.swift
//  SolanaGallery
//
//  Created by Rastaar Haghi on 5/4/22.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class SearchViewController: UIViewController {
    // Manage Data Models
    let collectionSearchViewModel = CollectionSearchViewModel()

    let disposeBag = DisposeBag()

    let searchTextField: UITextField = {
        let textField = UITextField(frame: .zero)
        textField.placeholder = "Search for a collection"
        textField.backgroundColor = .secondarySystemFill
        textField.layer.cornerRadius = 10
        textField.adjustsFontSizeToFitWidth = true
        textField.font = UIFont.primaryFont(size: 15)
        textField.autocapitalizationType = .none

        return textField
    }()
    
    let tableView: UITableView = {
        var tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(CollectionSearchResultTableViewCell.self, forCellReuseIdentifier: CollectionSearchResultTableViewCell.ReuseIdentifier)
        tableView.allowsMultipleSelectionDuringEditing = false
        tableView.layer.cornerRadius = 10
        return tableView
    }()


    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        // Position + arrange UI
        setupUI()
        
        // Use RxCocoa to bind data to tableview reactively
        bindTableView()

    }
    
    private func setupUI() {
        view.addSubview(searchTextField)
        view.addSubview(tableView)
        
        searchTextField.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 100, paddingLeft: 10, paddingBottom: 10, paddingRight: 10, width: view.bounds.width * 0.75, height: 50, enableInsets: false)
        
        tableView.anchor(top: searchTextField.bottomAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingTop: 10, paddingLeft: 10, paddingBottom: 10, paddingRight: 10, width: 0, height: 0, enableInsets: false)

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
                cellIdentifier: CollectionSearchResultTableViewCell.ReuseIdentifier,
                cellType: CollectionSearchResultTableViewCell.self)
        ) { row, model, cell in
            cell.updateData(with: model)
        }.disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .subscribe(onNext: {
                guard let cell = self.tableView.cellForRow(at: $0) as? CollectionSearchResultTableViewCell,
                      let symbol = cell.searchResult?.symbol else {
                  print("Couldn't identify cell pressed")
                  return
                }

                let detailVC = CollectionDetailViewController(collectionSymbol: symbol)
                self.navigationController?.pushViewController(detailVC, animated: true)

                self.tableView.deselectRow(at: $0, animated: true)
            }).disposed(by: disposeBag)
    }
}
