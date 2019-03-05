//
//  S3PhotoManager.swift
//  OdishaHighCommand
//
//  Created by Hari Keerthipati on 07/01/19.
//  Copyright © 2019 Avantari Technologies. All rights reserved.
//

import Foundation
import UIKit
import AWSS3

class S3PhotoManager {
    
    let imageCache = NSCache<NSString, UIImage>()
    let photosBucketName =  "bucket name"
    static let shared = S3PhotoManager()

    func cachedImage(from url: URL) -> UIImage?
    {
        if let cachedImage = imageCache.object(forKey: url.path as NSString) {
            return cachedImage
        }
        else
        {
            return nil
        }
    }
    
    private func downloadImage(inBucket bucket: String, from fileName: String, completion: @escaping (String, UIImage?, Error?) -> Void)
    {
        let downloadFilePath =  NSTemporaryDirectory().appending(fileName)
        let downloadingFileURL = NSURL.fileURL(withPath: downloadFilePath)
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType: AWSRegionType.USEast1, identityPoolId: "us-east-1:aaaaaaa-bbbbb-cccc-dddd-eeeeeeeeee")
        let defaultServiceConfiguration = AWSServiceConfiguration( region: AWSRegionType.USEast1, credentialsProvider: credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = defaultServiceConfiguration
        let downloadRequest = AWSS3TransferManagerDownloadRequest()
        downloadRequest?.bucket = bucket
        
        downloadRequest?.key = fileName
        downloadRequest?.downloadingFileURL = downloadingFileURL
        let transferManager = AWSS3TransferManager.default()
        DispatchQueue.global().async {
            transferManager.download(downloadRequest!).continueWith { (task) -> Any? in
                if task.error != nil
                {
                    print(task.error.debugDescription)
                    completion(fileName, nil, task.error)
                } else {
                    if let image = UIImage(contentsOfFile: downloadFilePath)
                    {
                        self.imageCache.setObject(image, forKey: fileName as NSString)
                        completion(fileName, image, nil)
                    }
                }
                return nil
            }
        }
    }
    
    func downloadImage(from fileName: String, completion: @escaping (String, UIImage?, Error?) -> Void)
    {
        downloadImage(inBucket: photosBucketName, from: fileName) { (url, image, error) in
            completion(url, image, error)
        }
    }
}
