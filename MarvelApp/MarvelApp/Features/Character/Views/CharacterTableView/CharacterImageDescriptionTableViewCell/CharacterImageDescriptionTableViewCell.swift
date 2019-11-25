//
//  CharacterImageDescriptionTableViewCell.swift
//  MarvelApp
//
//  Created by Rafael Lucena on 11/24/19.
//  Copyright © 2019 RLMG. All rights reserved.
//

import UIKit

protocol CharacterViewDelegate {
    func needsImageFetchRequest(forCharacter character: Character)
}

class CharacterImageDescriptionTableViewCell: UITableViewCell, CharacterTableViewCellProtocol {
    
    // IBOutlets variables
    @IBOutlet weak var charactersImageView: LoadingImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    // CharacterTableViewCellProtocol variables
    var model: CharacterTableViewModel? {
        didSet {
            updateUI()
        }
    }
    
    /**
     User interaction delegate variable
     */
    var delegate: CharacterViewDelegate?
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    private func updateUI() {
        if let model = model {
            descriptionLabel.text = model.character.characterDescription
            
            if let thumbnail = model.character.thumbnail, let image = ImageDownloaderService.shared.cachedImage(withURL: thumbnail) {
                charactersImageView.configureImageState(withImage: image)
            } else {
                charactersImageView.configureLoadingState()
                delegate?.needsImageFetchRequest(forCharacter: model.character)
            }
        }
    }
    
    static func heightFor(character: Character, andFrame frame: CGRect) -> CGFloat {
        var height: CGFloat = 0
        
        let frameWidth = frame.size.width
        let padding: CGFloat = 8.0
        
        height += frameWidth
        height += padding * 3 // padding
        
        if let description = character.characterDescription {
            height += description.height(withConstrainedWidth: frameWidth - (padding * 4))
        }
        
        return height
    }
}

extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont = UIFont.systemFont(ofSize: 15)) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)

        return ceil(boundingBox.height)
    }
}
