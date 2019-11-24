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
    static func heightFor(character: Character, andFrame frame: CGRect) -> CGFloat
}

struct CharacterTableViewModel {
    var cellClassName: String
    var header: String
    var height: CGFloat
    var character: Character
}

class CharacterTableView: UITableView {
    
    private var datasource: [CharacterTableViewModel] = []
    var model: Character?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        delegate = self
        dataSource = self
        
        configureDatasource()
    }
}

extension CharacterTableView {
    
    private func configureDatasource() {
        if let model = model {
            datasource = [
                // todo: do it here
                CharacterTableViewModel(cellClassName: "CharacterImageDescriptionTableViewCell",
                                        header: "",
                                        height: CharacterImageDescriptionTableViewCell.heightFor(character: model,
                                                                                                 andFrame: frame),
                                        character: model)
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
        
        castedCell.model = model
        return castedCell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return datasource[section].header
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return datasource[indexPath.section].height
    }
}
