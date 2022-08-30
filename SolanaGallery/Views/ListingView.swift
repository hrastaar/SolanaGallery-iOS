//
//  ListingView.swift
//  SolanaGallery
//
//  Created by Rastaar Haghi on 5/28/22.
//

import SafariServices
import SkeletonView
import UIKit

class ListingView: UIView {
    let listing: CollectionListing

    required init(listing: CollectionListing, frame: CGRect) {
        self.listing = listing
        super.init(frame: frame)
        backgroundColor = ColorManager.primaryCellColor
        layer.cornerRadius = 17.5
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    let listingImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.isSkeletonable = true
        imageView.skeletonCornerRadius = 10
        imageView.autoresizingMask = .flexibleWidth
        imageView.contentMode = .scaleAspectFit

        return imageView
    }()

    private func setupUI() {
        addSubview(listingImageView)
        setupListingImageView()

        // Create rarity stack view
        guard let rarityStackView = createRarityStackView() else {
            return
        }
        addSubview(rarityStackView)
        rarityStackView.anchor(
            top: centerYAnchor,
            left: leftAnchor,
            bottom: nil,
            right: rightAnchor,
            paddingTop: 0,
            paddingLeft: 2.5,
            paddingBottom: 0,
            paddingRight: 2.5,
            width: 0,
            height: 40,
            enableInsets: false
        )

        // Create price stack view
        let priceStackView = createPriceStackView()
        addSubview(priceStackView)
        priceStackView.anchor(
            top: rarityStackView.bottomAnchor,
            left: leftAnchor,
            bottom: nil,
            right: rightAnchor,
            paddingTop: 5,
            paddingLeft: 5,
            paddingBottom: 0,
            paddingRight: 5,
            width: 0,
            height: 20,
            enableInsets: false
        )

        // Create seller stack view
        let sellerStackView = createSellerStackView()
        addSubview(sellerStackView)
        sellerStackView.anchor(
            top: priceStackView.bottomAnchor,
            left: leftAnchor,
            bottom: nil,
            right: rightAnchor,
            paddingTop: 12.5,
            paddingLeft: 5,
            paddingBottom: 0,
            paddingRight: 5,
            width: 0,
            height: 10,
            enableInsets: false
        )
    }
}

// Extension contains tedious UI view creation + constraint specifications
extension ListingView {
    private func setupListingImageView() {
        listingImageView.anchor(
            top: topAnchor,
            left: leftAnchor,
            bottom: nil,
            right: rightAnchor,
            paddingTop: 10,
            paddingLeft: 10,
            paddingBottom: 0,
            paddingRight: 10,
            width: 0,
            height: 100,
            enableInsets: false
        )
        listingImageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true

        let animation = SkeletonAnimationBuilder().makeSlidingAnimation(withDirection: .topLeftBottomRight)
        listingImageView.showAnimatedGradientSkeleton(animation: animation)

        DispatchQueue.global(qos: .userInteractive).async {
            ImageManager.sharedInstance.fetchImage(imageUrlString: self.listing.image) { image in
                DispatchQueue.main.async {
                    self.listingImageView.layer.cornerRadius = 10
                    self.listingImageView.hideSkeleton()

                    guard let image = image else { return }
                    let scaledImage = image.scalePreservingAspectRatio(
                        targetSize: .init(width: 100, height: 100)
                    )
                    self.listingImageView.image = scaledImage
                }
            }
        }
    }

