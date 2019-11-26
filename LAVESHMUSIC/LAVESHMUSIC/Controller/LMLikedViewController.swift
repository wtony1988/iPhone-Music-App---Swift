//
//  LMLikedViewController.swift
//  LAVESHMUSIC
//
//  Created by Tony Wang on 1/4/19.
//  Copyright © 2019 Tony Wang. All rights reserved.
//

import UIKit
import Firebase
import JHSpinner

private let reuseIdentifier = "MusicCollectionCell"

class LMLikedViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var cltViSaved: UICollectionView!
    
    let sharedManager:Singleton = Singleton.sharedInstance
    var arrLikedMusics = [LMMusic]()
    var selectedMusicId = "0"


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        cltViSaved.alwaysBounceVertical = true
        cltViSaved.register(UINib(nibName: "MusicCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getUpdatedLikedMusics()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Adjust listingsCollectionViewCell width to screensize.
        if let layout = cltViSaved.collectionViewLayout as? UICollectionViewFlowLayout {

            layout.itemSize = CGSize(width: 170, height: 250)
            layout.invalidateLayout()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "showPlayerFromFolder" {
            let viCtrlPlayer = segue.destination as! LMPlayerViewController
            viCtrlPlayer.oneMusicId = self.selectedMusicId
        }
    }
    
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
            self.loadLikedMusics()
            
        }, withCancel: { (error) in
            spinner.dismiss()
            self.present(self.sharedManager.getErrorAlert(withError: error), animated: true, completion: nil)
        })
    }
    
    func loadLikedMusics(){
        self.arrLikedMusics.removeAll()
        
        let spinner = JHSpinnerView.showOnView(view, spinnerColor:ColorPalette.laveshOrange, overlay:.roundedSquare, overlayColor:UIColor.darkGray.withAlphaComponent(0.8), text:nil)
        self.view.addSubview(spinner)
        

        let dispatchGroup = DispatchGroup()

        for musicId in self.sharedManager.arrLikedMusicIds
        {
            
            dispatchGroup.enter()
            let dbRef = Database.database().reference()
            dbRef.child("music_data").child(musicId).observeSingleEvent(of: .value) { (dataSnapShot) in
                if let dicMusic = dataSnapShot.value as? Dictionary<String, AnyObject> {
                    
                    let music = LMMusic()
                    music.setValues(withDictionary: dicMusic)
                    self.arrLikedMusics.append(music)
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            spinner.dismiss()
            self.cltViSaved.reloadData()
        }
        
    }
    
    // MARK: - UICollectionViewDataSource, UICollectionViewDelegate Methods
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrLikedMusics.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let musicCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MusicCollectionViewCell
        
        musicCell.imgViSinger.layer.masksToBounds = true
        musicCell.imgViSinger.layer.cornerRadius = musicCell.imgViSinger.frame.size.width / 2.0
        
        let music = self.arrLikedMusics[indexPath.row]
        let musicVersion = music.arrVersions[0]
        
        musicCell.imgViMusicThumb.sd_setImage(with: musicVersion.thumbImageURL, completed: nil)
        musicCell.lblMusicTitle.text = musicVersion.title.uppercased()
        musicCell.lblSinger.text = musicVersion.singer.uppercased()
        
        return musicCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let music = self.arrLikedMusics[indexPath.row]
        self.selectedMusicId = music.id
        performSegue(withIdentifier: "showPlayerFromFolder", sender: collectionView.cellForItem(at: indexPath))
    }
}
