//
//  CharacterViewModel.swift
//  MarvelApp
//
//  Created by Rafael Lucena on 11/24/19.
//  Copyright © 2019 RLMG. All rights reserved.
//

import Foundation
import Realm
import RealmSwift
import RxSwift

enum CharacterViewModelViewerMode {
    case description, comics, series
}

struct CharacterViewModelViewer {
    var indexes: [IndexPath]
    var mode: CharacterViewModelViewerMode
}

class CharacterViewModel: BaseViewModel {
    
    // Observable variables
    private var isLoading = BehaviorSubject(value: false)
    var isLoadingObservable: Observable<Bool> {
        return isLoading.asObserver()
    }

    private var models = BehaviorSubject(value: CharacterViewModelViewer(indexes: [], mode: .description))
    var modelsObservable: Observable<CharacterViewModelViewer> {
        return models.asObserver()
    }
    
    // Model variables
    var model: Character?
    
    init(withPresenter presenter: UIViewController, model: Character?) {
        super.init(withPresenter: presenter)
        self.model = model
    }
}

extension CharacterViewModel {
    
    func fetchThumbnail(character: Character) {
        guard let thumbnail = character.thumbnail else { return }
        
        ImageDownloaderService.shared.requestImage(withURL: thumbnail) { [weak self] (error) in
            guard error == nil else { return }
            self?.models.onNext(CharacterViewModelViewer(indexes: [IndexPath(row: 0, section: 0)], mode: .description))
        }
    }
    
    func fetch(forModel model: HorizontalCollectionTableViewCellModel) {
        if let indexPath = model.indexPath {
            ImageDownloaderService.shared.requestImage(withURL: model.imageURL) { [weak self] (error) in
                guard error == nil else { return }
                self?.models.onNext(CharacterViewModelViewer(indexes: [indexPath], mode: .description))
            }
        }
    }
    
    func fetchComics(forCharacter character: Character) {
        let group = DispatchGroup()
        
        for index in 0..<character.comicIds.count {
            let object = character.comicIds.object(at: index)
            group.enter()
            CharactersService.fetchComic(withID: "\(object.id.intValue)") { (response, error) in
                self.isLoading.onNext(false)
                
                if let caughtError = error {
                    self.defaultErrorHandler(withError: caughtError)
                    return
                }
                
                if let result = response?.results.first {
                    let comic = ResourceList()
                    comic.id = NSNumber(integerLiteral: result.id)
                    comic.name = result.title
                    comic.image = "\(result.thumbnail.path).\(result.thumbnail.extensionString)"
                    self.model?.comics.add(comic)
                }
                
                group.leave()
            }
        }
        
        group.notify(queue: DispatchQueue.main) { [weak self] in
            self?.models.onNext(CharacterViewModelViewer(indexes: [IndexPath(row: 0, section: 1)], mode: .comics))
        }
    }
    
    func fetchSeries(forCharacter character: Character) {
        let group = DispatchGroup()
        
        for index in 0..<character.serieIds.count {
            let object = character.serieIds.object(at: index)
            group.enter()
            CharactersService.fetchComic(withID: "\(object.id.intValue)") { (response, error) in
                self.isLoading.onNext(false)
                
                if let caughtError = error {
                    self.defaultErrorHandler(withError: caughtError)
                    return
                }
                
                if let result = response?.results.first {
                    let series = ResourceList()
                    series.id = NSNumber(integerLiteral: result.id)
                    series.name = result.title
                    series.image = "\(result.thumbnail.path).\(result.thumbnail.extensionString)"
                    self.model?.serie.add(series)
                }
                
                group.leave()
            }
        }
        
        group.notify(queue: DispatchQueue.main) { [weak self] in
            if let count = self?.model?.comics.count {
                self?.models.onNext(CharacterViewModelViewer(indexes: [IndexPath(row: 0,
                                                                                 section: count > 0 ? 2 : 1)],
                                                             mode: .series))
            }
        }
    }
}
