//
//  Character.swift
//  MarvelApp
//
//  Created by Rafael Lucena on 11/19/19.
//  Copyright © 2019 RLMG. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

@objc
class Character: Object {
    @objc dynamic var id: NSNumber = 0
    @objc dynamic var name: String?
    @objc dynamic var characterDescription: String?
    @objc dynamic var thumbnail: String?
    @objc dynamic var isFavorite: NSNumber = false
    
    @objc dynamic var comicIds = RLMArray<ResourceID>.init(objectClassName: "ResourceID")
    @objc dynamic var comics = RLMArray<ResourceList>.init(objectClassName: "ResourceList")
    @objc dynamic var serieIds = RLMArray<ResourceID>.init(objectClassName: "ResourceID")
    @objc dynamic var serie = RLMArray<ResourceList>.init(objectClassName: "ResourceList")

    override func copy() -> Any {
        let copy = Character()
        copy.id = id
        copy.name = name
        copy.characterDescription = characterDescription
        copy.thumbnail = thumbnail
        copy.isFavorite = isFavorite
        copy.comicIds = comicIds
        copy.comics = comics
        return copy
    }
}

@objc
class ResourceList: Object {
    @objc dynamic var id: NSNumber = 0
    @objc dynamic var name: String?
    @objc dynamic var image: String?
    
    override func copy() -> Any {
        let copy = ResourceList()
        copy.id = id
        copy.name = name
        copy.image = image
        return copy
    }
}

@objc
class ResourceID: Object {
    @objc dynamic var id: NSNumber = 0
    
    override func copy() -> Any {
        let copy = ResourceID()
        copy.id = id
        return copy
    }

}
