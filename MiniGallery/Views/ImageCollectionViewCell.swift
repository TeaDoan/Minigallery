//
//  ImageCollectionViewCell.swift
//  MiniGallery
//
//  Created by Thao Doan on 1/13/19.
//  Copyright © 2019 Thao Doan. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    func scaleImageView(_ scale: Float) {
        imageView.transform = CGAffineTransform(scaleX: CGFloat(scale), y: CGFloat(scale))
    }
}
