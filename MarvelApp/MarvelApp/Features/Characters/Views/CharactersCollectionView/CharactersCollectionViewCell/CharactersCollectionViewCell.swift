//
//  CharactersCollectionViewCell.swift
//  MarvelApp
//
//  Created by Rafael Lucena on 11/12/19.
//  Copyright © 2019 RLMG. All rights reserved.
//

import UIKit

protocol CharactersCollectionViewCellDelegate: NSObjectProtocol {
    func didFavorite(character: Character)
    func needsImageFetchRequest(forCharacter character: Character)
}

class CharactersCollectionViewCell: UICollectionViewCell {

    /**
     IBOutlets variables
     */
    @IBOutlet private weak var charactersImageView: UIImageView!
    @IBOutlet weak var characterNameLabel: UILabel!
    @IBOutlet weak var characterFavoriteButton: UIButton!
    
    /**
     Model variables
     */
    var model: Character? {
        didSet {
            if model != nil {
                updateUI()
            }
        }
    }
    
    /**
     User interaction delegate variable
     */
    weak var delegate: CharactersCollectionViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configureBorder()
        configureFavoriteButton()
    }
    
    private func configureBorder() {
        layer.cornerRadius = 10
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.gray.cgColor
    }
    
    private func configureFavoriteButton() {
        characterFavoriteButton.addTarget(self, action: #selector(favoriteButtonPressed), for: .touchUpInside)
    }
    
    private func updateUI() {
        if let model = model {
            characterNameLabel.text = model.name
            characterFavoriteButton.setImage(model.isFavorite.boolValue ? UIImage(systemName: "star.fill") : UIImage(systemName: "star"), for: .normal)
            
            if let thumbnail = model.thumbnail, let image = ImageDownloaderService.shared.cachedImage(withURL: thumbnail) {
                charactersImageView.image = image
            } else {
                charactersImageView.image = UIImage(named: "marvel_icon")
                delegate?.needsImageFetchRequest(forCharacter: model)
            }
        }
    }
    
    @objc
    private func favoriteButtonPressed() {
        if let model = model {
            delegate?.didFavorite(character: model)
            model.isFavorite = NSNumber(booleanLiteral: !model.isFavorite.boolValue)
            updateUI()
        }
    }
}
