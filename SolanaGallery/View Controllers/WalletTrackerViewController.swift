//
//  WalletTrackerViewController.swift
//  SolanaGallery
//
//  Created by Rastaar Haghi on 5/8/22.
//

import UIKit
import Charts
import RxCocoa
import RxSwift

class WalletTrackerViewController: UIViewController, ChartViewDelegate {
    static let cellIdentifier = "PortfolioCollectionTableViewCell"
    
    let walletAddressViewModel = WalletAddressViewModel()
    let disposeBag = DisposeBag()
    
    let portfolioViewModel = PortfolioViewModel()
    
    let walletSearchTextField: UITextField = {
        let textField = UITextField(frame: .zero)
        textField.placeholder = "Enter a valid Solana Wallet Address"
        textField.backgroundColor = .secondarySystemFill
        textField.layer.cornerRadius = 10
        textField.adjustsFontSizeToFitWidth = true
        textField.font = UIFont.primaryFont(size: 15)

        return textField
    }()
    
    let searchButton: UIButton = {
        let button = UIButton()
        button.setTitle("Search", for: .normal)
        button.backgroundColor = .secondarySystemFill
        button.layer.cornerRadius = 10
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
        var tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(PortfolioCollectionTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.alpha = 0.0
        tableView.allowsMultipleSelectionDuringEditing = false
        return tableView
    }()
    
    var pieChart: PieChartView = {
        let chart = PieChartView(frame: .zero)
        chart.alpha = 0.0
        chart.chartDescription?.font = UIFont.primaryFont(size: 12)
        chart.legend.font = UIFont.primaryFont(size: 8)
        
        return chart
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
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

        pieChart.delegate = self

        searchButton.addTarget(self, action: #selector(getWalletCollections(_:)), for: .touchUpInside)
    }
    
    

    @objc
    private func getWalletCollections(_ sender: Any) {
        guard let walletAddress = walletSearchTextField.text else {
            print("Couldn't get wallet address")
            return
        }
        portfolioViewModel.fetchWalletPortfolioData(wallet: walletAddress)
    }
}

extension WalletTrackerViewController {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        pieChart.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: view.bounds.width, height: 400, enableInsets: false)
        return pieChart
    }
    
    private func updatePortfolioValueAndCharts(collections: [PortfolioCollectionViewModel]) {
        var portfolioTotal: Double = 0.00
        var entries: [PieChartDataEntry] = []
        for obj in collections {
            portfolioTotal += obj.getCollectionTotalValueDouble()
            if (obj.getCollectionTotalValueDouble() < 0.05) {
                continue
            }
            entries.append(PieChartDataEntry(value: obj.getCollectionTotalValueDouble(),
                                             label: obj.getCollectionTotalValueTruncatedString()))
        }

        let dataset = PieChartDataSet(entries: entries, label: "Portfolio Distribution")
        dataset.colors = [
            UIColor().getSolanaPurpleColor()!,
            UIColor().getSolanaGreenColor()!,
            .secondarySystemFill,
            .systemTeal
        ]
        DispatchQueue.main.async {
            self.pieChart.data = PieChartData(dataSet: dataset)

            self.portfolioTotalValueLabel.text = String(format: "Portfolio Value: %.2f◎", portfolioTotal)
            self.pieChart.notifyDataSetChanged()
            
            self.tableView.alpha = 1.0
            self.portfolioTotalValueLabel.alpha = 1.0
            self.pieChart.alpha = 1.0
        }
    }
    
    private func bindTableData() {
        portfolioViewModel.collections.bind(
            to: tableView.rx.items(
                cellIdentifier: "PortfolioCollectionTableViewCell",
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
        view.addSubview(pieChart)

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
        
        tableView.anchor(top: searchButton.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 50, paddingLeft: 0, paddingBottom: 10, paddingRight: 0, width: 0, height: 0, enableInsets: false)
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
