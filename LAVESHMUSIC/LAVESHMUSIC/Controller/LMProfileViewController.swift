//
//  LMProfileViewController.swift
//  LAVESHMUSIC
//
//  Created by Tony Wang on 1/4/19.
//  Copyright © 2019 Tony Wang. All rights reserved.
//

import UIKit
import Firebase
import JHSpinner
import SDWebImage

class LMProfileViewController: UIViewController {

    @IBOutlet weak var imgViBanner: UIImageView!
    @IBOutlet weak var imgViAvatar: UIImageView!
    @IBOutlet weak var btnEdit: UIButton!
    
    @IBOutlet weak var lblFullName: UILabel!
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var lblCompany: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var lblPhone: UILabel!
    
    @IBOutlet weak var btnLogout: UIButton!
    
    let sharedManager:Singleton = Singleton.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        imgViAvatar.layer.masksToBounds = true
        imgViAvatar.layer.cornerRadius = imgViAvatar.frame.size.width / 2.0
        imgViAvatar.layer.borderWidth = 1.0
        imgViAvatar.layer.borderColor = UIColor.black.cgColor
        
        btnEdit.layer.borderColor = UIColor.white.cgColor
        btnEdit.layer.borderWidth = 1.0

        btnLogout.layer.borderColor = UIColor.white.cgColor
        btnLogout.layer.borderWidth = 1.0
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.displayProfile()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onLogout(_ sender: Any) {
        
        let spinner = JHSpinnerView.showOnView(view, spinnerColor:ColorPalette.laveshOrange, overlay:.roundedSquare, overlayColor:UIColor.darkGray.withAlphaComponent(0.8), text:nil)
        self.view.addSubview(spinner)

        try! Auth.auth().signOut()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
            spinner.dismiss()
            
            self.tabBarController?.navigationController?.popToRootViewController(animated: true)
        })
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Own Methods

    func displayProfile()
    {
        self.lblFullName.text = sharedManager.myUser.firstName! + " " + sharedManager.myUser.lastName!
        self.lblUsername.text = "@" + sharedManager.myUser.username!
        self.lblCompany.text = sharedManager.myUser.company
        self.lblEmail.text = sharedManager.myUser.email
        self.lblPhone.text = sharedManager.myUser.phone
        
        //self.imgViAvatar.sd_setImage(with: sharedManager.myUser.userAvatarURL, completed: nil)
        self.imgViAvatar.sd_setImage(with: sharedManager.myUser.userAvatarURL, placeholderImage: UIImage(named: "avatarEmpty"), options: [], completed: nil)
        

    }

}
