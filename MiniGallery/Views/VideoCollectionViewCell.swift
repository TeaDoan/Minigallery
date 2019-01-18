//
//  VideoCollectionViewCell.swift
//  MiniGallery
//
//  Created by Thao Doan on 1/11/19.
//  Copyright © 2019 Thao Doan. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class VideoCollectionViewCell: UICollectionViewCell {

    var video: GalleryScene?
    
    lazy var videoView: UIView = {
        let view  = UIView(frame: self.frame)
        view.frame = .init(x: 0, y: 0,
                           width: view.frame.width,
                           height: view.frame.height / 2)
        return view
    }()

    weak var videoWidthConstraint: NSLayoutConstraint!
    
    private var player: AVPlayer?

    var avpController = AVPlayerViewController()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(videoView)
        videoView.anchor(left: contentView.leftAnchor, right: contentView.rightAnchor, height: contentView.bounds.width)
        NSLayoutConstraint(item: videoView, attribute: .centerX, relatedBy: .equal, toItem: contentView, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: videoView, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 0.8, constant: 0).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func play() {
        guard let video = video, let url = URL(string: video.videoUrl) else { return }
        player = MediaCache.shared.videoPlayer(for: url)
        avpController.player = player

        avpController.view.frame = videoView.bounds

        avpController.videoGravity = .resize
        avpController.showsPlaybackControls = false

        videoView.addSubview(avpController.view)
        player?.play()
    }

    func stop() {
        player?.pause()
    }

}
