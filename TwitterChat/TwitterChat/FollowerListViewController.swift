//
//  FollowerListViewController.swift
//  TwitterChat
//
//  Created by Christine Roanne Mendoza
//

import UIKit

class FollowerListViewController: UIViewController {
    
    @IBOutlet weak var followerTableView: UITableView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    var followerList = [TwitterUser]()
    var networkGateway = NetworkGateway()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchData()
    }
    
    func fetchData() {
        networkGateway.fetchFollowersList { (userList) in
            self.followerList.append(contentsOf: userList)
            DispatchQueue.main.async {
                self.followerTableView.reloadData()
                self.loadingIndicator.isHidden = true
            }
        }
    }
}

extension FollowerListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return followerList.count + (networkGateway.nextCursor > 0 ? 1 : 0)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = indexPath.row
        
        if index < followerList.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "profileCell") as! ProfileCell
            let follower = followerList[index]
            cell.name.text = follower.name
            cell.screenName.text = "@\(follower.screenName)"
            cell.followingButton.setTitle(follower.isFollowing ? "Following" : "Follow", for: .normal)
            networkGateway.fetchImage(follower.profilePhotoUrl) { (image) in
                DispatchQueue.main.async {
                    if let visibleCell = tableView.cellForRow(at: indexPath) as? ProfileCell, let image = image {
                        visibleCell.profilePhoto.image = image
                    }
                }
            }
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "loadingCell")
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row > followerList.count - 1 {
            fetchData()
        }
    }
}

extension FollowerListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let follower = followerList[indexPath.item]
        let chatViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        chatViewController.username = follower.screenName
        navigationController?.pushViewController(chatViewController, animated: true)
    }
}

class ProfileCell: UITableViewCell {
    
    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var screenName: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var followingButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        followingButton.layer.borderColor = followingButton.tintColor.cgColor
        followingButton.layer.borderWidth = 1.5
        followingButton.layer.cornerRadius = followingButton.frame.height/2
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        profilePhoto.image = nil
        screenName.text = nil
        name.text = nil
    }
}

