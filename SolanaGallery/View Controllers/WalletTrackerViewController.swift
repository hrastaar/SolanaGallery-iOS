//
//  WalletTrackerViewController.swift
//  SolanaGallery
//
//  Created by Rastaar Haghi on 5/8/22.
//

import RxCocoa
import RxSwift
import UIKit

class WalletTrackerViewController: UIViewController {
    let walletAddressViewModel = WalletAddressViewModel()

    let disposeBag = DisposeBag()

    let portfolioViewModel = PortfolioViewModel()

    let walletSearchTextField: TextField = {
        let textField = TextField(frame: .zero)

        textField.textColor = .white
        textField.placeholder = "Enter a valid Solana Wallet Address"
        textField.backgroundColor = ColorManager.primaryCellColor
        textField.layer.cornerRadius = Constants.UI.TextField.CornerRadius
        textField.adjustsFontSizeToFitWidth = true
        textField.font = UIFont.primaryFont(size: 15)
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no

        return textField
    }()

    let searchButton: UIButton = {
        let button = UIButton()

        button.tintColor = .white
        button.setTitle("Search", for: .normal)
        button.backgroundColor = ColorManager.primaryCellColor
        button.layer.cornerRadius = Constants.UI.Button.CornerRadius
        button.isEnabled = false
        button.alpha = 0.1
        button.titleLabel?.font = UIFont.primaryFont(size: 15)

        return button
    }()

    let portfolioTotalValueLabel: UILabel = {
        let label = UILabel()

        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.alpha = 0.0
        label.font = UIFont.primaryFont(size: 18)
        label.textColor = .white
        label.textAlignment = .center

        return label
    }()

    var tableView: UITableView = {
        var tableView = UITableView(frame: .zero)

        tableView.register(PortfolioCollectionTableViewCell.self, forCellReuseIdentifier: PortfolioCollectionTableViewCell.ReuseIdentifier)
        tableView.alpha = 0.0
        tableView.layer.cornerRadius = Constants.UI.TableView.CornerRadius
        tableView.allowsMultipleSelectionDuringEditing = false
        tableView.backgroundColor = .clear
        tableView.separatorColor = .clear

        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindWalletTrackerData()
        searchButton.addTarget(self, action: #selector(getWalletCollections(_:)), for: .touchUpInside)
    }

    @objc
    private func getWalletCollections(_: Any) {
        guard let walletAddress = walletSearchTextField.text else {
            return
        }
        portfolioViewModel.fetchWalletPortfolioData(wallet: walletAddress)
    }
}

// MARK: Data Modeling + Binding Implementations

extension WalletTrackerViewController {
    private func bindWalletTrackerData() {
        // Setup table view that hosts wallet collections
        bindTableData()

        // Bind view model to update portfolio page when subject updates
        portfolioViewModel.collections.subscribe { event in
            switch event {
            case let .next(value):
                self.updatePortfolioValueAndCharts(collections: value)
            case .completed:
                print("Completed")
            case let .error(error):
                print(error)
            }
        }.disposed(by: disposeBag)

        // Configure wallet address textfield data binding
        walletSearchTextField.rx.text.map { $0 ?? "" }.bind(
            to: walletAddressViewModel.walletAddressPublishSubject
        ).disposed(by: disposeBag)

        // Enable button when valid address provided
        walletAddressViewModel.isValidWallet().bind(
            to: searchButton.rx.isEnabled
        ).disposed(by: disposeBag)

        // Update button UI when valid address provided
        walletAddressViewModel.isValidWallet().map { $0 ? 1 : 0.1 }.bind(
            to: searchButton.rx.alpha
        ).disposed(by: disposeBag)
    }

    private func bindTableData() {
        // Bind portfolio collection data to table view
        portfolioViewModel.collections.bind(
            to: tableView.rx.items(
                cellIdentifier: PortfolioCollectionTableViewCell.ReuseIdentifier,
                cellType: PortfolioCollectionTableViewCell.self
            )
        ) { _, model, cell in
            cell.updateData(with: model)
        }.disposed(by: disposeBag)

        // When watchlist collection pressed, send user to collection detail view controller
        tableView.rx.itemSelected
            .subscribe(onNext: {
                guard let cell = self.tableView.cellForRow(at: $0) as? PortfolioCollectionTableViewCell,
                      let selectedViewModel = cell.portfolioCollectionViewModel
                else {
                    print("Couldn't identify cell pressed")
                    return
                }

                let detailVC = CollectionDetailViewController(collectionSymbol: selectedViewModel.collectionStats.symbol, collectionName: selectedViewModel.getCollectionNameString())
                self.navigationController?.pushViewController(detailVC, animated: true)

                self.tableView.deselectRow(at: $0, animated: true)
            }).disposed(by: disposeBag)
    }

    private func updatePortfolioValueAndCharts(collections: [PortfolioCollectionViewModel]) {
        var portfolioTotal = 0.00
        collections.forEach { collection in
            portfolioTotal += collection.getCollectionTotalValueDouble()
        }

        DispatchQueue.main.async {
            self.portfolioTotalValueLabel.text = String(format: "Portfolio Value: %.2f◎", portfolioTotal)
            self.tableView.alpha = 1.0
            self.portfolioTotalValueLabel.alpha = 1.0
        }
    }
}

// MARK: UI Implementations

extension WalletTrackerViewController {
    private func setupUI() {
        view.backgroundColor = ColorManager.backgroundColor

        setupNavigationTitle()

        view.addSubview(portfolioTotalValueLabel)
        view.addSubview(tableView)

        // Setup wallet search area (includes text field for wallet address, and send button)
        let stackView = UIStackView(arrangedSubviews: [walletSearchTextField, searchButton])
        stackView.axis = .horizontal
        view.addSubview(stackView)
        stackView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 25, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width: 0, height: 50, enableInsets: false)

        walletSearchTextField.anchor(top: stackView.topAnchor, left: stackView.leftAnchor, bottom: stackView.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: view.bounds.width * 0.65, height: 50, enableInsets: false)

        searchButton.anchor(top: stackView.topAnchor, left: walletSearchTextField.rightAnchor, bottom: stackView.bottomAnchor, right: stackView.rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: 0, height: 50, enableInsets: false)

        // Configure Portfolio Value Label below search stack view
        portfolioTotalValueLabel.translatesAutoresizingMaskIntoConstraints = false
        portfolioTotalValueLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        portfolioTotalValueLabel.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 25).isActive = true
        portfolioTotalValueLabel.heightAnchor.constraint(equalToConstant: 35).isActive = true

        // Configure tableview below portfolio label
        tableView.anchor(top: portfolioTotalValueLabel.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 10, paddingLeft: 10, paddingBottom: 10, paddingRight: 10, width: 0, height: 0, enableInsets: false)
    }

    private func setupNavigationTitle() {
        let label = UILabel()
        label.text = "Portfolio"
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        navigationItem.titleView = label
    }
}
