//
//  ChatViewController.swift
//  Shushumushu
//
//  Created by Dimitar Stoyanov on 9.01.19.
//  Copyright © 2019 Dimitar Stoyanov. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ChatViewController: UIViewController {
    var chatPartner: MCPeerID?
    var chatPartnerProfilePicture: UIImage?
    var messageInputContainerBottomConstraint: NSLayoutConstraint?
    var unreadMessagesCount: Int
    
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var chatTableView: UITableView!
    
    required init?(coder aDecoder: NSCoder) {
        chatPartner = nil
        unreadMessagesCount = 0
        super.init(coder: aDecoder)
    }
    
    let unreadMessagesView: UIButton = {
        let unreadMessagesView = UIButton()
        unreadMessagesView.translatesAutoresizingMaskIntoConstraints = false
        unreadMessagesView.backgroundColor = UIColor.init(red: 1, green: 0.23, blue: 0.19, alpha: 1)
        unreadMessagesView.layer.borderColor = UIColor.black.cgColor
        unreadMessagesView.layer.borderWidth = 1.0
        unreadMessagesView.titleLabel?.font = UIFont.boldSystemFont(ofSize: 32)
        unreadMessagesView.setTitle("0", for: .normal)
        unreadMessagesView.titleLabel?.textAlignment = NSTextAlignment.center
        unreadMessagesView.layer.cornerRadius = 25
        unreadMessagesView.layer.masksToBounds = true
        unreadMessagesView.isHidden = true
        unreadMessagesView.addTarget(self, action: #selector(unreadMessagesViewTapped), for: .touchUpInside)
        return unreadMessagesView
    }()
    
    let messageInputContainerView: UIView = {
        let messageInputContainerView = UIView()
        messageInputContainerView.translatesAutoresizingMaskIntoConstraints = false
        messageInputContainerView.backgroundColor = UIColor.init(white: 19/20, alpha: 1)
        return messageInputContainerView
    }()
    
    let inputTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Enter message..."
        textField.returnKeyType = .go
        textField.addTarget(self, action: #selector(sendButtonTapped), for: .primaryActionTriggered)
        return textField
    }()
    
    let sendButton: UIButton = {
        let sendButton = UIButton()
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.setTitle("👍", for: .normal)
        let titleColor = UIColor.blue
        sendButton.setTitleColor(titleColor, for: .normal)
        sendButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 32)
        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        return sendButton
    }()
    
    let separator: UIView = {
        let separator = UIView()
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.backgroundColor = UIColor.init(white: 13/15, alpha: 1)
        return separator
    }()
    
    let camera: UIButton = {
        let camera = UIButton()
        camera.translatesAutoresizingMaskIntoConstraints = false
        camera.setTitle("", for: .normal)
        camera.setBackgroundImage(UIImage(named: "CameraIcon"), for: .normal)
        camera.addTarget(self, action: #selector(cameraButtonTapped), for: .touchUpInside)
        return camera
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = chatPartner?.displayName
        chatPartnerProfilePicture = getProfilePicture(chatPartner!)
        setupAditionalViews()
        addNotificationObservers()
    }
    
    func getProfilePicture(_ peerID: MCPeerID) -> UIImage? {
        var profilePicture: UIImage?
        for (index, peer) in PeerService.peerService.foundPeers.enumerated() {
            if peer.id == chatPartner {
                profilePicture = PeerService.peerService.foundPeers[index].profilePicture
                break
            }
        }
        return profilePicture
    }
    
    func addNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(messageReceivedAction), name: Notification.Name.messageReceived, object: nil)
        inputTextField.addTarget(self, action: #selector(textFieldDidChangeAction), for: .editingChanged)
    }
    
    func setupAditionalViews() {
        var separatorBottomConstraint: NSLayoutConstraint?
        var unreadMessagesBottomConstraint: NSLayoutConstraint?
        var unreadMessagesCenterConstraint: NSLayoutConstraint?
        
        let views = ["view": view!, "messageInputContainerView": messageInputContainerView, "inputTextField": inputTextField, "sendButton": sendButton, "separator": separator, "unreadMessagesView": unreadMessagesView, "camera": camera]
        view.addSubview(messageInputContainerView)
        view.addSubview(separator)
        view.addSubview(unreadMessagesView)
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[separator]|", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[messageInputContainerView]|", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[unreadMessagesView]-[separator(1)]-[messageInputContainerView(48)]-0-[view]", options: [], metrics: nil, views: views))
        messageInputContainerBottomConstraint = NSLayoutConstraint(item: messageInputContainerView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
        separatorBottomConstraint = NSLayoutConstraint(item: separator, attribute: .bottom, relatedBy: .equal, toItem: messageInputContainerView, attribute: .top, multiplier: 1, constant: 0)
        unreadMessagesBottomConstraint = NSLayoutConstraint(item: unreadMessagesView, attribute: .bottom, relatedBy: .equal, toItem: separator, attribute: .top, multiplier: 1, constant: -8)
        unreadMessagesCenterConstraint = NSLayoutConstraint(item: unreadMessagesView, attribute: .centerX, relatedBy: .equal, toItem: separator, attribute: .centerX, multiplier: 1, constant: 0)
        view.addConstraint(messageInputContainerBottomConstraint!)
        view.addConstraint(separatorBottomConstraint!)
        view.addConstraint(unreadMessagesBottomConstraint!)
        view.addConstraint(unreadMessagesCenterConstraint!)
        
        let unreadMessagesHeightConstraint = NSLayoutConstraint(item: unreadMessagesView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 50)
        let unreadMessagesWidthConstant = NSLayoutConstraint(item: unreadMessagesView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 50)
        view.addConstraints([unreadMessagesWidthConstant, unreadMessagesHeightConstraint])
        
        messageInputContainerView.addSubview(inputTextField)
        messageInputContainerView.addSubview(sendButton)
        messageInputContainerView.addSubview(camera)
        messageInputContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-8-[camera]-8-|", options: [], metrics: nil, views: views))
        messageInputContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[inputTextField]|", options: [], metrics: nil, views: views))
        messageInputContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[sendButton]|", options: [], metrics: nil, views: views))
        messageInputContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-8-[camera(32)]-8-[inputTextField][sendButton(60)]|", options: [], metrics: nil, views: views))
    }
    
    @objc func textFieldDidChangeAction(_ textfield: UITextField) {
        if textfield.text != "" {
            UIView.transition(with: sendButton, duration: 0.3, options: [.curveEaseIn, .transitionCrossDissolve], animations: {
                self.sendButton.setTitle("Send", for: .normal)
                self.sendButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
            }, completion: nil)
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                UIView.transition(with: self.sendButton, duration: 0.3, options: [.curveEaseIn, .transitionCrossDissolve], animations: {
                    self.sendButton.setTitle("👍", for: .normal)
                    self.sendButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 32)
                }, completion: nil)
            }
        }
    }
    
    @objc func messageReceivedAction(_ notification: Notification) {
        unreadMessagesCount = unreadMessagesCount + 1
        DispatchQueue.main.async {
            self.chatTableView.insertRows(at: [IndexPath(row: self.numberOfMessages(fromAndTo: self.chatPartner!) - 1, section: 0)], with: .automatic)
            if self.previousMessageIsAtBottom() {
                self.scrollToBottom(true)
            } else {
                self.showUnreadMessagesView()
            }
        }
    }
    
    func animateUnreadMessagesView() {
        unreadMessagesView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        
        UIView.animate(withDuration: 2.0, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 3.0, options: .allowUserInteraction, animations: {
            self.unreadMessagesView.transform = .identity
        }, completion:  nil)
    }
    
    func hideUnreadMessagesView() {
        unreadMessagesCount = 0
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            self.unreadMessagesView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            self.unreadMessagesView.isHidden = true
        }) { _ in
            self.unreadMessagesView.transform = .identity
        }
        
    }
    
    func showUnreadMessagesView() {
        if unreadMessagesCount == 0 { return }
        
        let vibration = UINotificationFeedbackGenerator()
        vibration.notificationOccurred(.success)
        
        self.unreadMessagesView.isHidden = false
        self.unreadMessagesView.setTitle("\(self.unreadMessagesCount)", for: .normal)
        self.animateUnreadMessagesView()
    }
    
    @objc func handleKeyboardNotification(notification: NSNotification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            let isKeboardShowing = notification.name == UIResponder.keyboardWillShowNotification
            
            self.messageInputContainerBottomConstraint?.constant = isKeboardShowing ? -keyboardHeight : 0
            tableViewBottomConstraint.constant = isKeboardShowing ? (+keyboardHeight + 48) : +48
            self.chatTableView.updateConstraints()
            
            UIView.animate(withDuration: 0, delay: 0, options: .curveEaseOut, animations: {
                self.view.layoutIfNeeded()
                self.chatTableView.layoutIfNeeded()
            }, completion: { (completed) in })
            
            scrollToBottom(true)
        }
    }
    
    @objc func cameraButtonTapped() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = .camera
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    ///Checks if the message before the last one is at the bottom
    func previousMessageIsAtBottom() -> Bool {
        var previousMessageIsAtBottom = false
        
        if self.chatTableView.numberOfRows(inSection: 0) > 1 {
            let previousMessage = self.chatTableView.rectForRow(at: IndexPath(row: self.chatTableView.numberOfRows(inSection: 0) - 2, section: 0))
            let screen = UIScreen.main.bounds
            let previousMessageInScreen = self.chatTableView.convert(previousMessage, to: self.chatTableView.superview)
            if screen.height > previousMessageInScreen.minY {
                print("Setting previousMessageIsAtBottom to TRUE")
                previousMessageIsAtBottom = true
            }
        }
        
        return previousMessageIsAtBottom
    }
    
    ///Scrolls ChatTableView to the bottom
    func scrollToBottom(_ animated: Bool) {
        hideUnreadMessagesView()
        DispatchQueue.main.async{
            if self.chatTableView.numberOfRows(inSection: 0) > 0 {
                self.chatTableView.scrollToRow(at: IndexPath(row: self.chatTableView.numberOfRows(inSection: 0) - 1, section: 0), at: .bottom, animated: animated)
            }
        }
        
        print("Scrolled to bottom")
    }
    
    @IBAction func tableViewTapped(_ sender: Any) {
        view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("Initiated chat with: \(String(describing: chatPartner))")
        chatTableView.dataSource = self
        chatTableView.delegate = self
        chatTableView.reloadData()
        scrollToBottom(false)
    }
    
    @objc func sendButtonTapped(_ sender: Any) {
        guard let messageReceiver = chatPartner else {
            print("No chat participant found")
            return
        }
        
        let vibration = UIImpactFeedbackGenerator(style: .medium)
        vibration.impactOccurred()
        
        if inputTextField.text == "" { inputTextField.text = "👍" }
        
        if let messageData = inputTextField.text?.data(using: .utf8) {
            do {
                try PeerService.peerService.session.send(messageData, toPeers: [messageReceiver], with: .reliable)
                let newMessage = Message(sender: PeerService.peerService.myPeerId, receiver: chatPartner!, text: inputTextField.text!)
                PeerService.peerService.messages.append(newMessage)
                DispatchQueue.main.async {
                    self.chatTableView.insertRows(at: [IndexPath(row: self.numberOfMessages(fromAndTo: self.chatPartner!) - 1, section: 0)], with: .automatic)
                }
            } catch {
                print("Error sending message")
            }
        }
        inputTextField.text = ""
        UIView.transition(with: sendButton, duration: 0.3, options: [.curveEaseIn, .transitionCrossDissolve], animations: {
            self.sendButton.setTitle("👍", for: .normal)
            self.sendButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 32)
        }, completion: nil)
        scrollToBottom(true)
    }
    
    @objc func unreadMessagesViewTapped(_ sender: Any) {
        scrollToBottom(true)
    }
}

extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfMessages(fromAndTo: chatPartner!)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = PeerService.peerService.messages[indexPath.row]
        
        if message.sender == PeerService.peerService.myPeerId {
            if message.messageType == .Text {
                if message.text!.containsOnlyEmoji {
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: "SentEmojiTableViewCell", for: indexPath) as? SentEmojiTableViewCell else {
                        fatalError("The dequeued cell is not an instance of SentEmojiTableViewCell")
                    }
                    
                    cell.emojiSymbols.text = message.text
                    cell.timestampLabel.text = message.timestamp.toString()
                    return cell
                } else {
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: "SentMessageTableViewCell", for: indexPath) as? SentMessageTableViewCell else {
                        fatalError("The dequeued cell is not an instance of SentMessageTableViewCell")
                    }
                    
                    cell.messageText.text = message.text
                    cell.timestampLabel.text = message.timestamp.toString()
                    return cell
                }
            } else {
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: "SentImageTableViewCell", for: indexPath) as? SentImageTableViewCell else {
                        fatalError("The dequeued cell is not an instance of SentImageTableViewCell")
                    }
    
                    cell.sentImage.image = message.image
                    cell.timestampLabel.text = message.timestamp.toString()
                    return cell
            }
        } else  {
            if message.messageType == .Text {
                if message.text!.containsOnlyEmoji {
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: "ReceivedEmojiTableViewCell", for: indexPath) as? ReceivedEmojiTableViewCell else {
                        fatalError("The dequeued cell is not an instance of ReceivedEmojiTableViewCell")
                    }
                    
                    cell.emojiSymbols.text = message.text
                    cell.timestampLabel.text = message.timestamp.toString()
                    cell.profilePicture.image = chatPartnerProfilePicture
                    return cell
                } else {
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: "ReceivedMessageTableViewCell", for: indexPath) as? ReceivedMessageTableViewCell else {
                        fatalError("The dequeued cell is not an instance of ReceivedMessageTableViewCell")
                    }
                    
                    cell.messageText.text = message.text
                    cell.timestampLabel.text = message.timestamp.toString()
                    cell.profilePicture.image = chatPartnerProfilePicture
                    return cell
                }
            } else {
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: "ReceivedImageTableViewCell", for: indexPath) as? ReceivedImageTableViewCell else {
                        fatalError("The dequeued cell is not an instance of ReceivedImageTableViewCell")
                    }
                
                    cell.receivedImage.image = message.image
                    cell.timestampLabel.text = message.timestamp.toString()
                    cell.widthConstraint.constant = message.image?.size.width ?? 200
                    return cell
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func numberOfMessages(fromAndTo peer: MCPeerID) -> Int {
        var numberOfMessages = 0
        
        for message in PeerService.peerService.messages {
            if (message.sender == chatPartner && message.receiver == PeerService.peerService.myPeerId) || (message.sender == PeerService.peerService.myPeerId && message.receiver == chatPartner) {
                numberOfMessages += 1
            }
        }
        
        return numberOfMessages
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == tableView.numberOfRows(inSection: 0) - 1 {
            hideUnreadMessagesView()
        }
    }
    
}

