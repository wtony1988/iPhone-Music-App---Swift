//
//  LMPlayerViewController.swift
//  LAVESHMUSIC
//
//  Created by Admin on 1/5/19.
//  Copyright © 2019 Tony Wang. All rights reserved.
//

import UIKit
import DMSwipeCards
import JHSpinner
import Firebase
import SDWebImage
import AVFoundation

class LMPlayerViewController: UIViewController, AVAudioPlayerDelegate, UIScrollViewDelegate{
    
    @IBOutlet weak var scrlViMusics: UIScrollView!
    
    let sharedManager:Singleton = Singleton.sharedInstance
    
    var player = AVPlayer()
    var playerItem:AVPlayerItem!
    
    private var swipeView: DMSwipeCardsView<String>!
    var genre_id = SELECTED_NONE_ID
    var oneMusicId = SELECTED_NONE_STRING
    var arrMusics = [LMMusic]()
    var selectedMusicIdx = SELECTED_NONE
    var isReachedEnd = false
    var nCurrentVersionIdx = 0
    
    var topContainerView = LMSongView()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        /*
         * In this example we're using `String` as a type.
         * You can use DMSwipeCardsView though with any custom class.
         */
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.scrlViMusics.frame = CGRect(x: 0, y: 120, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - 357)
        
        self.loadMusics()
        self.sharedManager.getLikedMusics()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.player.replaceCurrentItem(with: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    /*override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "showLicensing" {
            let viCtrlLicensing = segue.destination as! LMLicensingViewController
            let music = self.arrMusics[self.selectedMusicIdx]
            viCtrlLicensing.musicVersion = music.arrVersions[0]
        }
    }*/
    
    // MARK: - Own Methods
    func getUpdatedLikedMusics()
    {
        let spinner = JHSpinnerView.showOnView(view, spinnerColor:ColorPalette.laveshOrange, overlay:.roundedSquare, overlayColor:UIColor.darkGray.withAlphaComponent(0.8), text:nil)
        self.view.addSubview(spinner)
        
        self.sharedManager.arrLikedMusicIds.removeAll()
        
        let dbRef = Database.database().reference()
    dbRef.child("user_data").child(self.sharedManager.myUser.uid!).child("liked_musics").observeSingleEvent(of: .value, with: { (dataSnapshot) in
            spinner.dismiss()
            if let snapshots = dataSnapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshots {
                    self.sharedManager.arrLikedMusicIds.append(snap.value as! String)
                }
            }
            
        }, withCancel: { (error) in
            spinner.dismiss()
            self.present(self.sharedManager.getErrorAlert(withError: error), animated: true, completion: nil)
        })
    }
    
