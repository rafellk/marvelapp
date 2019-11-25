//
//  HorizontalCollectionTableViewCell.swift
//  MarvelApp
//
//  Created by Rafael Lucena on 11/24/19.
//  Copyright © 2019 RLMG. All rights reserved.
//

import UIKit

struct HorizontalCollectionTableViewCellModel {
    var imageURL: String
    var title: String
    var indexPath: IndexPath?
}

class HorizontalCollectionTableViewCell: UITableViewCell, UICollectionViewDataSource, CharacterTableViewCellProtocol {
    
    // IBOutlets variables
    @IBOutlet weak var collectionView: UICollectionView!

    // Model variables
    var model: CharacterTableViewModel? {
        willSet {
            clear()
            
            if let value = newValue, model == nil {
                let mode = value.mode
                if mode == .comic &&
                    value.character.comics.count == 0 &&
                    value.character.comicIds.count > 0 {
                    showProgress()
                    delegate?.fetchComics()
                } else if mode == .serie {
                    delegate?.fetchSeries()
                }
            }
        }
        didSet {
            if model != nil {
                hideProgress()
                collectionView.reloadData()
            }
        }
    }

    // Delegate variables
    var delegate: CharacterViewDelegate?
    
    private let sectionInsets = UIEdgeInsets(top: 8,
                                             left: 16,
                                             bottom: 8,
                                             right: 20)
    var loadingView: LoadingView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureCollectionView()
        selectionStyle = .none
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        loadingView?.frame = frame
    }
    
    static func heightFor(character: Character, andFrame frame: CGRect) -> CGFloat {
        let numberOfLines: CGFloat = 2
        let paddingSpace = 16 * (numberOfLines + 1)
        
        let availableWidth = frame.width - paddingSpace
        let widthPerItem = availableWidth / numberOfLines

        return widthPerItem
    }
}

// CollectionView methods
extension HorizontalCollectionTableViewCell {
    
    private func clear() {
        hideProgress()
    }
        
    private func configureCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(UINib(nibName: "HorizontalCollectionViewCell",
                                      bundle: nil),
                                forCellWithReuseIdentifier: "HorizontalCollectionViewCell")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Int(bitPattern: model?.character.comics.count ?? 0)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HorizontalCollectionViewCell",
                                                      for: indexPath)
        
        guard let castedCell = cell as? HorizontalCollectionViewCell else {
            assert(false, "Unknown cell type")
            return UICollectionViewCell()
        }
        
        if let comic = model?.character.comics[UInt(indexPath.row)], let name = comic.name, let image = comic.image {
            castedCell.delegate = self
            castedCell.model = HorizontalCollectionTableViewCellModel(imageURL: image,
                                                                      title: name,
                                                                      indexPath: IndexPath(item: indexPath.item, section: indexPath.section))
        }
        
        return castedCell
    }
}

extension HorizontalCollectionTableViewCell: HorizontalCollectionViewCellDelegate {
    func needsImageFetchRequest(forModel model: HorizontalCollectionTableViewCellModel) {
        var theModel = model
        
        if let mode = self.model?.mode {
            switch mode {
            case .comic:
                theModel.indexPath = IndexPath(row: 0, section: 1)
                break
            case .serie:
                theModel.indexPath = IndexPath(row: 0, section: 2)
                break
            default:
                break
            }
        }
        
        delegate?.needsImageFetchRequest(forModel: theModel)
    }
}

extension HorizontalCollectionTableViewCell: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfLines: CGFloat = 2
        let paddingSpace = sectionInsets.left * (numberOfLines + 1)
        
        let availableWidth = frame.width - paddingSpace
        let widthPerItem = availableWidth / numberOfLines

        return CGSize(width: widthPerItem, height: widthPerItem)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.bottom
    }
}

// Progress extension
extension HorizontalCollectionTableViewCell {
    
    func showProgress() {
        if let loadingView = loadingView {
            loadingView.layer.opacity = 0
            
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.addSubview(loadingView)
                loadingView.layer.opacity = 1
            }
        }
    }
    
    func hideProgress() {
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.loadingView?.layer.opacity = 0
            self?.loadingView?.removeFromSuperview()
        }
    }
}

