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
}

class CharactersCollectionView: UICollectionView {
    
    let defaultLateralPadding: CGFloat = 8.0
    
    var pathsToInsert: [IndexPath]?
    var datasource: [CharactersCollectionViewModel]? {
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
        dataSource = self
        register(cellWithNibName: "CharactersCollectionViewCell")
        configureRefreshControl()
        configureFlowLayout()
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
            
            if indexPath.item == datasource.count - 1 {
                charactersCollectionViewDelegate?.didReachTheEnd()
            }
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
