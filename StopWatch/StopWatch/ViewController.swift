//
//  ViewController.swift
//  StopWatch
//
//  Created on 2018/01/24.
//  Copyright © 2018 Owehmgee. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var playPauseButton: UIButton?
    @IBOutlet var timerText: UILabel?
    var timer: Timer?
    var timeElapsed: Int = 0 {
        didSet {
            timerText?.text = "\(String(format:"%02d", timeElapsed/360)):\(String(format: "%02d",timeElapsed/60)):\(String(format: "%02d",timeElapsed%60))"
        }
    }
    var isPlaying: Bool = false {
        didSet {
            let buttonImage = isPlaying ? UIImage.init(named: "Pause") : UIImage.init(named: "Play")
            self.playPauseButton?.setImage(buttonImage, for: .normal)
        }
    }
    
    @IBAction func stopStartTimer(_ sender: UIButton?) {
        checkPlayStatus: if isPlaying {
            guard timer != nil else { break checkPlayStatus}
            timer?.invalidate()
            timer = nil
        } else {
            timeElapsed = 0
            guard timer == nil else { break checkPlayStatus }
            timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(ViewController.updateElapsedTime), userInfo: nil, repeats: true)
            timer?.fire()
        }
        isPlaying = !isPlaying
    }
    
    @objc private func updateElapsedTime() {
        timeElapsed += 1
    }
}

