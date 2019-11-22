//
//  CharactersCollectionView.swift
//  MarvelApp
//
//  Created by Rafael Lucena on 11/12/19.
//  Copyright © 2019 RLMG. All rights reserved.
//

import UIKit

protocol CharactersCollectionViewDelegate: NSObjectProtocol {
    func didPullRefresh()
    func didReachTheEnd()
    func didFavorite(character: Character)
    func needsImageFetchRequest(character: Character)
}

class CharactersCollectionView: UICollectionView {
    
    let defaultLateralPadding: CGFloat = 8.0
    var didReachTheEnd = false
    var isFiltering = false
    var isInfiniteScrollActivated = true
    
    var pathsToInsert: [IndexPath]?
    var datasource: [Character]? {
        willSet {
            endRefreshing()
            if let newValueCount = newValue?.count,
                let currentValueCount = datasource?.count,
                currentValueCount > 0,
                pathsToInsert == nil,
                currentValueCount < newValueCount {
                pathsToInsert = [IndexPath]()
                
                for i in currentValueCount..<newValueCount {
                    pathsToInsert?.append(IndexPath(item: i, section: 0))
                }
            }
        }
        didSet {
            // todo: remove this from here
            didReachTheEnd = false
            
            if pathsToInsert != nil {
                insertMoreItems()
            } else {
                DispatchQueue.main.async { [weak self] in
                    self?.reloadData()
                }
            }
        }
    }
    
    weak var charactersCollectionViewDelegate: CharactersCollectionViewDelegate?
    
    private let sectionInsets = UIEdgeInsets(top: 8,
                                             left: 16,
                                             bottom: 8,
                                             right: 20)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        delegate = self
        dataSource = self
                
        configureRefreshControl()
        register(cellWithNibName: "CharactersCollectionViewCell")
    }
}

extension CharactersCollectionView: UICollectionViewDelegateFlowLayout {
    
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

// UICollectionViewDataSource extension
extension CharactersCollectionView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return datasource?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CharactersCollectionViewCellID",
                                                            for: indexPath) as? CharactersCollectionViewCell
        guard let unwrappedCell = cell else {
            assert(false, "Dequeued a table view cell that is not subclass of CharactersCollectionViewCell")
            return UICollectionViewCell()
        }
        
        if let datasource = datasource {
            unwrappedCell.delegate = self
            unwrappedCell.model = datasource[indexPath.row]
        }
        
        return unwrappedCell
    }
}

// Refresh control methods
extension CharactersCollectionView {
    
    fileprivate func configureRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
    }
    
    @objc
    private func refresh() {
        charactersCollectionViewDelegate?.didPullRefresh()
    }
    
    func endRefreshing() {
        refreshControl?.endRefreshing()
    }
}

// Collection view update
extension CharactersCollectionView {
    
    fileprivate func insertMoreItems() {
        // todo: handle error here
        guard let paths = pathsToInsert else { return }
        
        isUserInteractionEnabled = false
        performBatchUpdates({
            self.insertItems(at: paths)
        }, completion: { [weak self] result in
            if result {
                self?.pathsToInsert = nil
            }
            
            self?.isUserInteractionEnabled = true
        })
    }
}

extension CharactersCollectionView: UICollectionViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let height = scrollView.frame.size.height
        
        let contentYoffset = scrollView.contentOffset.y
        let distanceFromBottom = scrollView.contentSize.height - contentYoffset
        
        if let empty = datasource?.isEmpty, !empty, distanceFromBottom < height, !didReachTheEnd, !isFiltering, isInfiniteScrollActivated {
            didReachTheEnd = true
            charactersCollectionViewDelegate?.didReachTheEnd()
        }
    }
}

// CharactersCollectionViewCellDelegate extension
extension CharactersCollectionView: CharactersCollectionViewCellDelegate {
    
    func didFavorite(character: Character) {
        charactersCollectionViewDelegate?.didFavorite(character: character)
    }
    
    func needsImageFetchRequest(forCharacter character: Character) {
        charactersCollectionViewDelegate?.needsImageFetchRequest(character: character)
    }
}
