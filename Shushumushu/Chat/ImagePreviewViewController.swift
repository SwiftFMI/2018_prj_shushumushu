//
//  ImagePreviewViewController.swift
//  Shushumushu
//
//  Created by Dimitar Stoyanov on 10.02.19.
//  Copyright © 2019 Dimitar Stoyanov. All rights reserved.
//

import UIKit

// MARK: - Class Definition

class ImagePreviewViewController: UIViewController {
    
    @IBOutlet weak var previewedImageView: UIImageView!
    @IBOutlet var previewedImagePinchGesture: UIPinchGestureRecognizer!
    @IBOutlet var previewedImagePanGesture: UIPanGestureRecognizer!
    
    var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        previewedImageView?.image = image
        UINavigationBar.appearance().backgroundColor = .black
    }
}

// MARK: - User Interactions

extension ImagePreviewViewController {
    
    @IBAction func pinchGestureAction(_ sender: UIPinchGestureRecognizer) {
        previewedImageView.transform = previewedImageView.transform.scaledBy(x: sender.scale, y: sender.scale)
        sender.scale = 1
    }
    
    @IBAction func panGestureAction(_ sender: UIPanGestureRecognizer) {
        let newPoint = CGPoint(x: previewedImageView.center.x + sender.translation(in: previewedImageView).x, y: previewedImageView.center.y + sender.translation(in: previewedImageView).y)
        previewedImageView.center = newPoint
        sender.setTranslation(CGPoint(x: 0, y: 0), in: previewedImageView)
    }
}

// MARK: - 'UIGestureRecognizerDelegate' callbacks

extension ImagePreviewViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
