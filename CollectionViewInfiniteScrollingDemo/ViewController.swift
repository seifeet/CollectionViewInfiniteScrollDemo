//
//  ViewController.swift
//  CollectionViewInfiniteScrollingDemo
//
//  Created by AT on 7/20/16.
//  Copyright © 2016 AT. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var data:Array<String> = []

    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    private struct Constants {
        static let ImageCellIdentifier: String = "ImageCell"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        generateRandomData()
        configureView()
        refresh()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureView() {
        
        // Set custom indicator margin
        collectionView.sf_infiniteScrollIndicatorMargin = 40
        
        // Call handler as soon as needed
        collectionView.sf_callInfiniteScrollHandlerWhileScrolling = true
        
        // Set trigger offset
        collectionView?.sf_infiniteScrollTriggerOffset = 500
        
        // Add infinite scroll handler
        collectionView.sf_addInfiniteScrollWithHandler { [weak self] (scrollView) -> Void in
            print("InfiniteScroll handler triggered")
            guard let strongSelf = self else {
                return
            }
            strongSelf.addMoreData()
        }
    }
    
    deinit {
        collectionView.sf_removeInfiniteScroll()
    }
    
    func addMoreData() {
        let beforeCount = data.count
        generateRandomData()
        let afterCount = data.count - 1
        var indexPaths = [NSIndexPath]()
        for index in beforeCount...afterCount {
            let indexPath = NSIndexPath(forItem: index, inSection: 0)
            indexPaths.append(indexPath)
        }
        
        collectionView.sf_finishInfiniteScrollWithCompletion { (scrollView) -> (Void) in
            
        }
        reloadEntries(indexPaths)
    }
    
    func refresh() {
        collectionView.reloadData()
    }
    
    func reloadEntries(indexPaths:[NSIndexPath]){
        self.collectionView.performBatchUpdates({ () -> Void in
            self.collectionView.insertItemsAtIndexPaths(indexPaths)
            }, completion: { (finished) -> Void in
                
        })
    }

    func generateRandomData() {
        
        let diceRoll = Int(arc4random_uniform(UInt32(2))) + 2
        
        for _ in 1...diceRoll {
            data.append(getRandomString(30))
        }
    }

    func getRandomString(maxLen : Int) -> String {
        
        let diceRoll = Int(arc4random_uniform(UInt32(maxLen))) + 2
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        
        let randomString : NSMutableString = NSMutableString(capacity: diceRoll)
        
        for _ in 1...(diceRoll) {
            let length = UInt32 (letters.length)
            let rand = arc4random_uniform(length)
            randomString.appendFormat("%C", letters.characterAtIndex(Int(rand)))
        }
        
        return String(randomString)
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let aCell = collectionView.dequeueReusableCellWithReuseIdentifier(Constants.ImageCellIdentifier, forIndexPath: indexPath) as! SFCollectionViewCell
        aCell.lblText.text = String(indexPath.item)
        return aCell
    }
}

