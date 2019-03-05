//
//  ViewController.swift
//  S3Downloader
//
//  Created by Hari Keerthipati on 25/01/19.
//  Copyright © 2019 Avantari Technologies. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        S3PhotoManager.shared.downloadImage(from: "imageNmae.png") { (url, image, error) in
            if error == nil
            {
                print("video downloaded")
            }
        }
    }
}

