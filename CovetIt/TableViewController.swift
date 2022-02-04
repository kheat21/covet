//
//  TableViewController.swift
//  CovetIt
//
//  Created by Covet on 1/18/22.
//

import UIKit
import SocketIO

class TableViewController: UIViewController,  UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    var collectionView: UICollectionView?
    var loadingView: UIActivityIndicatorView?
    
    var selectedImageCallback: ((_ image: ScrapedImage) -> Void)?;
    var images: [ScrapedImage] = [ScrapedImage]()
    
    var alreadyConfigured: Bool = false
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if alreadyConfigured {
            return
        }
        alreadyConfigured = true
        
        view.backgroundColor = .white
        
        let navBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 44))
        view.addSubview(navBar)

        let navItem = UINavigationItem(title: "Pick a Thumbnail")
        let cancelItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: #selector(self.cancel))
        cancelItem.tintColor = UIColor.covetGreen
        navItem.leftBarButtonItem = cancelItem

        navBar.setItems([navItem], animated: false)

        let wholeViewFrame = CGRect(
            x: 0,
            y: 44,
            width: self.view.frame.width,
            height: self.view.frame.height - 44
        )
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: 120, height: 120)
        
        self.collectionView = UICollectionView(
            frame: wholeViewFrame,
            collectionViewLayout: layout
        )
        self.collectionView!.delegate = self
        self.collectionView!.dataSource = self
        self.collectionView!.register(ImageCell.self, forCellWithReuseIdentifier: "MyImageCell")
        
        
        self.loadingView = UIActivityIndicatorView(frame: wholeViewFrame)
        self.loadingView!.startAnimating()
        self.view.addSubview(self.loadingView!)
        
        self.showCollectionView()
        
    }

    func addImage(image: ScrapedImage) {
        print("Setting the images...")
        self.images.append(image)
        self.images = self.images.sorted(by: { image1, image2 in
            return image1.size() > image2.size()
        })
        self.collectionView?.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (self.view.frame.width / 2) - 16, height: (self.view.frame.width / 2) - 16)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyImageCell", for: indexPath as IndexPath) as! ImageCell
        cell.imageView.image = self.images[indexPath.row].image
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let callback = self.selectedImageCallback {
            callback(self.images[indexPath.row])
        }
        // self.navigationController?.popViewController(animated: true)
    }
    
    public func setSelectedImageHandler(callback: @escaping (_ image: ScrapedImage) -> Void) {
        self.selectedImageCallback = callback
    }
    
    private func showCollectionView() {
        self.loadingView?.removeFromSuperview()
        self.view.addSubview(collectionView!)
    }
    
    @objc func cancel() {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
}
