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
            imageView.translatesAutoresizingMaskIntoConstraints = true
            imageView.sizeToFit()
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
