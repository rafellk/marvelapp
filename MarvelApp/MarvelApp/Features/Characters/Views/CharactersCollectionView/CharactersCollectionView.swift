//
//  CharactersCollectionView.swift
//  MarvelApp
//
//  Created by Rafael Lucena on 11/12/19.
//  Copyright © 2019 RLMG. All rights reserved.
//

import UIKit

class CharactersCollectionView: UICollectionView {
    
    let defaultLateralPadding: CGFloat = 8.0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        register(cellWithNibName: "CharactersCollectionViewCell")
        delegate = self
        dataSource = self
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

extension CharactersCollectionView: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "CharactersCollectionViewCellID", for: indexPath)
    }
}
