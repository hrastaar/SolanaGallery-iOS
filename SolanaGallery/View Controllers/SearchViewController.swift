//
//  SearchViewController.swift
//  SolanaGallery
//
//  Created by Rastaar Haghi on 5/4/22.
//

import RxCocoa
import RxSwift
import UIKit

class SearchViewController: UIViewController {
    // Manage Data Models
    let collectionSearchViewModel = CollectionSearchViewModel()

    let disposeBag = DisposeBag()

    let searchTextField: TextField = {
        let textField = TextField(frame: .zero)

        textField.placeholder = "Search for a collection"
        textField.backgroundColor = ColorManager.primaryCellColor
        textField.textColor = .white
        textField.layer.cornerRadius = Constants.UI.TextField.CornerRadius
        textField.adjustsFontSizeToFitWidth = true
        textField.font = UIFont.primaryFont(size: 15)
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no

        return textField
    }()

    let tableView: UITableView = {
        var tableView = UITableView(frame: .zero)

        tableView.register(CollectionSearchResultTableViewCell.self, forCellReuseIdentifier: CollectionSearchResultTableViewCell.ReuseIdentifier)
        tableView.allowsMultipleSelectionDuringEditing = false
        tableView.layer.cornerRadius = Constants.UI.TableView.CornerRadius
        tableView.backgroundColor = .clear
        tableView.separatorColor = .clear

        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorManager.backgroundColor
        // Position + arrange UI
        setupUI()
        // Use RxCocoa to bind data to tableview reactively
        bindTableView()
    }

    private func setupUI() {
        setupNavigationTitle()
        view.addSubview(searchTextField)
        view.addSubview(tableView)

        searchTextField.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 25, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width: 0, height: 50, enableInsets: false)

        tableView.anchor(top: searchTextField.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 10, paddingLeft: 10, paddingBottom: 10, paddingRight: 10, width: 0, height: 0, enableInsets: false)
    }

    private func setupNavigationTitle() {
        let label = UILabel()
        label.text = "Search"
        label.textColor = .white
        label.textAlignment = .center
        navigationItem.titleView = label
        label.translatesAutoresizingMaskIntoConstraints = false
    }
}

extension SearchViewController: UITableViewDelegate {
    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return 75
    }
}

// MARK: Data Binding

extension SearchViewController {
    private func bindTableView() {
        tableView
            .rx.setDelegate(self)
            .disposed(by: disposeBag)
        // Configure search text field to update search request per each text event
        searchTextField.rx.controlEvent(.allEditingEvents)
            .subscribe(onNext: { _ in
                guard let searchText = self.searchTextField.text else {
                    return
                }
                self.collectionSearchViewModel.filterSearchResults(searchInput: searchText)
            }).disposed(by: disposeBag)

        // Bind search results data from view model to table view
        collectionSearchViewModel.collectionSearchResults.bind(
            to: tableView.rx.items(
                cellIdentifier: CollectionSearchResultTableViewCell.ReuseIdentifier,
                cellType: CollectionSearchResultTableViewCell.self
            )
        ) { _, model, cell in
            cell.updateData(with: model)
        }.disposed(by: disposeBag)

        // Open collection detail view controller when a search result is selected
        tableView.rx.itemSelected
            .subscribe(onNext: {
                guard let cell = self.tableView.cellForRow(at: $0) as? CollectionSearchResultTableViewCell,
                      let symbol = cell.searchResult?.symbol,
                      let collectionName = cell.searchResult?.name
                else {
                    print("Couldn't identify cell pressed")
                    return
                }

                let detailVC = CollectionDetailViewController(collectionSymbol: symbol, collectionName: collectionName)
                self.navigationController?.pushViewController(detailVC, animated: true)

                // Deselect row, clear search text, remove search results
                self.tableView.deselectRow(at: $0, animated: true)
                self.searchTextField.text = ""
                self.collectionSearchViewModel.clearSearchResults()
            }).disposed(by: disposeBag)
    }
}
