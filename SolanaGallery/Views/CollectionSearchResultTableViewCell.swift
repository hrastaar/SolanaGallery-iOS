//
//  CollectionSearchResultTableViewCell.swift
//  SolanaGallery
//
//  Created by Rastaar Haghi on 5/17/22.
//

import UIKit

class CollectionSearchResultTableViewCell: UITableViewCell {
    static let ReuseIdentifier = "CollectionSearchResultTableViewCell"
    var searchResult: CollectionSearchResult? {
        didSet {
            collectionNameLabel.text = self.searchResult?.name
            image.isHidden = true
            guard let imageString = searchResult?.image else {
                return
            }
            DispatchQueue.global(qos: .userInteractive).async {
                ImageManager.sharedInstance.fetchImage(imageUrlString: imageString) { image in
                    DispatchQueue.main.async {
                        self.image.image = image
                        self.image.isHidden = false
                    }
                }
            }
        }
    }
    
    var collectionNameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 2
        label.font = UIFont.primaryFont(size: 15)
        label.sizeToFit()
        return label
    }()
    
    var image = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    func updateData(with searchResult: CollectionSearchResult) {
        self.searchResult = searchResult
        setupUI()
    }
    
    private func setupUI() {
        addSubview(collectionNameLabel)
        addSubview(image)
        image.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 10, paddingLeft: 10, paddingBottom: 10, paddingRight: 10, width: 50, height: 50, enableInsets: false)
        
        collectionNameLabel.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 5, paddingLeft: 10, paddingBottom: 5, paddingRight: 0, width: 0, height: 0, enableInsets: false)

        let stackView = UIStackView(arrangedSubviews: [image, collectionNameLabel])
        stackView.alignment = .leading
        stackView.axis = .horizontal
        stackView.spacing = 20
        addSubview(stackView)
        stackView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 10, paddingLeft: 10, paddingBottom: 10, paddingRight: 10, width: 0, height: 75, enableInsets: false)
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
}

