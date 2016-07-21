//
//  SFCollectionViewFlowLayout.swift
//  CollectionViewInfiniteScrollingDemo
//
//  Created by AT on 7/21/16.
//  Copyright © 2016 AT. All rights reserved.
//

import Foundation
import UIKit

class SFCollectionViewFlowLayout: UICollectionViewFlowLayout {
    override func collectionViewContentSize() -> CGSize {
        let contentSize = super.collectionViewContentSize()
        let viewHeight = collectionView!.bounds.size.height
        
        if contentSize.height < viewHeight {
            return CGSizeMake(contentSize.width, viewHeight + 100)
        }
        return contentSize
    }
}