    private func createRarityStackView() -> UIStackView? {
        // Create HowRare rarity view stack
        guard let howrareImage = UIImage(named: "howrare.png") else {
            return nil
        }
        let howrareImageView = UIImageView(image: howrareImage)
        howrareImageView.layer.cornerRadius = 10

        let howrareLabel = UILabel()
        howrareLabel.font = .primaryFont(size: 12)
        howrareLabel.textColor = .white

        if let howrareScore = listing.howrare {
            howrareLabel.text = String(howrareScore)
        } else {
            howrareLabel.text = "N/A"
        }
        let howrareStack = UIStackView(arrangedSubviews: [howrareImageView, howrareLabel])
        howrareImageView.anchor(
            top: nil,
            left: nil,
            bottom: nil,
            right: nil,
            paddingTop: 2,
            paddingLeft: 2,
            paddingBottom: 2,
            paddingRight: 2,
            width: 12,
            height: 12,
            enableInsets: false
        )
        howrareImageView.centerYAnchor.constraint(equalTo: howrareStack.centerYAnchor).isActive = true
        howrareLabel.centerYAnchor.constraint(equalTo: howrareStack.centerYAnchor).isActive = true
        howrareStack.axis = .horizontal
        howrareStack.spacing = 5
        howrareStack.alignment = .leading

        // Create Moonrank rarity view stack
        guard let moonrankImage = UIImage(named: "moonrank.png") else {
            return nil
        }
        let moonrankImageView = UIImageView(image: moonrankImage)
        moonrankImageView.layer.cornerRadius = 10

        let moonrankLabel = UILabel()
        moonrankLabel.font = .primaryFont(size: 12)
        moonrankLabel.textColor = .white

        if let moonrankScore = listing.moonrank {
            moonrankLabel.text = String(moonrankScore)
        } else {
            moonrankLabel.text = "N/A"
        }
        let moonrankStack = UIStackView(arrangedSubviews: [moonrankImageView, moonrankLabel])
        moonrankImageView.anchor(
            top: nil,
            left: nil,
            bottom: nil,
            right: nil,
            paddingTop: 2,
            paddingLeft: 2,
            paddingBottom: 2,
            paddingRight: 2,
            width: 12,
            height: 12,
            enableInsets: false
        )
        moonrankImageView.centerYAnchor.constraint(equalTo: moonrankStack.centerYAnchor).isActive = true
        moonrankLabel.centerYAnchor.constraint(equalTo: moonrankStack.centerYAnchor).isActive = true
        moonrankStack.axis = .horizontal
        moonrankStack.spacing = 5
        moonrankStack.alignment = .trailing

        let rarityStackView = UIStackView(arrangedSubviews: [howrareStack, moonrankStack])
        rarityStackView.axis = .horizontal
        rarityStackView.alignment = .center

        return rarityStackView
    }

    private func createPriceStackView() -> UIStackView {
        let priceLabel = UILabel()
        priceLabel.text = String(format: "%.2f◎", listing.price)
        priceLabel.font = .primaryFont(size: 14)
        priceLabel.textColor = .white

        let priceRowLabel = UILabel()
        priceRowLabel.text = "Price"
        priceRowLabel.font = .primaryFont(size: 14)
        priceRowLabel.textColor = .white

        let priceStackView = UIStackView(arrangedSubviews: [priceRowLabel, priceLabel])
        priceStackView.axis = .horizontal

        priceRowLabel.anchor(
            top: priceStackView.topAnchor,
            left: priceStackView.leftAnchor,
            bottom: priceStackView.bottomAnchor,
            right: priceStackView.centerXAnchor,
            paddingTop: 0,
            paddingLeft: 0,
            paddingBottom: 0,
            paddingRight: 0,
            width: 0,
            height: 20,
            enableInsets: false
        )
        priceRowLabel.textAlignment = .left

        priceLabel.anchor(
            top: priceStackView.topAnchor,
            left: priceStackView.centerXAnchor,
            bottom: priceStackView.bottomAnchor,
            right: priceStackView.rightAnchor,
            paddingTop: 0,
            paddingLeft: 0,
            paddingBottom: 0,
            paddingRight: 0,
            width: 0,
            height: 20,
            enableInsets: false
        )
        priceLabel.textAlignment = .right

        return priceStackView
    }

    private func createSellerStackView() -> UIStackView {
        let sellerLabel = UILabel()
        sellerLabel.text = listing.getShortenedSellerAddressString()
        sellerLabel.font = .primaryFont(size: 10)
        sellerLabel.textColor = .white

        let sellerRowLabel = UILabel()
        sellerRowLabel.text = "Seller"
        sellerRowLabel.font = .primaryFont(size: 10)
        sellerRowLabel.textColor = .white

        let sellerStackView = UIStackView(arrangedSubviews: [sellerRowLabel, sellerLabel])
        sellerStackView.axis = .horizontal

        sellerRowLabel.anchor(
            top: sellerStackView.topAnchor,
            left: sellerStackView.leftAnchor,
            bottom: sellerStackView.bottomAnchor,
            right: sellerStackView.centerXAnchor,
            paddingTop: 0,
            paddingLeft: 0,
            paddingBottom: 0,
            paddingRight: 0,
            width: 0,
            height: 20,
            enableInsets: false
        )
        sellerRowLabel.textAlignment = .left

        sellerLabel.anchor(
            top: sellerStackView.topAnchor,
            left: sellerStackView.centerXAnchor,
            bottom: sellerStackView.bottomAnchor,
            right: sellerStackView.rightAnchor,
            paddingTop: 0,
            paddingLeft: 0,
            paddingBottom: 0,
            paddingRight: 0,
            width: 0,
            height: 20,
            enableInsets: false
        )
        sellerLabel.textAlignment = .right

        return sellerStackView
    }
}
