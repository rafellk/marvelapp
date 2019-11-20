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
}

class CharactersCollectionView: UICollectionView {
    
    let defaultLateralPadding: CGFloat = 8.0
    var didReachTheEnd = false
    var isFiltering = false
    
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        delegate = self
        dataSource = self
                
        configureRefreshControl()
        configureFlowLayout()
        
        register(cellWithNibName: "CharactersCollectionViewCell")
    }
    
    private func configureFlowLayout() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(
            top: defaultLateralPadding,
            left: defaultLateralPadding,
            bottom: defaultLateralPadding,
            right: defaultLateralPadding
        )
        
        let width = frame.size.width
        let calculatedWidth = width / 2.4

        layout.itemSize = CGSize(width: calculatedWidth, height: calculatedWidth)
        layout.scrollDirection = .vertical
        collectionViewLayout = layout
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
            unwrappedCell.model = datasource[indexPath.row]
            unwrappedCell.delegate = self
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
        
        if let empty = datasource?.isEmpty, !empty, distanceFromBottom < height, !didReachTheEnd, !isFiltering {
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
}
