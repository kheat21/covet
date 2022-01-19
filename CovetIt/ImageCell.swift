//
//  ImageCell.swift
//  CovetIt
//
//  Created by Covet on 1/18/22.
//

import UIKit

class ImageCell: UICollectionViewCell {
        
    let imageView: UIImageView = {
            let imageView = UIImageView()
            imageView.backgroundColor = UIColor.green
            imageView.image = UIImage(named: "Covet_Logo_BW")
            imageView.translatesAutoresizingMaskIntoConstraints = true
            imageView.sizeToFit()
            imageView.sd_setImage(with: URL(string: "https://images.unsplash.com/photo-1642265538249-1dd3cb45cfb2?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=2535&q=80")) { image, err, cacheType, url in
                print("Got the image")
            }
        
            return imageView
    }()
    
    override init(frame: CGRect) {
        print("Initing ImageCell")
        super.init(frame: frame)
        self.addSubview(imageView)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        imageView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        imageView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: frame.height).isActive = true
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
