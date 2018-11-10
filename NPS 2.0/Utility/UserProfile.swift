//
//  UserProfile.swift
//  NPS 2.0
//
//  Created by Luis Alberto Ramirez on 8/8/18.
//  Copyright © 2018 Memes. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class ImageView {
    
    static let cacheImage = NSCache<NSString, UIImage>()
    
    static func downloadImageFirebase (imageRef: StorageReference, urlString: String,
                                       completion: @escaping (_ ima: UIImage?) -> ()) {
        var imagenS: UIImage? = nil
        var cancelTimer: Bool = false
        imageRef.downloadURL { url, error in
            if let error = error {
                print(error)
            } else {
                let data = NSData(contentsOf: url!)
                
                if let data = data {
                    imagenS = UIImage(data: data as Data)!
                }
                if imagenS != nil {
                    cacheImage.setObject(imagenS!, forKey: urlString as NSString)
                }
                DispatchQueue.main.async {
                    completion(imagenS)
                }
                cancelTimer = true
                if cancelTimer == true {
                    NotificationCenter.default.post(name: Notification.Name("cancelTimer"), object: nil)
                }
            }
        }
    }
    
    static func selectedImage (imageRef: StorageReference, urlString: String, completion: @escaping (_ image: UIImage?) -> ()) {
        var cancelTimer: Bool = false
        if let imageExist = ImageView.cacheImage.object(forKey: urlString as NSString) {
            completion(imageExist)
            cancelTimer = true
            if cancelTimer == true {
                NotificationCenter.default.post(name: Notification.Name("cancelTimer"), object: nil)
            }
        } else {
            downloadImageFirebase(imageRef: imageRef, urlString: urlString, completion: completion)
        }
    }
    
    static func downloadImg (withURL url: URL, completion: @escaping (_ image: UIImage?) -> ()) {
        let dataTask = URLSession.shared.dataTask(with: url) { data, responseURL, err in
            var downloadedImg: UIImage?
            if let data = data {
                downloadedImg = UIImage(data: data)
            }
            
            if downloadedImg != nil {
                cacheImage.setObject(downloadedImg!, forKey: url.absoluteString as NSString)
            }
            
            DispatchQueue.main.async {
                completion(downloadedImg)
            }
        }
        dataTask.resume()
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        print("Finished downloading file")
    }
    
    static func getImage(withURL url: URL, completion: @escaping (_ image: UIImage?) -> ()) {
        if let imageExist = cacheImage.object(forKey: url.absoluteString as NSString) {
            completion(imageExist)
        } else {
            downloadImg(withURL: url, completion: completion)
        }
    }
}

extension UIImage {
    func resizeImage(_ dimension: CGFloat, opaque: Bool, contentMode: UIView.ContentMode = .scaleAspectFit) -> UIImage {
        var width: CGFloat
        var height: CGFloat
        var newImage: UIImage
        
        let size = self.size
        let aspectRatio =  size.width/size.height
        
        switch contentMode {
        case .scaleAspectFit:
            if aspectRatio > 1 {                            // Landscape image
                width = dimension
                height = dimension / aspectRatio
            } else {                                        // Portrait image
                height = dimension
                width = dimension * aspectRatio
            }
            
        default:
            fatalError("Unimplemented ContentMode")
        }
        
        if #available(iOS 10.0, *) {
            let renderFormat = UIGraphicsImageRendererFormat.default()
            renderFormat.opaque = opaque
            let renderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: height), format: renderFormat)
            newImage = renderer.image {
                (context) in
                self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
            }
        } else {
            UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), opaque, 0)
            self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
            newImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
        }
        
        return newImage
    }
}
struct profile {
    var name: String = ""
    var mail: String = ""
    var profile:UIImage? = nil
    
}

struct valueUser {
    var promotor: Int = 0
    var neutro: Int = 0
    var detractor: Int = 0
    var note: String = ""
}
