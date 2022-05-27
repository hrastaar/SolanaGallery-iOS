//
//  CollectionSearchResultTableViewCell.swift
//  SolanaGallery
//
//  Created by Rastaar Haghi on 5/17/22.
//

import UIKit
import SkeletonView

class CollectionSearchResultTableViewCell: UITableViewCell {
    static let ReuseIdentifier = "CollectionSearchResultTableViewCell"
    var searchResult: CollectionSearchResult?
    
    let colorManager = ColorManager.sharedInstance

    var collectionNameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 2
        label.font = UIFont.primaryFont(size: 15)
        label.sizeToFit()
        label.isSkeletonable = true
        
        return label
    }()
    
    var collectionImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.isSkeletonable = true
        imageView.skeletonCornerRadius = 10
        
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    func updateData(with searchResult: CollectionSearchResult) {
        self.searchResult = searchResult
        collectionNameLabel.text = self.searchResult?.name
        DispatchQueue.main.async {
            self.collectionImageView.image = .none
        }
        let oldSymbol = searchResult.symbol
        DispatchQueue.global(qos: .userInteractive).async {
            ImageManager.sharedInstance.fetchImage(imageUrlString: searchResult.image) { image in
                // Ensures that old async call to uiimage doesn't update cell with outdated collection image
                if oldSymbol == self.searchResult?.symbol {
                    DispatchQueue.main.async {
                        self.collectionImageView.hideSkeleton()
                        self.collectionImageView.layer.cornerRadius = 10
                        self.collectionImageView.image = image
                        self.collectionNameLabel.hideSkeleton()
                    }
                }

            }
        }
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = colorManager.primaryCellColor

        addSubview(collectionNameLabel)
        addSubview(collectionImageView)
        setupSkeletonViews()
        let stackView = UIStackView(arrangedSubviews: [collectionImageView, collectionNameLabel])
        stackView.alignment = .leading
        stackView.axis = .horizontal
        stackView.spacing = 20
        addSubview(stackView)
        stackView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 5, paddingLeft: 5, paddingBottom: 5, paddingRight: 5, width: 0, height: 65, enableInsets: false)
        collectionImageView.anchor(top: nil, left: stackView.leftAnchor, bottom: nil, right: nil, paddingTop: 25, paddingLeft: 10, paddingBottom: 25, paddingRight: 10, width: 50, height: 50, enableInsets: false)
        collectionImageView.centerYAnchor.constraint(equalTo: stackView.centerYAnchor).isActive = true

        collectionNameLabel.anchor(top: stackView.topAnchor, left: collectionImageView.rightAnchor, bottom: stackView.bottomAnchor, right: stackView.rightAnchor, paddingTop: 5, paddingLeft: 10, paddingBottom: 5, paddingRight: 0, width: 0, height: 0, enableInsets: false)
    }
    
    required init?(coder: NSCoder) {
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
    
    private func setupSkeletonViews() {
        let animation = SkeletonAnimationBuilder().makeSlidingAnimation(withDirection: .topLeftBottomRight)
        collectionImageView.showAnimatedGradientSkeleton(animation: animation)
        collectionNameLabel.skeletonTextLineHeight = .relativeToFont
        collectionNameLabel.skeletonTextNumberOfLines = 1
        collectionNameLabel.linesCornerRadius = 10
        collectionNameLabel.showSkeleton()
    }
}
