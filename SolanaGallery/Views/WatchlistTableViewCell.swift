//
//  WatchlistTableViewCell.swift
//  SolanaGallery
//
//  Created by Rastaar Haghi on 4/30/22.
//

import UIKit

class WatchlistTableViewCell: UITableViewCell {
    
    var watchlistViewModel: WatchlistViewModel? {
        didSet {
            collectionNameLabel.text = watchlistViewModel?.getCollectionNameString()
            floorPriceLabel.text = watchlistViewModel?.getFloorPriceString()
            listedCountLabel.text = watchlistViewModel?.getListedCountString()
        }
    }
    
    var collectionNameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 2
        label.sizeToFit()
        return label
    }()
    
    var floorPriceLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()
    var listedCountLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    func updateData(with watchlistViewModel: WatchlistViewModel) {
        self.watchlistViewModel = watchlistViewModel
        
        setupUI()
    }
    private func setupUI() {
        super.addSubview(collectionNameLabel)
        super.addSubview(floorPriceLabel)
        super.addSubview(listedCountLabel)

        collectionNameLabel.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 5, paddingLeft: 5, paddingBottom: 5, paddingRight: 0, width: bounds.width * 0.5, height: 0, enableInsets: false)

        let stackView = UIStackView(arrangedSubviews: [floorPriceLabel, listedCountLabel])
        stackView.distribution = .equalSpacing
        stackView.axis = .vertical
        stackView.spacing = 25
        addSubview(stackView)
        stackView.anchor(top: topAnchor, left: nil, bottom: bottomAnchor, right: rightAnchor, paddingTop: 15, paddingLeft: 5, paddingBottom: 15, paddingRight: 5, width: 0, height: 0, enableInsets: false)

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
