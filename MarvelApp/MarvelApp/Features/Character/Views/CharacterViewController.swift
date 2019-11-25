//
//  CharacterViewController.swift
//  MarvelApp
//
//  Created by Rafael Lucena on 11/24/19.
//  Copyright © 2019 RLMG. All rights reserved.
//

import UIKit

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
        navigationController?.navigationBar.prefersLargeTitles = false
    }
}

extension CharacterViewController {
    
    private func configureViewModel() {
        viewModel = CharacterViewModel(withPresenter: self, model: model)
        let _ = viewModel?.isLoadingObservable.subscribe(onNext: { (value) in
            // todo: handle progress here
        })
        
        let _ = viewModel?.modelsObservable.subscribe(onNext: { [weak self] (value) in
            switch value.mode {
            case .description, .comics, .series:
                if !value.indexes.isEmpty {
                    self?.tableView.reloadRows(at: value.indexes, with: .automatic)
                }
                break
            default:
                break
            }
        })
    }
}

extension CharacterViewController: CharacterViewDelegate {
    
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
