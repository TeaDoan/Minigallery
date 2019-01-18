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
    private var activeScrollView: UIScrollView?
    
    private let videoCellIdentifier = "collectionCell"
    private let imageCellIdentifier = "imageCell"

    private lazy var videoCollectionView: UICollectionView = {
        let cellSize = view.bounds.size
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = cellSize
        flowLayout.scrollDirection = .horizontal
        flowLayout.sectionInset = .zero
        flowLayout.minimumLineSpacing = 0
        let video = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
        video.register(VideoCollectionViewCell.self, forCellWithReuseIdentifier: videoCellIdentifier)
        video.delegate = self
        video.dataSource = self
        video.backgroundColor = .white
        return video
    }()
    
    private lazy var imageCollectionView: UICollectionView = {
        let frame = CGRect(x: 0,
                           y: view.bounds.height * 3 / 4,
                           width: view.bounds.width,
                           height: view.bounds.height / 4)
        let cellWidth = frame.width / 2
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: cellWidth, height: frame.height)
        flowLayout.sectionInset = .init(top: 0, left: cellWidth / 2, bottom: 0, right: cellWidth / 2)
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = 0
        let image = UICollectionView(frame: frame, collectionViewLayout: flowLayout)
        image.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: imageCellIdentifier)
        image.delegate = self
        image.dataSource = self
        image.backgroundColor = .white
        return image
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(videoCollectionView)
        view.addSubview(imageCollectionView)
    }

    override func viewWillAppear(_ animated: Bool) {
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

    private func scaleImages() {
        let collectionWidth = Float(imageCollectionView.bounds.width)
        let collectionCenter = imageCollectionView.bounds.width / 2

        imageCollectionView.indexPathsForVisibleItems.forEach {
            let attributes = imageCollectionView.layoutAttributesForItem(at: $0)!
            let cellFrame = imageCollectionView.convert(attributes.frame, to: nil)
            let cellCenter = cellFrame.origin.x + (cellFrame.width / 2)

            let cell = imageCollectionView.cellForItem(at: $0) as! ImageCollectionViewCell
            cell.scaleImageView(1 - fabsf(Float((cellCenter - collectionCenter))) / collectionWidth)
        }
    }

}

extension GalleryViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return scenes.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == videoCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: videoCellIdentifier, for: indexPath) as! VideoCollectionViewCell
            cell.video = scenes[indexPath.row]
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: imageCellIdentifier, for: indexPath) as! ImageCollectionViewCell
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
        } else {
            (cell as! ImageCollectionViewCell).scaleImageView(0.5)
        }
    }

    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if collectionView == videoCollectionView {
            (cell as! VideoCollectionViewCell).stop()
        }
    }
}

extension GalleryViewController: UICollectionViewDelegate {

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        activeScrollView = scrollView
    }

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
        guard scrollView == activeScrollView else { return }
        if scrollView == videoCollectionView  {
            imageCollectionView.contentOffset = CGPoint(x: scrollView.contentOffset.x / 2, y: 0)
        } else {
            videoCollectionView.contentOffset = CGPoint(x: scrollView.contentOffset.x * 2, y: 0)
        }
        scaleImages()
    }

}
