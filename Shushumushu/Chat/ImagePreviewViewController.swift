//
//  ImagePreviewViewController.swift
//  Shushumushu
//
//  Created by Dimitar Stoyanov on 10.02.19.
//  Copyright © 2019 Dimitar Stoyanov. All rights reserved.
//

import UIKit

// MARK: - Creating Instance

extension ImagePreviewViewController {
    
    /// Sets up an 'ImagePreviewViewController' for force touch
    ///
    /// - Parameter image: the image to preview
    static func instanceFor(_ image: UIImage?) -> ImagePreviewViewController? {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let imagePreviewVC = storyboard.instantiateViewController(withIdentifier: "ImagePreviewViewController") as? ImagePreviewViewController else { return nil }
        imagePreviewVC.image = image
        return imagePreviewVC
    }
}

// MARK: - Class Definition

class ImagePreviewViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    private var imageView: UIImageView?
    
    var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Image Preview"
        
        let imageView = UIImageView(image: image)
        self.imageView = imageView
        scrollView.addSubview(imageView)
        scrollView.contentSize = image?.size ?? .zero
        scrollView.maximumZoomScale = 2
        scrollView.minimumZoomScale = 1
        
        imageView.layer.minificationFilter = CALayerContentsFilter.trilinear
        imageView.layer.minificationFilterBias = 0.1
        imageView.layer.allowsEdgeAntialiasing = true
        
        setScrollViewZoomScalesInRegardsTo(imageView)
   }
}

// MARK: - UIScrollViewDelegate

extension ImagePreviewViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? { return imageView }
}



extension ImagePreviewViewController {
    
    /// Initial zoom levels when image is loaded
    private func setScrollViewZoomScalesInRegardsTo(_ imageView: UIImageView) {
        
        scrollView.contentInset = UIEdgeInsets(top:     imageView.bounds.height / 2 + scrollView.contentSize.height / 2,
                                               left:    imageView.bounds.width / 2 + scrollView.contentSize.width / 2,
                                               bottom:  imageView.bounds.height / 2 + scrollView.contentSize.height / 2,
                                               right:   imageView.bounds.width / 2 + scrollView.contentSize.width / 2)
        
        var centerOfImageInLeftTop = CGPoint(x: scrollView.contentSize.width / 2, y: scrollView.contentSize.height / 2)
        centerOfImageInLeftTop.x -= scrollView.bounds.width / 2
        centerOfImageInLeftTop.y -= scrollView.bounds.height / 2
        scrollView.setContentOffset(centerOfImageInLeftTop, animated: false)
        
        centerOfImageInLeftTop.x -= scrollView.contentSize.width / 2
        centerOfImageInLeftTop.y -= scrollView.contentSize.height / 2
        
        scrollView.minimumZoomScale = 0.01
        scrollView.maximumZoomScale = 3
        
        let shorterSideOfImageView = imageView.shorterSide
        let comparisonSide = imageView.comparisonSide
        
        // 🤖: We increase the zoom by 5% to try an avoid images not quite filling the entire "layer"
        // This is an issue with modern iPhone having pictures not quite tall enough.
        // A future improvement woult be to calulate a true "aspect fill"
        scrollView.setZoomScale((comparisonSide / shorterSideOfImageView) * 1.05, animated: false)
    }
    
}

extension UIImageView {
    
    fileprivate var comparisonSide: CGFloat {
        guard bounds.width != bounds.height else { return longerSide }
        return shorterSide
    }
    
    var longerSide: CGFloat {
        return bounds.width > bounds.height ? bounds.width : bounds.height
    }
    
    var shorterSide: CGFloat {
        return bounds.width > bounds.height ? bounds.height : bounds.width
    }
}
