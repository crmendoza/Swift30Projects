//
//  NetworkGateway.swift
//  TwitterChat
//
//  Created by Christine Roanne Mendoza
//

import Foundation
import UIKit

enum TwitterEndpoint {
    static let token = "https://api.twitter.com/oauth2/token"
    static let followers = "https://api.twitter.com/1.1/followers/list.json"
}

struct TwitterUser {
    let name: String
    let screenName: String
    let profilePhotoUrl: String
    let isFollowing: Bool
}

extension TwitterUser {
    init(json: [String: AnyObject]) {
        var isFollowing = false
        if let _ = json["following"] as? Bool {
            isFollowing = json["following"] as! Bool
        }
        
        self.init(name: json["name"] as! String,
                  screenName: json["screen_name"] as! String,
                  profilePhotoUrl: json["profile_image_url_https"] as! String,
                  isFollowing: isFollowing)
    }
}

class NetworkGateway {
    
    let defaultUser = "objcio"
    let consumerCred = "LdBPB0Mp842tqORzUqlX2qptb:qIbvjDIszlIfKnxYmncpnOPEgSO1dHYg61j5b6ch07M1YyR1fH"
    
    let session = URLSession.shared
    var cache: NSCache<AnyObject, AnyObject> = NSCache()
    var accessToken: String?
    var nextCursor = -1
    
    func fetchFollowersList(completion: @escaping (([TwitterUser]) -> Void)) {
        let requestBlock: () -> Void = {
            let urlString = "\(TwitterEndpoint.followers)?screen_name=\(self.defaultUser)&count=50&cursor=\(self.nextCursor)"
            var request = URLRequest(url: URL(string: urlString)!)
            request.addValue("Bearer \(self.accessToken ?? "")", forHTTPHeaderField: "Authorization")
            request.httpMethod = "GET"
            let task = self.session.dataTask(with: request, completionHandler: { (data, response, error) in
                if error == nil && data != nil {
                    do {
                        var userList = [TwitterUser]()
                        let jsonData = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! [String: AnyObject]
                        if let users = jsonData["users"] as? [AnyObject] {
                            for user in users {
                                userList.append(TwitterUser(json: user as! [String : AnyObject]))
                            }
                        }
                        
                        if let nextCursor = jsonData["next_cursor"] as? Int {
                            self.nextCursor = nextCursor
                        }
                        
                        completion(userList)
                    } catch {
                        print("Error occurred: \(error.localizedDescription)")
                        completion([TwitterUser]())
                    }
                } else {
                    completion([TwitterUser]())
                }
            })
            task.resume()
        }
        
        if accessToken == nil {
            authenticate {
                requestBlock()
            }
        } else {
            DispatchQueue.global(qos: .background).async {
                requestBlock()
            }
        }
    }
    
    func authenticate(completion: @escaping (() -> Void)) {
        DispatchQueue.global(qos: .background).async {
            var request = URLRequest(url: URL(string: TwitterEndpoint.token)!)
            request.addValue("Basic \(self.consumerCred.data(using: .utf8)?.base64EncodedString() ?? "")", forHTTPHeaderField: "Authorization")
            request.addValue("application/x-www-form-urlencoded;charset=UTF-8.", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            request.httpBody = "grant_type=client_credentials".data(using: .utf8)
            let task = self.session.dataTask(with: request) { (data, response, error) in
                if error == nil && data != nil {
                    do {
                        let jsonData = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! [String: Any]
                        if let accessToken = jsonData["access_token"] as? String {
                            self.accessToken = accessToken
                            completion()
                        }
                    } catch {
                        return
                    }
                }
            }
            task.resume()
        }
    }
    
    func fetchImage(_ imageUrl: String, completion: @escaping ((UIImage?) -> Void)) {
        if (cache.object(forKey: NSString(string: imageUrl)) != nil){
            let image = cache.object(forKey: NSString(string: imageUrl)) as? UIImage
            completion(image)
        } else{
            let url:URL! = URL(string: imageUrl)
            let task = session.downloadTask(with: url, completionHandler: { (location, response, error) -> Void in
                if let data = try? Data(contentsOf: url){
                    let image:UIImage! = UIImage(data: data)
                    self.cache.setObject(image, forKey: NSString(string: imageUrl))
                    completion(image)
                }
            })
            task.resume()
        }
    }
}
