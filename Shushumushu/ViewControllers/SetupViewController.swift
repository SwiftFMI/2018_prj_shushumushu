//
//  SetupViewController.swift
//  Shushumushu
//
//  Created by Rostislav Georgiev on 17.01.19.
//  Copyright © 2019 Dimitar Stoyanov. All rights reserved.
//

import Foundation
import UIKit

class SetupViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var pickedImage: UIImageView!
    @IBOutlet weak var username: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pickedImage.layer.cornerRadius = pickedImage.frame.size.width/2
        pickedImage.layer.masksToBounds = true
    }
    
    
    @IBAction func takePhoto(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = .camera
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func choosePhoto(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let libraryPicker = UIImagePickerController()
            libraryPicker.delegate = self
            libraryPicker.sourceType = .photoLibrary
            libraryPicker.allowsEditing = true
            self.present(libraryPicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else {
            print("No image found")
            return
        }
        pickedImage.image = image
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func proceed(_ sender: Any) {
        if pickedImage.image != nil {
            UserDefaults.standard.set(username.text, forKey: "username")
            let pngImage = pickedImage.image!.pngData()
            UserDefaults.standard.set(pngImage, forKey: "profilePic")
            
            let nextStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = nextStoryboard.instantiateViewController(withIdentifier: "NearbyDevices") as! PeerTableViewController
            present(viewController, animated: true, completion: nil)
        } else {
            let noPictureAlert = UIAlertController(title: "Oops", message: "You don't have a picture.", preferredStyle: .alert)
            noPictureAlert.addAction(UIAlertAction(title: "Ok, I'll add one now :)", style: .default, handler: nil))
            self.present(noPictureAlert, animated: true)
        }
    }
    
}
