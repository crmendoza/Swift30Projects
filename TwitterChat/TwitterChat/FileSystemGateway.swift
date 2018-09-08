//
//  FileSystemGateway.swift
//  TwitterChat
//
//  Created by Christine Roanne Mendoza
//

import Foundation

class FileSystemGateway {
    
    func fetchStoredMessages(for username: String) -> [Message] {
        guard let urlPath = urlPath(for: username, type: "json") else {
            return [Message]()
        }
        
        do {
            let messageData = try Data(contentsOf: urlPath)
            let messageArray = try JSONDecoder().decode([Message].self, from: messageData)
            return messageArray
        } catch {
            return [Message]()
        }
    }
    
    func saveMessages(messages: [Message], for username: String) {
        guard let urlPath = urlPath(for: username, type: "json") else {
            return
        }
        
        do {
            let messageData = try JSONEncoder().encode(messages)
            try messageData.write(to: urlPath)
        } catch {
            return
        }
    }
    
    private func urlPath(for filename:String, type: String) -> URL? {
        let fileManager = FileManager.default
        do {
            let documentsDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            return documentsDirectory.appendingPathComponent("\(filename).\(type)")
        } catch {
            return nil
        }
    }
}
