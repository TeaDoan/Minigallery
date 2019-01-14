//
//  GalleryViewController.swift
//  MiniGallery
//
//  Created by Thao Doan on 1/11/19.
//  Copyright © 2019 Thao Doan. All rights reserved.
//

import UIKit

class GalleryViewController: UIViewController{
    
    private var scenes = [GalleryScene]()
    private var pageForDisplay = 0
    
    @IBOutlet weak var imageCollectionView: UICollectionView!
    @IBOutlet weak var videoCollectionView: UICollectionView!
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        updateLayout()
        if UIDevice.current.orientation == .portrait {
            setVideoConstraints(width: videoCollectionView.bounds.width)
        } else {
            setVideoConstraints(width: videoCollectionView.bounds.height)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateLayout()
        setVideoConstraints(width: videoCollectionView.bounds.width)
        fetchGallery()
    }
    
    private func fetchGallery() {
        Networking.getGallery { [weak self] galleries in
            self?.scenes = galleries ?? []
            DispatchQueue.main.async {
                self?.videoCollectionView.reloadData()
                self?.imageCollectionView.reloadData()
            }
        }
    }
    
    private func setVideoConstraints(width: CGFloat) {
        (videoCollectionView.visibleCells as? [VideoCollectionViewCell])?.forEach {
            $0.videoWidthConstraint.constant = width
        }
    }
    
    private func updateLayout() {
        if let flowLayout = videoCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.itemSize = CGSize(width: videoCollectionView.bounds.width, height: videoCollectionView.bounds.height)
        }
        if let flowLayout = imageCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let cellWidth = imageCollectionView.bounds.width / 2
            flowLayout.itemSize = CGSize(width: cellWidth, height: imageCollectionView.bounds.height)
            flowLayout.sectionInset = UIEdgeInsets.init(top: 0, left: cellWidth / 2, bottom: 0, right: cellWidth / 2)
        }
    }

}

extension GalleryViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return scenes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == videoCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "videoCell", for: indexPath) as! VideoCollectionViewCell
            cell.video = scenes[indexPath.row]
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! ImageCollectionViewCell
            let imageUrl = scenes[indexPath.row].imageUrl
            Networking.fetchImage(withURL: imageUrl) { image in
                DispatchQueue.main.async {
                    guard let image = image else {return}
                    cell.imageView.image = image
                }
            }
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if collectionView == videoCollectionView {
            pageForDisplay = indexPath.item
            (cell as! VideoCollectionViewCell).play()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if collectionView == videoCollectionView {
            (cell as! VideoCollectionViewCell).stop()
        }
    }
}

extension GalleryViewController: UICollectionViewDelegate {
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {

        let collectionView = scrollView as! UICollectionView
        let pageWidth = Float((collectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize.width)
        let targetXContentOffset = Float(targetContentOffset.pointee.x)
        let contentWidth = Float(collectionView.contentSize.width)
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
        if scrollView == videoCollectionView {
            imageCollectionView.contentOffset = CGPoint(x: scrollView.contentOffset.x / 2, y: 0)
        } else {
            videoCollectionView.contentOffset = CGPoint(x: scrollView.contentOffset.x * 2, y: 0)
        }
    }
    
}
