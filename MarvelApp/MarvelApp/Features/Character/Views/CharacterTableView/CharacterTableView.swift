//
//  CharacterTableView.swift
//  MarvelApp
//
//  Created by Rafael Lucena on 11/24/19.
//  Copyright © 2019 RLMG. All rights reserved.
//

import UIKit

protocol CharacterTableViewCellProtocol: UITableViewCell {
    var model: CharacterTableViewModel? { get set }
    var delegate: CharacterViewDelegate? { get set }

    static func heightFor(character: Character, andFrame frame: CGRect) -> CGFloat
}

enum CharacterTableViewModelMode {
    case none, comic, serie
}

struct CharacterTableViewModel {
    var cellClassName: String
    var header: String
    var height: CGFloat
    var character: Character
    var mode: CharacterTableViewModelMode
}

class CharacterTableView: UITableView {
    
    private var datasource: [CharacterTableViewModel] = []
    var model: Character? {
        didSet {
            if model != nil {
                configureDatasource()
                reloadData()
            }
        }
    }
    
    var characterDelegate: CharacterViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        delegate = self
        dataSource = self
        
        registerCells()
        separatorStyle = .none
    }
    
    private func registerCells() {
        register(UINib(nibName: "CharacterImageDescriptionTableViewCell",
                       bundle: nil),
                 forCellReuseIdentifier: "CharacterImageDescriptionTableViewCell")
        register(UINib(nibName: "HorizontalCollectionTableViewCell",
                       bundle: nil),
                 forCellReuseIdentifier: "HorizontalCollectionTableViewCell")
    }
}

extension CharacterTableView {
    
    private func configureDatasource() {
        if let model = model {
            datasource = [
                CharacterTableViewModel(cellClassName: "CharacterImageDescriptionTableViewCell",
                                        header: "",
                                        height: CharacterImageDescriptionTableViewCell.heightFor(character: model,
                                                                                                 andFrame: frame),
                                        character: model,
                                        mode: .none),
                CharacterTableViewModel(cellClassName: "HorizontalCollectionTableViewCell",
                                        header: "Comics",
                                        height: HorizontalCollectionTableViewCell.heightFor(character: model,
                                                                                            andFrame: frame),
                                        character: model,
                                        mode: .comic),
                CharacterTableViewModel(cellClassName: "HorizontalCollectionTableViewCell",
                                        header: "Series",
                                        height: HorizontalCollectionTableViewCell.heightFor(character: model,
                                                                                            andFrame: frame),
                                        character: model,
                                        mode: .serie),

            ]
        }
    }
}

extension CharacterTableView: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return datasource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = datasource[indexPath.section]
        let cell = tableView.dequeueReusableCell(withIdentifier: model.cellClassName)
        
        guard let castedCell = cell as? CharacterTableViewCellProtocol else {
            assert(false, "This should be a know cell type")
            return UITableViewCell()
        }
        
        castedCell.delegate = self
        castedCell.model = model
        
        return castedCell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch datasource[section].mode {
        case .none:
            return datasource[section].header
        case .serie:
            return datasource[section].character.serieIds.count > 0 ? datasource[section].header :
            ""
        case .comic:
            return datasource[section].character.comicIds.count > 0 ? datasource[section].header :
            ""
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch datasource[indexPath.section].mode {
        case .none:
            return datasource[indexPath.section].height
        case .serie:
            return datasource[indexPath.section].character.serieIds.count > 0 ? datasource[indexPath.section].height :
            0
        case .comic:
            return datasource[indexPath.section].character.comicIds.count > 0 ? datasource[indexPath.section].height :
            0
        }
    }
}

extension CharacterTableView: CharacterViewDelegate {
    func needsImageFetchRequest(forModel model: HorizontalCollectionTableViewCellModel) {
        characterDelegate?.needsImageFetchRequest(forModel: model)
    }
    
    func fetchComics() {
        characterDelegate?.fetchComics()
    }
    
    func fetchSeries() {
        characterDelegate?.fetchSeries()
    }
    
    func needsImageFetchRequest(forCharacter character: Character) {
        characterDelegate?.needsImageFetchRequest(forCharacter: character)
    }
}
