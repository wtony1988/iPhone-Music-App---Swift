//
//  LMLicensingViewController.swift
//  LAVESHMUSIC
//
//  Created by Admin on 2/10/19.
//  Copyright © 2019 Tony Wang. All rights reserved.
//

import UIKit

class LMLicensingViewController: UIViewController{

    @IBOutlet weak var imgViMusicThumb: UIImageView!
    @IBOutlet weak var lblMusicTitle: UILabel!
    
    @IBOutlet weak var lblSinger: UILabel!
    
    let sharedManager:Singleton = Singleton.sharedInstance
    
    var musicVersion = LMSingleMusic()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.imgViMusicThumb.sd_setImage(with: self.musicVersion.thumbImageURL, completed: nil)
        self.lblMusicTitle.text = self.musicVersion.title.uppercased()
        self.lblSinger.text = self.musicVersion.singer.uppercased()
        
        self.sendMail()
    }
    
    // MARK: - Own Methods
    func sendMail()
    {
        self.sharedManager.sendMailTo(receiverName: self.sharedManager.myUser.username!, receiverEmail: self.sharedManager.myUser.email!, subject: String(format: "Thank you for licensing %@", self.musicVersion.title.uppercased()), text: "Please sign form to receive your download!", html: "")
        
    }
    
    // MARK: - Event Handlers
    @IBAction func onDone(_ sender: Any) {
        self.dismiss(animated: true) {
            
        }
    }
    

    /*
    // MARK: - Navigation
s
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
