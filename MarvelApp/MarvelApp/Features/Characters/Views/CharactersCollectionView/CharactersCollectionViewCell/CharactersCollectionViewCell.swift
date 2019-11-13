//
//  CharactersCollectionViewCell.swift
//  MarvelApp
//
//  Created by Rafael Lucena on 11/12/19.
//  Copyright © 2019 RLMG. All rights reserved.
//

import UIKit

struct CharactersCollectionViewCellModel {
    var characterImageURL: String
    var characterName: String
    var isFavorite: Bool
}

class CharactersCollectionViewCell: UICollectionViewCell {

    /**
     IBOutlets variables
     */
    @IBOutlet private weak var charactersImageView: UIImageView!
    @IBOutlet weak var characterNameLabel: UILabel!
    @IBOutlet weak var chracterFavoriteImageView: UIImageView!

    /**
     Model variables
     */
    var model: CharactersCollectionViewCellModel? {
        didSet {
            if model != nil {
                updateUI()
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 10
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.gray.cgColor
    }
    
    private func updateUI() {
        // TODO: update UI here
    }
}
