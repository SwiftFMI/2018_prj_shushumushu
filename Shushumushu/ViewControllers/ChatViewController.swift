//
//  ChatViewController.swift
//  Shushumushu
//
//  Created by Dimitar Stoyanov on 9.01.19.
//  Copyright © 2019 Dimitar Stoyanov. All rights reserved.
//

import UIKit
import MultipeerConnectivity

// MARK: - Class Definition

class ChatViewController: UIViewController {
    var chatPartner: MCPeerID?
    var unreadMessagesCount = 0
    
    @IBOutlet private weak var tableViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var chatTableView: UITableView!
    @IBOutlet private weak var unreadMessagesButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = chatPartner?.displayName
        addNotificationObservers()
        if traitCollection.forceTouchCapability == .available { registerForPreviewing(with: self, sourceView: chatTableView) }
        (children.first(where: { $0 is ChatInputViewController }) as? ChatInputViewController)?.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("Initiated chat with: \(String(describing: chatPartner))")
        chatTableView.reloadData()
        scrollToBottom(false)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: .messageReceived, object: nil)
        NotificationCenter.default.removeObserver(self, name: .messageSeen, object: nil)
    }
    
    private func addNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(messageReceivedAction), name: .messageReceived, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(messagesSeenAction), name: .messageSeen, object: nil)
    }
}

// MARK: - ChatInputViewControllerDelegate

extension ChatViewController: ChatInputViewControllerDelegate {
    
    func chatInputViewController(_ chatInputViewController: ChatInputViewController, wantsToSendData data: Data) {
        
        guard let messageReceiver = chatPartner else { return }
        
        do {
            guard let newMessage = Message.createFrom(sender: PeerService.shared.myPeerId, receiver: messageReceiver, data: data) else { return }
            try PeerService.shared.session.send(data, toPeers: [messageReceiver], with: .reliable)
            PeerService.shared.messages.append(newMessage)
            
            chatTableView.insertRows(at: [IndexPath(row: chatTableView.numberOfRows(inSection: 0), section: 0)], with: .automatic)
            scrollToBottom(true)
        } catch {
            printError(withMessage: error.localizedDescription)
            showAlert(withMessage: error.localizedDescription)
        }
    }
}

// MARK: - TableView Callbacks

extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PeerService.shared.totalNumberOfMessages(with: chatPartner!)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = PeerService.shared.messages[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: message.messageCellIdentifier, for: indexPath)
        (cell as? ChatTableViewCell)?.populateFrom(message)
        (cell as? ImageTableViewCell)?.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == tableView.numberOfRows(inSection: 0) - 1 {
            unreadMessagesCount = 0
            unreadMessagesButton.hideUnreadMessagesView()
            PeerService.shared.sendNotification(String.messageSeen, to: chatPartner!)
        }
    }
}

// Mark: - Notification handlers

extension ChatViewController {
    
    @objc func messagesSeenAction(notification: NSNotification) {
        DispatchQueue.main.async { [weak self] in
            (self!.chatTableView.cellForRow(at: IndexPath(row: PeerService.shared.indexOfLastMessageSentByMe(with: self!.chatPartner!), section: 0)) as? ChatTableViewCell)?.setSeen(to: true)
            
            for index in stride(from: PeerService.shared.indexOfLastMessageSentByMe(with: self!.chatPartner!) - 1, through: 0, by: -1) {
                if PeerService.shared.messages[index].sender == PeerService.shared.myPeerId && PeerService.shared.messages[index].receiver == self!.chatPartner {
                    (self!.chatTableView.cellForRow(at: IndexPath(row: index, section: 0)) as? ChatTableViewCell)?.setSeen(to: false)
                }
            }
        }
    }
}

// MARK: - User Actions

extension ChatViewController {
    
    @IBAction private func tableViewTapped(_ sender: Any) {
        view.endEditing(true)
    }
    
    @IBAction private func unreadMessageButtonTapped(_ sender: Any) {
        scrollToBottom(true)
    }
    
    @objc private func messageReceivedAction(_ notification: Notification) {
        unreadMessagesCount = unreadMessagesCount + 1
        DispatchQueue.main.async { [weak self] in
            
            guard let strongSelf = self else { return }
            
            strongSelf.chatTableView.insertRows(at: [IndexPath(row: strongSelf.chatTableView.numberOfRows(inSection: 0), section: 0)], with: .automatic)
            if strongSelf.previousMessageIsAtBottom {
                strongSelf.scrollToBottom(true)
            } else {
                guard strongSelf.unreadMessagesCount != 0 else { return }
                strongSelf.unreadMessagesButton.showUnreadMessagesView(for: strongSelf.unreadMessagesCount)
            }
        }
    }
    
