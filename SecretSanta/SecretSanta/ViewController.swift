//
//  ViewController.swift
//  SecretSanta
//
//  Created by Mendoza, Christine | Roanne | DCSD on 2017/12/06.
//  Copyright © 2017 Mendoza, Christine | Roanne | DCSD. All rights reserved.
//

import UIKit
import MessageUI

class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var textView: UITextView!
    var participants = [SecretSanta]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.text = "There are no Secret Santa participants"
    }
    
    func assignGifteeToGifter() -> [SecretSanta] {
        var secretSantas = [SecretSanta]()
        var success = false
        
        repeat {
            var giftees = participants.map{$0.name}
            
            for gifter in participants {
                var secretSanta = gifter
                let index = Int(arc4random_uniform(UInt32(giftees.count)))
                let giftee = giftees[index]
                if secretSanta.name != giftee {
                    secretSanta.assignGiftee(giftee)
                    giftees.remove(at: index)
                    secretSantas.append(secretSanta)
                } else {
                    break;
                }
            }
            if giftees.count == 0 {
                success = true
            }
        } while success == false
        
        return secretSantas
    }
    
    func listParticipants() {
        var text = ""
        
        for entry in participants {
            text.append("Secret Santa \(entry.name)'s giftee is \(String(describing: entry.giftee)) \n")
        }
        textView.text = text
    }
    
    func generateTextFile() {
        for entry in participants {
            if let giftee = entry.giftee {
                let text = "Hello Secret Santa \(entry.name)!\n\n Your giftee is \(giftee) \n"
                write(text: text, to: "secret_santa_\(entry.name)")
            }
        }
    }
    
    func write(text: String, to fileNamed: String, folder: String = "SavedFiles") {
        guard let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else { return }
        guard let writePath = NSURL(fileURLWithPath: path).appendingPathComponent(folder) else { return }
        try? FileManager.default.createDirectory(atPath: writePath.path, withIntermediateDirectories: true)
        let file = writePath.appendingPathComponent(fileNamed + ".txt")
        try? text.write(to: file, atomically: false, encoding: String.Encoding.utf8)
    }
    
    @IBAction func addParticipants(_ sender: Any) {
        let dialog = UIAlertController.init(title: "Add Participant", message: nil, preferredStyle: .alert)
        dialog.addAction(UIAlertAction.init(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        dialog.addAction(UIAlertAction.init(title: "Add", style: UIAlertActionStyle.default, handler: { (action) in
            guard let nameField = dialog.textFields!.first else { return }
            let entry = SecretSanta.init(name: nameField.text!, giftee: nil)
            self.participants.append(entry)
            self.listParticipants()
        }))
        dialog.addTextField { (textField) in
            textField.placeholder = "Name"
        }
        self.present(dialog, animated: true, completion: nil)
    }
    
    @IBAction func generateSecretSanta(_ sender: Any) {
        participants = assignGifteeToGifter()
//        listParticipants()
        generateTextFile()
    }
    
    @IBAction func clearAll(_ sender: Any) {
        textView.text = "There are no Secret Santa participants"
        participants.removeAll()
    }
}

