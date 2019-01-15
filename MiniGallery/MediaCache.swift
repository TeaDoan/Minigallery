//
//  MediaCache.swift
//  MiniGallery
//
//  Created by Thao Doan on 1/14/19.
//  Copyright © 2019 Thao Doan. All rights reserved.
//

import Foundation
import AVKit
import AVFoundation

class MediaCache {
    static let shared = MediaCache()
    
    private var documentsDir: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    private func savePath(for webURL: URL) -> URL? {
        // example video URL
        // https://media.giphy.com/media/l0ExncehJzexFpRHq/giphy.mp4
        var components = webURL.pathComponents
        guard components.count > 3, let fileName = components.popLast() else { return nil }
        return documentsDir
            .appendingPathComponent(components.last! + "-" + fileName)
    }

    func videoPlayer(for webURL: URL) -> AVPlayer?  {
        guard let savePath = savePath(for: webURL)?.path else { return nil }
        let fm = FileManager.default
        
        if fm.fileExists(atPath: savePath) {
            return AVPlayer(url: URL(fileURLWithPath: savePath))
        } else {
            Networking.fetchVideoData(withURL: webURL.absoluteString) { data in
                if let data = data, !fm.fileExists(atPath: savePath) {
                    do {
                        try data.write(to: URL(fileURLWithPath: savePath))
                    } catch let err {
                        print(err.localizedDescription)
                    }
                }
            }
            return AVPlayer(url: webURL)
        }
    }

}

