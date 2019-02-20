//
//  ChatInputViewController.swift
//  Shushumushu
//
//  Created by Dimitar Stoyanov on 03/02/2019.
//  Copyright © 2019 Dimitar Stoyanov. All rights reserved.
//

import UIKit
import MultipeerConnectivity

// MARK: - ChatInputViewControllerDelegate

protocol ChatInputViewControllerDelegate: class {

    func chatInputViewController(_ chatInputViewController: ChatInputViewController, wantsToSendData data: Data)
}

// MARK: - Class Definition

final class ChatInputViewController: UIViewController {
    
    weak var delegate: ChatInputViewControllerDelegate?
    
    @IBOutlet private weak var textField: UITextField!
    @IBOutlet private weak var sendButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.addTarget(self, action: #selector(textFieldDidChangeAction), for: .editingChanged)
        updateSendButtonAppearance()
    }
    
    deinit {
       textField.removeTarget(self, action: #selector(textFieldDidChangeAction), for: .editingChanged)
    }
}

// MARK: - User Actions

extension ChatInputViewController {
    
    @IBAction private func cameraButtonTapped(_ sender: UIButton) {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else { return }
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true)
    }
    
    @IBAction private func sendButtonTapped(_ sender: UIButton) {

        let vibration = UIImpactFeedbackGenerator(style: .medium)
        vibration.impactOccurred()

        let textFieldText = textField.text ?? ""
        let message = textFieldText == "" ? PeerService.shared.selectedEmoji : textFieldText
        
        if let messageData = message.data(using: .utf8) {
            delegate?.chatInputViewController(self, wantsToSendData: messageData)
        }
        
        textField.text = ""
        updateSendButtonAppearance()
    }
    
    @IBAction func galleryButtonTapped(_ sender: Any) {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else { return }
        
        let libraryPicker = UIImagePickerController()
        libraryPicker.delegate = self
        libraryPicker.sourceType = .photoLibrary
        libraryPicker.allowsEditing = true
        self.present(libraryPicker, animated: true, completion: nil)
    }
    
    @objc private func textFieldDidChangeAction(_ textfield: UITextField) {
        DispatchQueue.main.asyncAfter(deadline: .now() + (textfield.text != "" ? 0 : 0.5)) { [weak self] in
            self?.updateSendButtonAppearance()
        }
    }
}

// MARK: - UIImagePicker Callbacks

extension ChatInputViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let imageToSend = (info[.editedImage] as? UIImage)?.pngData() else { return }
        delegate?.chatInputViewController(self, wantsToSendData: imageToSend)
        picker.dismiss(animated: true)
    }
}

// MARK: - Helper

extension ChatInputViewController {
    
    private func updateSendButtonAppearance() {
        
        UIView.transition(with: sendButton, duration: 0.3, options: [.curveEaseIn, .transitionCrossDissolve], animations: { [weak self] in
            self?.sendButton.setTitle(self?.textField.text != "" ? "Send" : PeerService.shared.selectedEmoji, for: .normal)
            self?.sendButton.titleLabel?.font = self?.textField.text != "" ? .boldSystemFont(ofSize: 18) : .boldSystemFont(ofSize: 36)
            self?.sendButton.backgroundColor = self?.textField.text != "" ?  UIColor(red: 0, green: 0.51, blue: 1, alpha: 1) : UIColor(red: 0, green: 0, blue: 0, alpha: 0)
            if self?.textField.text != "" { self?.sendButton.setValue(1, forKey: "borderWidth") } else { self?.sendButton.setValue(0, forKey: "borderWidth") }
        })
    }
}
