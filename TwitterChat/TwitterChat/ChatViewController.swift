//
//  ChatViewController.swift
//  TwitterChat
//
//  Created by Christine Roanne Mendoza
//

import UIKit

enum MessageAuthor: Int, Codable {
    case localUser
    case remoteUser
}

struct Message: Codable {
    let source: MessageAuthor
    let message: String
}

class ChatViewController: UIViewController {
    
    @IBOutlet weak var messagesTableView: UITableView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var chatTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    
    var username: String = ""
    var messageHistory = [Message]()
    var fileGateway = FileSystemGateway()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "@\(username)"
        
        loadMessages()
        
        NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        chatTextField.becomeFirstResponder()
        if self.messageHistory.count > 0 {
            let indexPath = IndexPath(row: self.messageHistory.count-1, section: 0)
            messagesTableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
        }
    }
    
    //MARK: IBActions
    @IBAction func sendMessage(_ sender: Any) {
        if let text = self.chatTextField.text, !text.isEmpty {
            sendMessage(text)
        }
    }
    
    // MARK: @objc functions
    @objc func adjustForKeyboard(notification: Notification) {
        let userInfo = notification.userInfo!
        
        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == Notification.Name.UIKeyboardWillHide {
            bottomConstraint.constant = 0
        } else {
            bottomConstraint.constant = -(keyboardViewEndFrame.height - self.view.safeAreaInsets.bottom)
        }
        
        self.view.layoutIfNeeded()
        scrollToBottom(animated: true)
    }

    @objc private func sendDelayedMessage(_ text: String) {
        saveMessage(Message(source: .remoteUser, message: "\(text) \(text)"))
        messagesTableView.reloadData()
        let indexPath = IndexPath(row: self.messageHistory.count-1, section: 0)
        messagesTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
    
    // MARK: private functions
    private func sendMessage(_ text: String) {
        sendButton.isEnabled = false
        saveMessage(Message(source: .localUser, message: text))
        messagesTableView.reloadData()
        let indexPath = IndexPath(row: self.messageHistory.count-1, section: 0)
        messagesTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        chatTextField.text = nil
        perform(#selector(sendDelayedMessage(_:)), with: text, afterDelay: 1.0)
    }
    
    private func saveMessage(_ message: Message) {
        messageHistory.append(message)
        fileGateway.saveMessages(messages: messageHistory, for: username)
    }
    
    private func loadMessages() {
        messageHistory = fileGateway.fetchStoredMessages(for: username)
        messagesTableView.reloadData()
    }
    
    private func scrollToBottom(animated: Bool) {
        if messageHistory.count > 0 {
            messagesTableView.scrollToRow(at: IndexPath(row: messageHistory.count-1, section: 0), at: .bottom, animated: animated)
        }
    }
}

// MARK: UITableView Delegate & DataSource
extension ChatViewController: UITableViewDelegate {

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        chatTextField.resignFirstResponder()
    }
}

extension ChatViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageHistory.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatMessageCell") as! MessageCell
        let message = messageHistory[indexPath.item]
        cell.adjustView(for: message, cellWidth: (UIScreen.main.bounds.width-30.0)*0.65)
        return cell
    }
}

extension ChatViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text, !text.isEmpty {
            sendMessage(text)
            return true
        }
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let text = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        sendButton.isEnabled = !text.isEmpty
        
        return true
    }
}

class MessageCell: UITableViewCell {
    @IBOutlet weak var bubbleImage: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var rightMargin: NSLayoutConstraint!
    @IBOutlet var leftMargin: NSLayoutConstraint!
    
    func adjustView(for chatMessage: Message, cellWidth: CGFloat) {
        
        self.messageLabel.text = chatMessage.message
        
        switch chatMessage.source {
        case .remoteUser:
            bubbleImage.image = #imageLiteral(resourceName: "leftBubble")
            messageLabel.textAlignment = .left
            messageLabel.textColor = .black
            leftMargin.isActive = true
        case .localUser:
            bubbleImage.image = #imageLiteral(resourceName: "rightBubble")
            messageLabel.textAlignment = .right
            messageLabel.textColor = .white
            leftMargin.isActive = false
        }
    }
}