    @objc private func handleKeyboardNotification(notification: NSNotification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            let isKeboardShowing = notification.name == UIResponder.keyboardWillShowNotification
            
            let keyBoardShownHeight = 48 - view.safeAreaInsets.bottom + keyboardHeight
            tableViewBottomConstraint.constant = isKeboardShowing ? keyBoardShownHeight : 48
            chatTableView.updateConstraints()
            
            UIView.animate(withDuration: 0, delay: 0, options: .curveEaseOut, animations: { [weak self] in
                self?.view.layoutIfNeeded()
                self?.chatTableView.layoutIfNeeded()
            })
            
            scrollToBottom(true)
        }
    }
}

// MARK: - ImageTableViewCellDelegate

extension ChatViewController: ImageTableViewCellDelegate {
    
    func imageTableViewCell(_ imageTableViewCell: ImageTableViewCell, didTapImage image: UIImage) {
        guard let vc = ImagePreviewViewController.instanceFor(image) else { return }
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - Force Touch Delegate

extension ChatViewController: UIViewControllerPreviewingDelegate {
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        if let indexPath = chatTableView.indexPathForRow(at: location) {
            if let cell = chatTableView.cellForRow(at: indexPath) as? ImageTableViewCell {
                let vc = ImagePreviewViewController.instanceFor(cell.contentImageView.image)
                previewingContext.sourceRect = cell.convert(cell.contentImageView.frame, to: chatTableView)
                return vc
            }
        }
        return nil
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        navigationController?.pushViewController(viewControllerToCommit, animated: true)
    }
}

// MARK: - Helpers

extension ChatViewController {
    
    /// Checks if a view contains a location
    private func touchedView(_ view: UIView, location: CGPoint) -> Bool {
        let locationInView = view.convert(location, from: view)
        return view.bounds.contains(locationInView)
    }

    /// Presents alert with error message.
    ///
    /// - Parameter message: the error message.
    private func printError(withMessage message: String = "An Error has occured") {
        print(message)
    }
    
    /// Checks if the message before the last one is at the bottom
    private var previousMessageIsAtBottom: Bool {
        var previousMessageIsAtBottom = false
        
        if chatTableView.numberOfRows(inSection: 0) > 1 {
            let previousMessage = chatTableView.rectForRow(at: IndexPath(row: chatTableView.numberOfRows(inSection: 0) - 2, section: 0))
            let previousMessageInScreen = chatTableView.convert(previousMessage, to: chatTableView.superview)
            if UIScreen.main.bounds.height > previousMessageInScreen.minY {
                print("Setting previousMessageIsAtBottom to TRUE")
                previousMessageIsAtBottom = true
            }
        }
        
        return previousMessageIsAtBottom
    }
    
    /// Scrolls `ChatTableView` to the bottom
    func scrollToBottom(_ animated: Bool) {
        unreadMessagesCount = 0
        unreadMessagesButton.hideUnreadMessagesView()
        
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            if strongSelf.chatTableView.numberOfRows(inSection: 0) > 0 {
                strongSelf.chatTableView.scrollToRow(at: IndexPath(row: strongSelf.chatTableView.numberOfRows(inSection: 0) - 1, section: 0), at: .bottom, animated: animated)
            }
        }
        
        PeerService.shared.sendNotification(String.messageSeen, to: chatPartner!)
        print("Scrolled to bottom")
    }
}

extension Message {
    
    fileprivate var messageCellIdentifier: String {
        
        switch messageType {
        case .emojiOnly: return isSendByLocalUser ? EmojiTableViewCell.sentIdentifier   : EmojiTableViewCell.receivedIdentifier
        case .text:      return isSendByLocalUser ? MessageTableViewCell.sentIdentifier : MessageTableViewCell.receivedIdentifier
        case .image:     return isSendByLocalUser ? ImageTableViewCell.sentIdentifier   : ImageTableViewCell.receivedIdentifier
        }
    }
}

// MARK: Alerts

extension ChatViewController {
    
    func showAlert(withMessage message: String) {
        let alertController = UIAlertController(title: "Warning", message: "An error occured regarding your connectivity with your chat partner", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Okay", style: .cancel) { (action) in
            self.navigationController?.popViewController(animated: true)
        }
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
}