    func loadMusics(){
        self.arrMusics.removeAll()
        
        for viewTemp in self.scrlViMusics.subviews
        {
            viewTemp.removeFromSuperview()
        }
        
        let spinner = JHSpinnerView.showOnView(view, spinnerColor:ColorPalette.laveshOrange, overlay:.roundedSquare, overlayColor:UIColor.darkGray.withAlphaComponent(0.8), text:nil)
        self.view.addSubview(spinner)
        
        let dbRef = Database.database().reference()
        if self.genre_id != SELECTED_NONE_ID {
            dbRef.child("music_data").queryOrdered(byChild: "genre_id").queryEqual(toValue: Int(self.genre_id)).observeSingleEvent(of: .value, with: { (snapshot) in
                if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                    for snap in snapshots {
                        if let dicMusic = snap.value as? Dictionary<String, AnyObject> {
                            
                            let music = LMMusic()
                            music.setValues(withDictionary: dicMusic)
                            self.arrMusics.append(music)
                        }
                    }
                    print(self.arrMusics.count)
                    
                    self.selectedMusicIdx = 0
                    self.displayMusics()
                    spinner.dismiss()
                }
                
            }, withCancel: { (getUserInfoError) in
                spinner.dismiss()
                self.present(self.sharedManager.getErrorAlert(withError: getUserInfoError), animated: true, completion: nil)
            })
        }
        else if (self.genre_id == SELECTED_NONE_ID) && (self.oneMusicId != SELECTED_NONE_STRING)  {
            dbRef.child("music_data").child(self.oneMusicId).observeSingleEvent(of: .value, with: { (dataSnapShot) in
                
                if let dicMusic = dataSnapShot.value as? Dictionary<String, AnyObject> {
                    
                    let music = LMMusic()
                    music.setValues(withDictionary: dicMusic)
                    self.arrMusics.append(music)
                }
                
                self.selectedMusicIdx = 0
                self.displayMusics()
                
                spinner.dismiss()
            })
        }
    }
    
    func displayMusics()
    {
        
        self.scrlViMusics.contentSize = CGSize(width: self.scrlViMusics.frame.size.width * CGFloat(self.arrMusics.count), height: self.scrlViMusics.frame.size.height)
        for i in 0...self.arrMusics.count - 1
        {
            let music = self.arrMusics[i]
            let musicVersion = music.arrVersions[self.nCurrentVersionIdx]
            
            let container:LMSongView = UIView.fromNib()
            container.frame = CGRect(x: CGFloat(i) * self.scrlViMusics.frame.size.width, y: 0, width: self.scrlViMusics.frame.size.width, height: self.scrlViMusics.frame.size.height)
            
            container.imgViThumb.sd_setImage(with: musicVersion.thumbImageURL, completed: nil)
            
            if musicVersion.versionType != "" {
                container.lblTitle.text = (musicVersion.title + "(" + musicVersion.versionType + ")").uppercased()
            }
            else{
                container.lblTitle.text = musicVersion.title.uppercased()
            }
            container.lblSinger.text = musicVersion.singer.uppercased()
            
            container.timeSlider.setThumbImage(UIImage(named: "slider_thumb"), for: .normal)
            container.timeSlider.setThumbImage(UIImage(named: "slider_thumb_h"), for: .highlighted)
            container.timeSlider.addTarget(self, action: #selector(self.onSeekPlayer(sender:)), for: .valueChanged)
            
            container.btnPlay.addTarget(self, action: #selector(self.onPlay(sender:)), for: .touchUpInside)
            
            container.viContents.layer.cornerRadius = 4.0
            container.viContents.layer.shadowRadius = 4
            container.viContents.layer.shadowOpacity = 1.0
            container.viContents.layer.shadowColor = UIColor(white: 0.3, alpha: 1.0).cgColor
            container.viContents.layer.shadowOffset = CGSize(width: 0, height: 0)
            container.viContents.layer.shouldRasterize = true
            container.viContents.layer.rasterizationScale = UIScreen.main.scale
            
            container.tag = i
            
            let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture(gesture:)))
            swipeUp.direction = UISwipeGestureRecognizerDirection.up
            container.addGestureRecognizer(swipeUp)
            
            self.scrlViMusics.addSubview(container)
            
        }
        
        self.playCurrentMusic()

    }
    
    func playCurrentMusic()
    {
        self.topContainerView = self.scrlViMusics.viewWithTag(self.selectedMusicIdx) as! LMSongView
        let musicSelected = self.arrMusics[self.selectedMusicIdx]
        
        self.playerItem = AVPlayerItem(url:musicSelected.arrVersions[self.nCurrentVersionIdx].fileURL!)
        self.player = AVPlayer(playerItem:playerItem)
        self.player.volume = 1.0
        
        self.player.addObserver(self, forKeyPath: "rate", options: NSKeyValueObservingOptions.new, context: nil)
        
        self.player.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, 1), queue: DispatchQueue.main) { (time) in
            if self.player.currentItem?.status == .readyToPlay {
                
                let durationInSeconds = Float(CMTimeGetSeconds(self.playerItem.duration))
                let currentTime = Float(CMTimeGetSeconds(time))
                
                self.topContainerView.timeSlider.value = currentTime
                self.topContainerView.timeSlider.maximumValue = durationInSeconds
                
                /*self.currentTimeLabel.text = String(format: "%02d:%02d",   Int(currentTime)/60, Int(currentTime) % 60)
                 self.durationLabel.text = String(format: "%02d:%02d",   Int(durationInSeconds)/60, Int(durationInSeconds) % 60)*/
                
            }
        }

        self.player.play()
        
        
        
    }
    
    func reloadMusicVersion()
    {
        let music = self.arrMusics[self.selectedMusicIdx]
        let musicVersion = music.arrVersions[self.nCurrentVersionIdx]
        
        self.topContainerView.imgViThumb.sd_setImage(with: musicVersion.thumbImageURL, completed: nil)
        self.topContainerView.lblSinger.text = musicVersion.singer.uppercased()
        
        if musicVersion.versionType != "" {
            self.topContainerView.lblTitle.text = (musicVersion.title + "(" + musicVersion.versionType + ")").uppercased()
        }
        else{
            self.topContainerView.lblTitle.text = musicVersion.title.uppercased()
        }
        
        self.topContainerView.timeSlider.value = 0
        
        self.playCurrentMusic()
    }
    
    // MARK: - Event Handlers
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            
            
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                print("Swiped right")
            case UISwipeGestureRecognizerDirection.down:
                print("Swiped down")
            case UISwipeGestureRecognizerDirection.left:
                print("Swiped left")
            case UISwipeGestureRecognizerDirection.up:
                print("Swiped up")
                
                let musicSelected = self.arrMusics[self.selectedMusicIdx]
                
                if musicSelected.arrVersions.count > 1
                {
                    if self.nCurrentVersionIdx == musicSelected.arrVersions.count - 1
                    {
                        self.nCurrentVersionIdx = 0
                    }
                    else {
                        self.nCurrentVersionIdx = self.nCurrentVersionIdx + 1
                    }
                    self.reloadMusicVersion()
                }
                
            default:
                break
            }
        }
    }
    
    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func onPlay(sender: Any) {
        if ((self.player.rate != 0) && (self.player.error == nil)) {
            self.player.pause()
        }
        else {
            self.player.play()
        }
    }
    
    @objc func onSeekPlayer(sender: Any)
    {
        let slider = sender as! UISlider
        player.seek(to: CMTimeMakeWithSeconds(Float64(slider.value), 1))
    }
    
    @IBAction func onTapToReload(_ sender: Any) {
        self.loadMusics()
    }
    
    @IBAction func onReload(_ sender: Any) {
        self.loadMusics()
    }
    
    @IBAction func onLike(_ sender: Any) {
        
        if self.arrMusics.count < 1
        {
            return
        }
        
        let selectedMusicId = self.arrMusics[self.selectedMusicIdx].id
        
        if self.sharedManager.isLikedMusic(musicId: selectedMusicId)
        {
            let msgLabel = UILabel(frame: CGRect(x: (SCREEN_WIDTH - 160)/2.0, y: 300, width: 160, height: 32))
            msgLabel.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
            msgLabel.text = "✓ Already Liked!"
            msgLabel.textColor = UIColor.white
            msgLabel.textAlignment = .center
            msgLabel.alpha = 0
            
            self.view.addSubview(msgLabel)
            UIView.animate(withDuration: 0.4, animations: {
                msgLabel.alpha = 1
            }) { (complete) in
                UIView.animate(withDuration: 0.4, animations: {
                    msgLabel.alpha = 0
                }) { (complete) in
                    msgLabel.removeFromSuperview()
                }
            }
        }
        else {
            let spinner = JHSpinnerView.showOnView(view, spinnerColor:ColorPalette.laveshOrange, overlay:.roundedSquare, overlayColor:UIColor.darkGray.withAlphaComponent(0.8), text:nil)
            self.view.addSubview(spinner)
            
            let dbRef = Database.database().reference()
            dbRef.child("user_data").child(self.sharedManager.myUser.uid!).child("liked_musics").childByAutoId().setValue(selectedMusicId, withCompletionBlock: { (error, ref) in
                if error != nil{
                    spinner.dismiss()
                    self.present(self.sharedManager.getErrorAlert(withError: error!), animated: true, completion: nil)
                }
                else {
                    spinner.dismiss()
                    
                    let msgLabel = UILabel(frame: CGRect(x: (SCREEN_WIDTH - 100)/2.0, y: 260, width: 100, height: 100))
                    msgLabel.font = UIFont.systemFont(ofSize: 80)
                    msgLabel.backgroundColor = UIColor.clear
                    msgLabel.text = "🔥"
                    msgLabel.textAlignment = .center
                    msgLabel.alpha = 0
                    
                    self.view.addSubview(msgLabel)
                    UIView.animate(withDuration: 0.4, animations: {
                        msgLabel.alpha = 1
                    }) { (complete) in
                        UIView.animate(withDuration: 0.4, animations: {
                            msgLabel.alpha = 0
                        }) { (complete) in
                            msgLabel.removeFromSuperview()
                            self.getUpdatedLikedMusics()
                        }
                    }
                }
            })
        }
    }
    
    @IBAction func onShare(_ sender: Any) {
        
        if self.arrMusics.count < 1
        {
            return
        }
        
        let actionSheet = UIAlertController.init(title: "Share a music with", message: nil, preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction.init(title: "Facebook", style: UIAlertActionStyle.default, handler: { (action) in
        }))
        
        actionSheet.addAction(UIAlertAction.init(title: "Twitter", style: UIAlertActionStyle.default, handler: { (action) in
        }))
        
        actionSheet.addAction(UIAlertAction.init(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (action) in
        }))
        
        //Present the controller
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    @IBAction func onLicense(_ sender: Any) {
        if self.arrMusics.count < 1
        {
            return
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viCtrlLicensing = storyboard.instantiateViewController(withIdentifier: "LMLicensingViewController") as! LMLicensingViewController
        let music = self.arrMusics[self.selectedMusicIdx]
        viCtrlLicensing.musicVersion = music.arrVersions[0]
        self.present(viCtrlLicensing, animated: true, completion: nil)
    }
    
    // MARK: - UIScrollViewDelegate Methods
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x/view.frame.width)
        self.selectedMusicIdx = Int(pageIndex)
        self.nCurrentVersionIdx = 0
        
        self.player.replaceCurrentItem(with: nil)
        self.playCurrentMusic()
    }
    
    // MARK: - AVAudioPlayerDelegate Methods
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.player.seek(to: kCMTimeZero)
        self.player.play()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "rate" {
            if player.rate > 0 {
                print("audio started")
                
                self.topContainerView.btnPlay.setImage(UIImage(named: "btnPause"), for: .normal)
            }
            else {
                self.topContainerView.btnPlay.setImage(UIImage(named: "btnPlay"), for: .normal)
            }
        }
    }
    
/*    func swipedLeft(_ object: Any) {
        print("Swiped left: \(object)")
        if !self.isReachedEnd {
            self.selectedMusicIdx = Int(object as! String)! + 1
            self.nCurrentVersionIdx = 0
            
            self.topContainerView = self.swipeView.getCardViewOnTheTop() as! LMSongView
            self.playCurrentMusic()
        }
    }
    
    func swipedUp(_ object: Any) {
        print("Swiped up: \(object)")
        
        let musicSelected = self.arrMusics[self.selectedMusicIdx]
        
        if musicSelected.arrVersions.count > 1
        {
            if self.nCurrentVersionIdx == musicSelected.arrVersions.count - 1
            {
                self.nCurrentVersionIdx = 0
            }
            else {
                self.nCurrentVersionIdx = self.nCurrentVersionIdx + 1
            }
            self.reloadMusicVersion()
        }

    }
 */

}

