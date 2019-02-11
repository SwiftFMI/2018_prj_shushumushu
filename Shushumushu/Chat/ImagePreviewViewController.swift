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
        guard sender.view != nil else { return }
        let currentScale = sender.view!.transform.scaleX
        let minScale = CGFloat(1.0)
        let maxScale = CGFloat(3.0)
        let zoomSpeed = CGFloat(0.5)
        var deltaScale = sender.scale
        
        deltaScale = ((deltaScale - 1) * zoomSpeed) + 1;
        deltaScale = min(deltaScale, maxScale / currentScale)
        deltaScale = max(deltaScale, minScale / currentScale)
        
        previewedImageView.transform = previewedImageView.transform.scaledBy(x: deltaScale, y: deltaScale)
        sender.scale = 1
    }
    
    @IBAction func panGestureAction(_ sender: UIPanGestureRecognizer) {
        let newCenter = CGPoint(x: previewedImageView.center.x + sender.translation(in: previewedImageView).x, y: previewedImageView.center.y + sender.translation(in: previewedImageView).y)
        if view.layer.contains(newCenter) {
            previewedImageView.center = newCenter
        }
        sender.setTranslation(CGPoint(x: 0, y: 0), in: previewedImageView)
    }
    
    @IBAction func doubleTapGesture(_ sender: UITapGestureRecognizer) {
        let viewCenter = view.center
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: { [weak self] in
            self?.previewedImageView.transform = CGAffineTransform.identity
            self?.previewedImageView.center = viewCenter
        })
    }
}

// MARK: - 'UIGestureRecognizerDelegate' callbacks

extension ImagePreviewViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
