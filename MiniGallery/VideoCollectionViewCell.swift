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
    var url =  [String]()
    
    var video : Gallery?
    
    @IBOutlet weak var videoView: UIView!
    
    private var player: AVPlayer?
    
    var avpController = AVPlayerViewController()
    
    func play() {
        guard let video = video, let url = URL(string: video.videoUrl) else { return }
        player = AVPlayer(url :  url)
        avpController.player = player
        
        avpController.view.frame.size.height = videoView.frame.size.height
        
        avpController.view.frame.size.width = videoView.frame.size.width
        
        videoView.addSubview(avpController.view)
        player?.play()
    }
    
    func stop() {
        player?.pause()
        player = nil
    }
    
}