extension Notification.Name {
    static let messageReceived = Notification.Name("message-received")
}

extension UILabel {
    func calculateMaxLines() -> Int {
        let maxSize = CGSize(width: frame.size.width, height: CGFloat(Float.infinity))
        let charSize = font.lineHeight
        let text = (self.text ?? "") as NSString
        let textSize = text.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        let linesRoundedUp = Int(ceil(textSize.height/charSize))
        return linesRoundedUp
    }
}

extension TimeInterval {
    func toString() -> String {
        let date = Date(timeIntervalSince1970: self)
        
        let dayTimePeriodFormatter = DateFormatter()
        dayTimePeriodFormatter.dateFormat = "hh:mm"
        let dateString = dayTimePeriodFormatter.string(from: date)
        
        return dateString
    }
}

extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let imageToSend = info[.editedImage] as? UIImage else {
            print("No image found")
            return
        }
        
        guard let messageReceiver = chatPartner else {
            print("No chat participant found")
            return
        }
        
        
        do {
            if let imageData = imageToSend.pngData() {
                try PeerService.peerService.session.send(imageData, toPeers: [messageReceiver], with: .reliable)
            } else {
                print("Error sending image")
                return
            }
            let newMessage = Message(sender: PeerService.peerService.myPeerId, receiver: chatPartner!, image: imageToSend)
            PeerService.peerService.messages.append(newMessage)
        } catch {
            print("Error sending image")
        }
        
//        DispatchQueue.main.async {
//            self.chatTableView.insertRows(at: [IndexPath(row: self.numberOfMessages(fromAndTo: self.chatPartner!) - 1, section: 0)], with: .automatic)
//        }
        dismiss(animated: true, completion: nil)
    }
}
