//
//  CollectionActivityTableViewCell.swift
//  SolanaGallery
//
//  Created by Rastaar Haghi on 7/18/22.
//

import UIKit

class CollectionActivityTableViewCell: UITableViewCell {
    static let ReuseIdentifier = "CollectionActivityTableViewCell"

    var activityEvent: CollectionActivityEvent?

    var priceLabel: UILabel = {
        let label = UILabel()

        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 1
        label.font = UIFont.primaryFont(size: 14)
        label.sizeToFit()

        return label
    }()

    var dateLabel: UILabel = {
        let label = UILabel()

        label.textColor = .white
        label.textAlignment = .right
        label.numberOfLines = 1
        label.font = UIFont.primaryFont(size: 10)
        label.sizeToFit()

        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    func updateData(with activityEvent: CollectionActivityEvent) {
        self.activityEvent = activityEvent

        priceLabel.text = activityEvent.priceString
        dateLabel.text = activityEvent.dateString

        setupUI()
    }

    private func setupUI() {
        backgroundColor = ColorManager.primaryCellColor

        addSubview(dateLabel)
        addSubview(priceLabel)

        let stackView = UIStackView(arrangedSubviews: [dateLabel, priceLabel])
        stackView.axis = .vertical
        stackView.spacing = 15
        addSubview(stackView)

        stackView.anchor(
            top: topAnchor,
            left: leftAnchor,
            bottom: bottomAnchor,
            right: rightAnchor,
            paddingTop: 10,
            paddingLeft: 10,
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
