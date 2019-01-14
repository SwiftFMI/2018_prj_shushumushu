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
    var bottomConstraint: NSLayoutConstraint?
    
    
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var chatTableView: UITableView!
    
    required init?(coder aDecoder: NSCoder) {
        chatPartner = nil
        bottomConstraint = nil
        
        super.init(coder: aDecoder)
    }
    
    let messageInputContainerView: UIView = {
        let messageInputContainerView = UIView()
        messageInputContainerView.backgroundColor = UIColor.lightGray
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let views = ["view": view!, "messageInputContainerView": messageInputContainerView, "inputTextField": inputTextField, "sendButton": sendButton]
        view.addSubview(messageInputContainerView)
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[messageInputContainerView]|", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[messageInputContainerView(48)]-0-[view]", options: [], metrics: nil, views: views))
        bottomConstraint = NSLayoutConstraint(item: messageInputContainerView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
        view.addConstraint(bottomConstraint!)
        
        messageInputContainerView.translatesAutoresizingMaskIntoConstraints = false
        inputTextField.translatesAutoresizingMaskIntoConstraints = false
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        
        messageInputContainerView.addSubview(inputTextField)
        messageInputContainerView.addSubview(sendButton)
        messageInputContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[inputTextField]|", options: [], metrics: nil, views: views))
        messageInputContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[sendButton]|", options: [], metrics: nil, views: views))
        messageInputContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-8-[inputTextField][sendButton(60)]|", options: [], metrics: nil, views: views))
        
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    @objc func handleKeyboardNotification(notification: NSNotification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            let isKeboardShowing = notification.name == UIResponder.keyboardWillShowNotification
            
            self.bottomConstraint?.constant = isKeboardShowing ? -keyboardHeight : 0
            tableViewBottomConstraint.constant = isKeboardShowing ? (-keyboardHeight - 48) : -48
            self.chatTableView.updateConstraints()
            
            UIView.animate(withDuration: 0, delay: 0, options: .curveEaseOut, animations: {
                self.view.layoutIfNeeded()
                self.chatTableView.layoutIfNeeded()
                
            }, completion: { (completed) in
                
            })
        }
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("Initiated chat with: \(String(describing: chatPartner))")
        chatTableView.dataSource = self
        chatTableView.delegate = self
        chatTableView.reloadData()
    }
    
    @objc func sendButtonTapped(_ sender: Any) {
        guard let messageReceiver = chatPartner else { return }
        
        if let messageData = inputTextField.text?.data(using: .utf8) {
            do {
                try PeerService.peerService.session.send(messageData, toPeers: [messageReceiver], with: .reliable)
                let newMessage = Message(sender: PeerService.peerService.myPeerId, receiver: chatPartner!, text: inputTextField.text!)
                PeerService.peerService.messages.append(newMessage)
            } catch {
                print("Error sending message")
            }
        }
        inputTextField.text = ""
    }
}

extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfMessages(fromAndTo: chatPartner!)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if PeerService.peerService.messages[indexPath.row].sender == chatPartner {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ReceivedMessageTableViewCell", for: indexPath) as? ReceivedMessageTableViewCell else {
                  fatalError("The dequeued cell is not an instance of ReceivedMessageTableViewCell")
            }
            cell.messageText.text = PeerService.peerService.messages[indexPath.row].text
            
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "SentMessageTableViewCell", for: indexPath) as? SentMessageTableViewCell else {
                fatalError("The dequeued cell is not an instance of SentMessageTableViewCell")
            }
            
            cell.messageText.text = PeerService.peerService.messages[indexPath.row].text
            
            return cell
        }
    }
    
    func numberOfMessages(fromAndTo peer: MCPeerID) -> Int {
        var numberOfMessages = 0
        
        for message in PeerService.peerService.messages {
            if message.sender == chatPartner || message.sender == PeerService.peerService.myPeerId || message.receiver == chatPartner || message.receiver == PeerService.peerService.myPeerId {
                numberOfMessages += 1
            }
        }
        
        return numberOfMessages
    }
    
}
