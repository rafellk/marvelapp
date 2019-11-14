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
}

class CharactersCollectionView: UICollectionView {
    
    let defaultLateralPadding: CGFloat = 8.0
    var datasource: [CharactersCollectionViewModel]? {
        willSet {
            endRefreshing()
        }
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.reloadData()
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
        }
        
        if let model = datasource?[indexPath.row] {
            unwrappedCell.model = model
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
    
    fileprivate func endRefreshing() {
        refreshControl?.endRefreshing()
    }
}
