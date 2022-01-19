//
//  TableViewController.swift
//  CovetIt
//
//  Created by Covet on 1/18/22.
//

import UIKit

class TableViewController: UIViewController,  UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {

    
    
    var imageData: [String] = [String]()
    var imageCounter: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        imageData = ["box-8", "box-9"]
        print("LOADED TABLE VIEW CONTROLLER")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("VIEW APPEARED")
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: 60, height: 60)
        
        let collectionView = UICollectionView(
            frame: CGRect(
                x: 0,
                y: 0,
                width: self.view.frame.width,
                height: self.view.frame.height
            ),
            collectionViewLayout: layout
        )
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: "MyImageCell")
        
        self.view.addSubview(collectionView)
        
        collectionView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("Getting item...")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyImageCell", for: indexPath as IndexPath) as! ImageCell
            cell.backgroundColor = UIColor.blue
            var currImage:String = ""
            currImage = self.imageData[self.imageCounter]
            self.imageCounter += 1
            if self.imageCounter >= self.imageData.count {
                    self.imageCounter = 0
            }
        
            // cell.image.image = UIImage(named: currImage)
            return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("Was asked for number of items")
        return 20
        
     }
    
}
