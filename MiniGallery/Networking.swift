//
//  Networking.swift
//  MiniGallery
//
//  Created by Thao Doan on 1/10/19.
//  Copyright © 2019 Thao Doan. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class Networking {
  
   static let baseURL = URL(string: "http://private-04a55-videoplayer1.apiary-mock.com/pictures")
    
    static func getGallery(completion : @escaping ([GalleryScene]?) -> Void) {
        guard let url = baseURL else {completion(nil);return}
        var request = URLRequest(url: url)
        request.httpBody = nil
        request.httpMethod = "GET"
        URLSession.shared.dataTask(with: request) { (data, response, err) in
            if let err = err {
                print("Fail sending request,\(err.localizedDescription)")
                completion(nil)
                return
            }
            guard let data = data else {completion(nil);return}
            let jsonDecoder = JSONDecoder()
            do {
                let galleryData = try jsonDecoder.decode([GalleryScene].self, from: data)
                completion(galleryData)
                return
            } catch let err {
                print ("Fail getting back, \(err.localizedDescription)")
            }
            }.resume()
    }
    
    static func fetchVideoData(withURL: String, completion: @escaping ((Data?)-> Void)) {
        guard let url = URL(string: withURL) else { completion(nil); return }
        var request = URLRequest(url: url)
        request.httpBody = nil
        request.httpMethod = "GET"
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                print("\(error)")
                completion(nil)
                return
            }
            completion(data)
        }.resume()
    }
    
    static func fetchImage(withURL : String, completion: @escaping ((UIImage?)-> Void)) {
        guard let url = URL(string: withURL) else {completion(nil); return}
        var request = URLRequest(url: url)
        request.httpBody = nil
        request.httpMethod = "GET"
        URLSession.shared.dataTask(with: request) { (data,_, error) in
            if let error = error {
                print("\(error)")
                completion(nil)
                return
            }
            guard let data = data,
                let image = UIImage(data: data) else {completion(nil);return}
            completion(image)
        }.resume()
    }
    
}
