//
//  HorizontalCollectionViewCell.swift
//  MarvelApp
//
//  Created by Rafael Lucena on 11/24/19.
//  Copyright © 2019 RLMG. All rights reserved.
//

import UIKit

protocol HorizontalCollectionViewCellDelegate: NSObjectProtocol {
    func needsImageFetchRequest(forModel: HorizontalCollectionTableViewCellModel)
}

class HorizontalCollectionViewCell: UICollectionViewCell {
    
    // IBOutlets variables
    @IBOutlet weak var targetImageView: LoadingImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    // Model variables
    var model: HorizontalCollectionTableViewCellModel? {
        didSet {
            updateUI()
        }
    }
    
    weak var delegate: HorizontalCollectionViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureBorder()
    }
}

extension HorizontalCollectionViewCell {
    
    private func configureBorder() {
        layer.cornerRadius = 10
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.gray.cgColor
    }
    
    private func updateUI() {
        if let model = model {
            descriptionLabel.text = model.title
            
            if let image = ImageDownloaderService.shared.cachedImage(withURL: model.imageURL) {
                targetImageView.configureImageState(withImage: image)
            } else {
                targetImageView.configureLoadingState()
                delegate?.needsImageFetchRequest(forModel: model)
            }
        }
    }
}
