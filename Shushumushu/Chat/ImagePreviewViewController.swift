//
//  ImagePreviewViewController.swift
//  Shushumushu
//
//  Created by Dimitar Stoyanov on 10.02.19.
//  Copyright © 2019 Dimitar Stoyanov. All rights reserved.
//

import UIKit

class ImagePreviewViewController: UIViewController {
    @IBOutlet weak var previewedImageView: UIImageView!
    var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        previewedImageView?.image = image
    }
    
    convenience init(imageView: UIImageView) {
        self.init()
        image = imageView.image
    }
    
 
}
