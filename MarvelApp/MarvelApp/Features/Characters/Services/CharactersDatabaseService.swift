//
//  CharactersDatabaseService.swift
//  MarvelApp
//
//  Created by Rafael Lucena on 11/19/19.
//  Copyright © 2019 RLMG. All rights reserved.
//

import Foundation
import RealmSwift

let realm = try! Realm()

class CharactersDatabaseService {
    
    static func addFavorite(character: Character, callback: ((Error?) -> Void)? = nil) {
        if let oldValue = checkExistence(ofCharacter: character) {
            do {
                realm.beginWrite()
                realm.delete(oldValue)
                try realm.commitWrite()
                callback?(nil)
            } catch {
                callback?(error)
            }
        } else if let copy = character.copy() as? Object {
            do {
                realm.beginWrite()
                realm.add(copy)
                try realm.commitWrite()
                callback?(nil)
            } catch {
                callback?(error)
            }            
        }
    }
    
    static func listFavorites() -> [Character] {
        return realm.objects(Character.self).map { $0 }
    }
    
    private static func checkExistence(ofCharacter character: Character) -> Character? {
        if let value = realm.objects(Character.self).filter("id == \(character.id)").first {
            return value
        }
        
        return nil
    }
}
