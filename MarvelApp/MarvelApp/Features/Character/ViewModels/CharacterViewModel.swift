//
//  CharacterViewModel.swift
//  MarvelApp
//
//  Created by Rafael Lucena on 11/24/19.
//  Copyright © 2019 RLMG. All rights reserved.
//

import Foundation
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
    private var model: Character?
    
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
}
