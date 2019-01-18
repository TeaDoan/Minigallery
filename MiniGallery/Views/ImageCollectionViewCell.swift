//
//  ImageCollectionViewCell.swift
//  MiniGallery
//
//  Created by Thao Doan on 1/13/19.
//  Copyright © 2019 Thao Doan. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    lazy var imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(imageView)
        imageView.anchor(top: contentView.topAnchor, bottom: contentView.bottomAnchor)
        NSLayoutConstraint(item: imageView, attribute: .centerX, relatedBy: .equal, toItem: contentView, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: imageView, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func scaleImageView(_ scale: Float) {
        imageView.transform = CGAffineTransform(scaleX: CGFloat(scale), y: CGFloat(scale))
    }
}
