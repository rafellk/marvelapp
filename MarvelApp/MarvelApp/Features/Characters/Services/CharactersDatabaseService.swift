//
//  CharactersDatabaseService.swift
//  MarvelApp
//
//  Created by Rafael Lucena on 11/19/19.
//  Copyright © 2019 RLMG. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

let realm = try! Realm()

class CharactersDatabaseService {
    
    static let shared = CharactersDatabaseService()
    private var models: Results<Character>
    private var token: NotificationToken?
    var onChange: (([Character]) -> Void)?
    
    private init() {
        models = realm.objects(Character.self)
        token = models.observe { [weak self] (changes) in
        switch changes {
            case.initial(let result):
                self?.onChange?(result.map({ $0 }))
            case .update(let result):
                self?.onChange?(result.0.map({ $0 }))
                break
            default:
                break
            }

        }
    }
    
    func addFavorite(character: Character, callback: ((Error?) -> Void)? = nil) {
        if let oldValue = checkExistence(ofCharacter: character) {
            do {
                try realm.write {
                    realm.delete(oldValue)
                    callback?(nil)
                }
            } catch {
                callback?(error)
            }
        } else if let copy = character.copy() as? Character {
            copy.isFavorite = NSNumber(booleanLiteral: true)
            
            do {
                try realm.write {
                    realm.add(copy)
                    callback?(nil)
                }
            } catch {
                callback?(error)
            }            
        }
    }
    
    func listFavorites() -> [Character] {
        return models.map({ $0 })
    }
    
    func subscribeToChanges(callback: @escaping ([Character]) -> Void) {
        onChange = callback
    }
    
    private func checkExistence(ofCharacter character: Character) -> Character? {
        if let value = models.filter("id == \(character.id)").first {
            return value
        }
        
        return nil
    }
}
