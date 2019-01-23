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
    var separatorBottomConstraint: NSLayoutConstraint?
    
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var chatTableView: UITableView!
    
    required init?(coder aDecoder: NSCoder) {
        chatPartner = nil
        messageInputContainerBottomConstraint = nil
        separatorBottomConstraint = nil
        super.init(coder: aDecoder)
    }
    
    let messageInputContainerView: UIView = {
        let messageInputContainerView = UIView()
        messageInputContainerView.backgroundColor = UIColor.init(white: 19/20, alpha: 1)
        return messageInputContainerView
    }()
    
    let inputTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter message..."
        return textField
    }()
    
    let sendButton: UIButton = {
        let sendButton = UIButton()
        sendButton.setTitle("Send", for: .normal)
        let titleColor = UIColor.blue
        sendButton.setTitleColor(titleColor, for: .normal)
        sendButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        return sendButton
    }()
    
    let separator: UIView = {
        let separator = UIView()
        separator.backgroundColor = UIColor.init(white: 13/15, alpha: 1)
        return separator
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
            if peer == chatPartner {
                profilePicture = PeerService.peerService.profilePictures[index]
                break
            }
        }
        return profilePicture
    }
    
    func addNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(messageReceivedAction), name: Notification.Name.messageReceived, object: nil)
    }
    
    func setupAditionalViews() {
        messageInputContainerView.translatesAutoresizingMaskIntoConstraints = false
        inputTextField.translatesAutoresizingMaskIntoConstraints = false
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        separator.translatesAutoresizingMaskIntoConstraints = false
        
        let views = ["view": view!, "messageInputContainerView": messageInputContainerView, "inputTextField": inputTextField, "sendButton": sendButton, "separator": separator]
        view.addSubview(messageInputContainerView)
        view.addSubview(separator)
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[separator]|", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[messageInputContainerView]|", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[separator(1)]-[messageInputContainerView(48)]-0-[view]", options: [], metrics: nil, views: views))
        messageInputContainerBottomConstraint = NSLayoutConstraint(item: messageInputContainerView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
        separatorBottomConstraint = NSLayoutConstraint(item: separator, attribute: .bottom, relatedBy: .equal, toItem: messageInputContainerView, attribute: .top, multiplier: 1, constant: 0)
        view.addConstraint(messageInputContainerBottomConstraint!)
        view.addConstraint(separatorBottomConstraint!)
        
        messageInputContainerView.addSubview(inputTextField)
        messageInputContainerView.addSubview(sendButton)
        messageInputContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[inputTextField]|", options: [], metrics: nil, views: views))
        messageInputContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[sendButton]|", options: [], metrics: nil, views: views))
        messageInputContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-8-[inputTextField][sendButton(60)]|", options: [], metrics: nil, views: views))
    }
    
    @objc func messageReceivedAction(_ notification: Notification) {
        DispatchQueue.main.async {
            self.chatTableView.insertRows(at: [IndexPath(row: self.numberOfMessages(fromAndTo: self.chatPartner!) - 1, section: 0)], with: .automatic)
            if self.previousMessageIsAtBottom() {
                self.scrollToBottom(true)
            }
        }
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
        guard let messageReceiver = chatPartner else { return }
        
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
        scrollToBottom(true)
    }
}

extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfMessages(fromAndTo: chatPartner!)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = PeerService.peerService.messages[indexPath.row]
        
        if message.sender == chatPartner && message.text.containsOnlyEmoji {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ReceivedEmojiTableViewCell", for: indexPath) as? ReceivedEmojiTableViewCell else {
                fatalError("The dequeued cell is not an instance of ReceivedEmojiTableViewCell")
            }
            
            cell.emojiSymbols.text = message.text
            cell.timestampLabel.text = message.timestamp.toString()
            cell.profilePicture.image = chatPartnerProfilePicture
            return cell
        } else if message.sender == PeerService.peerService.myPeerId {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "SentMessageTableViewCell", for: indexPath) as? SentMessageTableViewCell else {
                fatalError("The dequeued cell is not an instance of SentMessageTableViewCell")
            }
            
            cell.messageText.text = message.text
            cell.timestampLabel.text = message.timestamp.toString()
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
