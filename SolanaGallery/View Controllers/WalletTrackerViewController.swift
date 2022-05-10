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
    let cellIdentifier = "PortfolioCollectionTableViewCell"
    
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
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.alpha = 0.0
        
        return tableView
    }()
    
    var pieChart: PieChartView = {
        let chart = PieChartView(frame: .zero)
        chart.alpha = 0.0
        chart.chartDescription?.font = UIFont.primaryFont(size: 12)
        chart.legend.font = UIFont.primaryFont(size: 8)
        
        return chart
    }()
    
    let walletAddressViewModel = WalletAddressViewModel()
    let disposeBag = DisposeBag()
    
    var portfolioObjects = [PortfolioCollectionViewModel]()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Portfolio"
        
        // Do any additional setup after loading the view.
        self.setupTableView()
        self.setupUI()
                
        walletSearchTextField.rx.text.map { $0 ?? "" }.bind(to: walletAddressViewModel.walletAddressPublishSubject).disposed(by: disposeBag)
        walletAddressViewModel.isValidWallet().bind(to: searchButton.rx.isEnabled).disposed(by: disposeBag)
        walletAddressViewModel.isValidWallet().map { $0 ? 1 : 0.1 }.bind(to: searchButton.rx.alpha).disposed(by: disposeBag)
        
        tableView.dataSource = self
        tableView.delegate = self
        pieChart.delegate = self

        searchButton.addTarget(self, action: #selector(getWalletCollections(_:)), for: .touchUpInside)
    }
    
    private func setupUI() {
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
    
    private func getWalletPortfolioCollectionInfo(wallet: String) {
        self.portfolioObjects.removeAll()
        SolanaGalleryAPI.sharedInstance.getNftCollectionCounts(wallet: wallet).subscribe(onNext: { counts in
            for count in counts {
                SolanaGalleryAPI.sharedInstance.fetchCollectionStats(collectionName: count.collection).subscribe(onNext: { stats in
                    let portfolioItemViewModel = PortfolioCollectionViewModel(with: stats, collectionCount: count)
                    self.portfolioObjects.append(portfolioItemViewModel)
                    self.portfolioItemsUpdated()
                }).disposed(by: self.disposeBag)
            }
        }).disposed(by: self.disposeBag)
    }
    
    @objc
    private func getWalletCollections(_ sender: Any) {
        guard let walletAddress = walletSearchTextField.text else { return }
        self.portfolioObjects.removeAll()
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        getWalletPortfolioCollectionInfo(wallet: walletAddress)
    }
}

extension WalletTrackerViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return portfolioObjects.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        pieChart.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: view.bounds.width, height: 400, enableInsets: false)
        return pieChart
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! PortfolioCollectionTableViewCell
        cell.updateData(with: portfolioObjects[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = self.portfolioObjects[indexPath.row]
        print(item.collectionCount.collection + ", " + String(item.collectionCount.count) + ", price: " + String(item.collectionStats.floorPrice))
        
    }
    
    private func portfolioItemsUpdated() {
        var portfolioTotal: Double = 0.00
        for obj in portfolioObjects {
            portfolioTotal += obj.getCollectionTotalValueDouble()
        }
        
        var entries: [PieChartDataEntry] = []
        for obj in portfolioObjects {
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
        self.pieChart.data = PieChartData(dataSet: dataset)
        DispatchQueue.main.async {
            self.portfolioTotalValueLabel.text = String(format: "Portfolio Value: %.2f◎", portfolioTotal)
            self.tableView.reloadData()
            self.pieChart.notifyDataSetChanged()
            
            self.tableView.alpha = 1.0
            self.portfolioTotalValueLabel.alpha = 1.0
            self.pieChart.alpha = 1.0
        }
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PortfolioCollectionTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.allowsMultipleSelectionDuringEditing = false
    }
}
