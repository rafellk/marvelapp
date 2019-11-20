//
//  Character.swift
//  MarvelApp
//
//  Created by Rafael Lucena on 11/19/19.
//  Copyright © 2019 RLMG. All rights reserved.
//

import Foundation
import RealmSwift

@objc
class Character: Object {
    @objc dynamic var id: NSNumber = 0
    @objc dynamic var name: String?
    @objc dynamic var characterDescription: String?
    @objc dynamic var thumbnail: String?
    @objc dynamic var isFavorite: NSNumber = false
    
    override func copy() -> Any {
        let copy = Character()
        copy.id = id
        copy.name = name
        copy.characterDescription = characterDescription
        copy.thumbnail = thumbnail
        copy.isFavorite = isFavorite
        return copy
    }
}
