//
//  WalletTrackerViewController.swift
//  SolanaGallery
//
//  Created by Rastaar Haghi on 5/8/22.
//

import UIKit
import RxCocoa
import RxSwift

class WalletTrackerViewController: UIViewController {
    static let cellIdentifier = "PortfolioCollectionTableViewCell"
    
    let walletAddressViewModel = WalletAddressViewModel()
    let disposeBag = DisposeBag()
    
    let portfolioViewModel = PortfolioViewModel()
    let colorManager = ColorManager.sharedInstance

    let walletSearchTextField: TextField = {
        let textField = TextField(frame: .zero)
        textField.placeholder = "Enter a valid Solana Wallet Address"
        textField.backgroundColor = ColorManager.sharedInstance.primaryCellColor
        textField.layer.cornerRadius = 20
        textField.adjustsFontSizeToFitWidth = true
        textField.font = UIFont.primaryFont(size: 15)
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        
        return textField
    }()
    
    let searchButton: UIButton = {
        let button = UIButton()
        button.setTitle("Search", for: .normal)
        button.backgroundColor = ColorManager.sharedInstance.primaryCellColor
        button.layer.cornerRadius = 20
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
        label.textAlignment = .center
        
        return label
    }()
    
    var tableView: UITableView = {
        var tableView = UITableView(frame: .zero)
        tableView.register(PortfolioCollectionTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.alpha = 0.0
        tableView.layer.cornerRadius = 25
        tableView.allowsMultipleSelectionDuringEditing = false
        tableView.backgroundColor = .clear
        tableView.separatorColor = .clear
        
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = colorManager.backgroundColor
        
        // Do any additional setup after loading the view.
        self.bindTableData()
        self.bindPortfolioData()
        self.setupUI()
                
        walletSearchTextField.rx.text.map { $0 ?? "" }.bind(
            to: walletAddressViewModel.walletAddressPublishSubject
        ).disposed(by: disposeBag)
        
        walletAddressViewModel.isValidWallet().bind(
            to: searchButton.rx.isEnabled
        ).disposed(by: disposeBag)
        
        walletAddressViewModel.isValidWallet().map { $0 ? 1 : 0.1 }.bind(
            to: searchButton.rx.alpha
        ).disposed(by: disposeBag)

        searchButton.addTarget(self, action: #selector(getWalletCollections(_:)), for: .touchUpInside)
    }
    
    

    @objc
    private func getWalletCollections(_ sender: Any) {
        guard let walletAddress = walletSearchTextField.text else {
            return
        }
        portfolioViewModel.fetchWalletPortfolioData(wallet: walletAddress)
    }
}

extension WalletTrackerViewController {
    private func updatePortfolioValueAndCharts(collections: [PortfolioCollectionViewModel]) {
        var portfolioTotal: Double = 0.00
        collections.forEach { collection in
            portfolioTotal += collection.getCollectionTotalValueDouble()
        }

        DispatchQueue.main.async {
            self.portfolioTotalValueLabel.text = String(format: "Portfolio Value: %.2f◎", portfolioTotal)
            self.tableView.alpha = 1.0
            self.portfolioTotalValueLabel.alpha = 1.0
        }
    }
    
    private func bindTableData() {
        portfolioViewModel.collections.bind(
            to: tableView.rx.items(
                cellIdentifier: PortfolioCollectionTableViewCell.ReuseIdentifier,
                cellType: PortfolioCollectionTableViewCell.self)
        ) { row, model, cell in
            cell.updateData(with: model)
        }.disposed(by: disposeBag)
        
        tableView.rx.modelSelected(PortfolioCollectionViewModel.self).bind { collection in
            print(collection.collectionCount.collection)
        }.disposed(by: disposeBag)
    }
    
    private func bindPortfolioData() {
        portfolioViewModel.collections.subscribe { event in
            switch event {
                case .next(let value):
                    self.updatePortfolioValueAndCharts(collections: value)
                case .completed:
                    print("Completed")
                case .error(let error):
                    print(error)
            }
        }.disposed(by: disposeBag)
    }
}

extension WalletTrackerViewController {
    private func setupUI() {
        setupNavigationTitle()
        view.addSubview(portfolioTotalValueLabel)
        view.addSubview(tableView)

        // Setup wallet search area (includes text field for wallet address, and send button)
        let stackView = UIStackView(arrangedSubviews: [walletSearchTextField, searchButton])
        stackView.distribution = .fill
        stackView.axis = .horizontal
        stackView.spacing = 20
        view.addSubview(stackView)
        
        walletSearchTextField.anchor(top: stackView.topAnchor, left: stackView.leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: view.bounds.width * 0.65, height: 50, enableInsets: false)
        
        searchButton.anchor(top: stackView.topAnchor, left: nil, bottom: stackView.bottomAnchor, right: stackView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 25, width: view.bounds.width * 0.2 , height: 50, enableInsets: false)
        
        stackView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 100, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width: 0, height: 0, enableInsets: false)
        
        portfolioTotalValueLabel.anchor(top: searchButton.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 25, paddingLeft: 0, paddingBottom: 25, paddingRight: 0, width: view.bounds.width * 0.3, height: 35, enableInsets: false)
        
        tableView.anchor(top: portfolioTotalValueLabel.bottomAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingTop: 10, paddingLeft: 10, paddingBottom: 10, paddingRight: 10, width: 0, height: 0, enableInsets: false)
    }
    
    private func setupNavigationTitle() {
        let label = UILabel()
        label.text = "Portfolio"
        label.textAlignment = .left
        self.navigationItem.titleView = label
        label.translatesAutoresizingMaskIntoConstraints = false
        label.anchor(top: navigationController?.navigationBar.topAnchor, left: navigationController?.navigationBar.leftAnchor, bottom: navigationController?.navigationBar.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: navigationController?.navigationBar.bounds.width ?? 0, height: 0, enableInsets: false)
    }
}
