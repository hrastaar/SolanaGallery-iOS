//
//  WatchlistTableViewCell.swift
//  SolanaGallery
//
//  Created by Rastaar Haghi on 4/30/22.
//

import UIKit

class WatchlistTableViewCell: UITableViewCell {
    static let ReuseIdentifier = "WatchlistTableViewCell"

    var watchlistViewModel: WatchlistCollectionViewModel?

    var collectionNameLabel: UILabel = {
        let label = UILabel()

        label.textColor = .white
        label.textAlignment = .left
        label.numberOfLines = 2
        label.font = UIFont.primaryFont(size: 15)
        label.sizeToFit()

        return label
    }()

    var floorPriceLabel: UILabel = {
        let label = UILabel()

        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 2
        label.font = UIFont.primaryFont(size: 13)

        return label
    }()

    var listedCountLabel: UILabel = {
        let label = UILabel()

        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 2
        label.font = UIFont.primaryFont(size: 13)

        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    func updateData(with watchlistViewModel: WatchlistCollectionViewModel) {
        self.watchlistViewModel = watchlistViewModel
        collectionNameLabel.text = watchlistViewModel.getCollectionNameString()
        floorPriceLabel.text = watchlistViewModel.getFloorPriceString()
        listedCountLabel.text = watchlistViewModel.getListedCountString()
        setupUI()
    }

    private func setupUI() {
        backgroundColor = ColorManager.primaryCellColor

        super.addSubview(collectionNameLabel)
        super.addSubview(floorPriceLabel)
        super.addSubview(listedCountLabel)

        collectionNameLabel.anchor(
            top: topAnchor,
            left: leftAnchor,
            bottom: bottomAnchor,
            right: nil,
            paddingTop: 5,
            paddingLeft: 10,
            paddingBottom: 5,
            paddingRight: 0,
            width: 0,
            height: 0,
            enableInsets: false
        )

        let stackView = UIStackView(arrangedSubviews: [floorPriceLabel, listedCountLabel])
        stackView.distribution = .equalSpacing
        stackView.axis = .vertical
        stackView.spacing = 20
        addSubview(stackView)
        stackView.anchor(
            top: topAnchor,
            left: nil,
            bottom: bottomAnchor,
            right: rightAnchor,
            paddingTop: 10,
            paddingLeft: 5,
            paddingBottom: 10,
            paddingRight: 10,
            width: 0,
            height: 0,
            enableInsets: false
        )
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
