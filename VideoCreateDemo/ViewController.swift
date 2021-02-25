//
//  ViewController.swift
//  VideoCreateDemo
//
//  Created by Kriti Agarwal on 25/02/21.
//

import UIKit
import AVKit
import AVFoundation

class ViewController: UIViewController, UIGestureRecognizerDelegate {
    
    
    //MARK:- IBOutlets
    
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var btnPause: UIButton!
    @IBOutlet weak var btnReplay: UIButton!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var textView: UITextView!
    
    
    //MARK:- Properties
    
    var urlStr = URL(string: "https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4")
    let controller = AVPlayerViewController()
    var player = AVPlayer()
    var interruptedTimeStamp : CMTime?
    var statusOld = 0
    var statusNew = 0
    var outputUrl : URL?
    var videoHasBeenTrimmed = false
    var urls = [URL]()
    var playerItems = [AVPlayerItem]()
    var edittedText = ""
    
    
    //MARK:- Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialSetUp()
        setupAVPlayer()
        aMethod()
    }
    
    
    //MARK:- Extra methods
    
    private func initialSetUp() {
        //1. Create a URL
        let url =  NSURL(fileURLWithPath: Bundle.main.path(forResource: "DemoVideo", ofType:"mp4")!)
        self.urlStr = url as URL
        //2. Create AVPlayer object
        let asset = AVAsset(url: url as URL)
        let playerItem = AVPlayerItem(asset: asset)
        self.player = AVPlayer(playerItem: playerItem)
        
        //3. Create AVPlayerLayer object
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.videoView.bounds //bounds of the view in which AVPlayer should be displayed
        playerLayer.videoGravity = .resizeAspect
        
        //4. Add playerLayer to view's layer
        self.videoView.layer.addSublayer(playerLayer)
        
        player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 2), queue: DispatchQueue.main) {[weak self] (progressTime) in
            if let duration = self?.player.currentItem?.duration {
                
                let durationSeconds = CMTimeGetSeconds(duration)
                let seconds = CMTimeGetSeconds(progressTime)
                let progress = Float(seconds/durationSeconds)
                
                DispatchQueue.main.async {
                    self?.progressBar.progress = progress
                    
                    if self?.player.currentItem?.currentTime() == self?.interruptedTimeStamp {
                        self?.textView.isHidden = false
                    } else {
                        self?.textView.isHidden = true
                    }
                    
                    if progress >= 1.0 {
                        self?.progressBar.progress = 0.0
                    }
                }
            }
        }
        
        //add pan gesture
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        gestureRecognizer.delegate = self
        textView.addGestureRecognizer(gestureRecognizer)
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        if touch.view != textView {
            self.edittedText =  textView.text
            textView.resignFirstResponder()
        }
    }

    @objc func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
            
            let translation = gestureRecognizer.translation(in: self.view)
            // note: 'view' is optional and need to be unwrapped
            gestureRecognizer.view!.center = CGPoint(x: gestureRecognizer.view!.center.x + translation.x, y: gestureRecognizer.view!.center.y + translation.y)
            gestureRecognizer.setTranslation(CGPoint.zero, in: self.view)
        }
        
    }


       //MARK:- UIGestureRecognizerDelegate Methods
       func gestureRecognizer(_: UIGestureRecognizer,
           shouldRecognizeSimultaneouslyWith shouldRecognizeSimultaneouslyWithGestureRecognizer:UIGestureRecognizer) -> Bool {
           return true
       }
    
    func aMethod() {
      let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTap(_:)))
      videoView.addGestureRecognizer(tapGesture)
    }

    @objc func onTap(_ gesture: UIGestureRecognizer) {
      if (gesture.state == .ended) {
        /* action */
        self.textView.isHidden = false
        self.textView.text = edittedText
        self.textView.becomeFirstResponder()
        self.videoHasBeenTrimmed = true
      }
    }
    
    private func setupAVPlayer() {
        player.addObserver(self, forKeyPath: "status", options: [.old, .new], context: nil)
        if #available(iOS 10.0, *) {
            player.addObserver(self, forKeyPath: "timeControlStatus", options: [.old, .new], context: nil)
        } else {
            player.addObserver(self, forKeyPath: "rate", options: [.old, .new], context: nil)
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if object as AnyObject? === player {
            if keyPath == "status" {
                if player.status == .readyToPlay {
                    player.play()
                }
            } else if keyPath == "timeControlStatus" {
                if #available(iOS 10.0, *) {
                    if player.timeControlStatus == .playing {
                        if self.player.currentItem?.currentTime() == self.interruptedTimeStamp {
                            self.textView.text = edittedText
                            self.textView.isHidden = false
                        } else {
                            self.textView.isHidden = true
                        }
                    } else {
                        
                    }
                }
            } else if keyPath == "rate" {
                if player.rate > 0 {
                    
                } else {
                    
                }
            }
        }
    }
    
    @IBAction func playTapped(_ sender: UIButton) {
        
        if videoHasBeenTrimmed {
            self.player.seek(to: CMTime.zero)
            self.player.play()
        } else {
            self.player.play()
        }

    }
    
    @IBAction func pauseTapped(_ sender: UIButton) {
        player.pause()
        self.interruptedTimeStamp = player.currentItem?.currentTime()
        print(self.interruptedTimeStamp ?? CMTime.zero)
    }
    
    @IBAction func replayTapped(_ sender: UIButton) {
        
    }
    
}
