//
//  CharacterImageDescriptionTableViewCell.swift
//  MarvelApp
//
//  Created by Rafael Lucena on 11/24/19.
//  Copyright © 2019 RLMG. All rights reserved.
//

import UIKit

class CharacterImageDescriptionTableViewCell: UITableViewCell, CharacterTableViewCellProtocol {
    
    // IBOutlets variables
    @IBOutlet weak var charactersImageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    // CharacterTableViewCellProtocol variables
    var model: CharacterTableViewModel? {
        didSet {
            updateUI()
        }
    }
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    private func updateUI() {
        // todo: do stuff here
    }
    
    static func heightFor(character: Character, andFrame frame: CGRect) -> CGFloat {
        var height: CGFloat = 0
        let frameWidth = frame.size.width
        let padding: CGFloat = 16.0
        
        height += frameWidth
        height += padding * 2 // padding
        height += character.description.height(withConstrainedWidth: frameWidth - (padding * 2))
        
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
