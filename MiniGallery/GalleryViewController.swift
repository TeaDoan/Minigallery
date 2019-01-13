//
//  GalleryViewController.swift
//  MiniGallery
//
//  Created by Thao Doan on 1/11/19.
//  Copyright © 2019 Thao Doan. All rights reserved.
//

import UIKit

class GalleryViewController: UIViewController{
    
    private var videos = [GalleryScene]()
    private var pageForDisplay = 0
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        updateLayout()
        if UIDevice.current.orientation == .portrait {
            setVideoConstraints(width: collectionView.bounds.width)
        } else {
            setVideoConstraints(width: collectionView.bounds.height)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateLayout()
        setVideoConstraints(width: collectionView.bounds.width)
        fetchGallery()
    }
    
    private func fetchGallery() {
        Networking.getGallery { [weak self] galleries in
            self?.videos = galleries ?? []
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
            }
        }
    }
    
    private func setVideoConstraints(width: CGFloat) {
        (collectionView.visibleCells as? [VideoCollectionViewCell])?.forEach {
            $0.videoWidthConstraint.constant = width
        }
    }
    
    private func updateLayout() {
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.itemSize = CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height)
            flowLayout.minimumLineSpacing = 10
        }
    }

}

extension GalleryViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "videoCell", for: indexPath) as! VideoCollectionViewCell
        let video = videos[indexPath.row]
        cell.video = video
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        print("will display \(indexPath.item)")
        pageForDisplay = indexPath.item
        (cell as! VideoCollectionViewCell).play()
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        print("did display \(indexPath.item)")
        (cell as! VideoCollectionViewCell).stop()
    }
}

extension GalleryViewController: UICollectionViewDelegate {
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        let pageWidth = Float((collectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize.width + 10)
        let targetXContentOffset = Float(targetContentOffset.pointee.x)
        let contentWidth = Float(collectionView!.contentSize.width)
        var newPage = Float(pageForDisplay)
        
        if velocity.x == 0 {
            newPage = floor((targetXContentOffset - Float(pageWidth) / 2) / Float(pageWidth)) + 1.0
        } else {
            newPage = Float(velocity.x > 0 ? newPage + 1 : newPage - 1)
            if newPage < 0 {
                newPage = 0
            }
            if (newPage > contentWidth / pageWidth) {
                newPage = ceil(contentWidth / pageWidth) - 1.0
            }
        }
        
        let point = CGPoint (x: CGFloat(newPage * pageWidth), y: targetContentOffset.pointee.y)
        targetContentOffset.pointee = point
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.x
        let itemWidth = (collectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize.width
        print("x offset : \(offset)")
        print("itemWidth : \(itemWidth)")
    }
    
}

extension UIView {
    
    func anchorToTop(top: NSLayoutYAxisAnchor? = nil, left: NSLayoutXAxisAnchor? = nil, bottom: NSLayoutYAxisAnchor? = nil, right: NSLayoutXAxisAnchor? = nil) {
        
        anchorWithConstantsToTop(top: top, left: left, bottom: bottom, right: right, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0)
    }
    
    func anchorWithConstantsToTop(top: NSLayoutYAxisAnchor? = nil, left: NSLayoutXAxisAnchor? = nil, bottom: NSLayoutYAxisAnchor? = nil, right: NSLayoutXAxisAnchor? = nil, topConstant: CGFloat = 0, leftConstant: CGFloat = 0, bottomConstant: CGFloat = 0, rightConstant: CGFloat = 0) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            topAnchor.constraint(equalTo: top, constant: topConstant).isActive = true
        }
        
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -bottomConstant).isActive = true
        }
        
        if let left = left {
            leftAnchor.constraint(equalTo: left, constant: leftConstant).isActive = true
        }
        
        if let right = right {
            rightAnchor.constraint(equalTo: right, constant: -rightConstant).isActive = true
        }
        
    }
    
}

