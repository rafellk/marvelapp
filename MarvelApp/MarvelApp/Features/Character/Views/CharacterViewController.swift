//
//  CharacterViewController.swift
//  MarvelApp
//
//  Created by Rafael Lucena on 11/24/19.
//  Copyright © 2019 RLMG. All rights reserved.
//

import UIKit
import GSImageViewerController

class CharacterViewController: UIViewController {

    // IBOutlets variables
    @IBOutlet weak var tableView: CharacterTableView!
    
    // Model variables
    var model: Character?
    
    // View Model variables
    var viewModel: CharacterViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.model = model
        tableView.characterDelegate = self
        
        configureViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationItem()
    }
    
    private func configureNavigationItem() {
        navigationController?.navigationBar.prefersLargeTitles = false
        
        if let model = model {
            navigationItem.title = model.name
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: model.isFavorite.boolValue ? UIImage(systemName: "star.fill") : UIImage(systemName: "star"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(favoriteButtonPressed))
        }
    }
}

// User actions
extension CharacterViewController {
    
    @objc
    func favoriteButtonPressed() {
        if let model = model {
            let isFavorite = NSNumber(booleanLiteral: !model.isFavorite.boolValue)
            navigationItem.rightBarButtonItem?.image = isFavorite.boolValue ? UIImage(systemName: "star.fill") : UIImage(systemName: "star")
            viewModel?.favorite(character: model)
        }
    }
}

extension CharacterViewController {
    
    private func configureViewModel() {
        viewModel = CharacterViewModel(withPresenter: self, model: model)
        
        let _ = viewModel?.modelsObservable.subscribe(onNext: { [weak self] (value) in
            switch value.mode {
            case .description, .comics, .series:
                if !value.indexes.isEmpty {
                    self?.tableView.reloadRows(at: value.indexes, with: .automatic)
                }
                break
            }
        })
    }
}

extension CharacterViewController: CharacterViewDelegate {
    
    func viewImage(_ image: UIImage) {
        let imageInfo = GSImageInfo(image: image, imageMode: .aspectFit, imageHD: nil)
        let transitionInfo = GSTransitionInfo(fromView: view)
        let imageViewer = GSImageViewerController(imageInfo: imageInfo, transitionInfo: transitionInfo)
        present(imageViewer, animated: true, completion: nil)
    }
    
    func needsImageFetchRequest(forModel model: HorizontalCollectionTableViewCellModel) {
        viewModel?.fetch(forModel: model)
    }
    
    func fetchComics() {
        if let model = model {
            viewModel?.fetchComics(forCharacter: model)
        }
    }
    
    func fetchSeries() {
        if let model = model {
            viewModel?.fetchSeries(forCharacter: model)
        }
    }
    
    func needsImageFetchRequest(forCharacter character: Character) {
        viewModel?.fetchThumbnail(character: character)
    }
}
