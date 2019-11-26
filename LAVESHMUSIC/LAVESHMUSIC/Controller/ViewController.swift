//
//  ViewController.swift
//  LAVESHMUSIC
//
//  Created by Tony Wang on 1/3/19.
//  Copyright © 2019 Tony Wang. All rights reserved.
//

import UIKit
import Firebase
import JHSpinner

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var btnSignup: UIButton!
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var imgViLogo: UIImageView!
    @IBOutlet weak var blackCover: UILabel!
    
    let sharedManager:Singleton = Singleton.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        imgViLogo.image = imgViLogo.image!.withRenderingMode(.alwaysTemplate)
        imgViLogo.tintColor = UIColor(red: 234.0/255.0, green: 218.0/255.0, blue: 82.0/255.0, alpha: 1)
        
        btnLogin.layer.borderColor = UIColor.white.cgColor
        btnLogin.layer.borderWidth = 1.0
        
        btnSignup.layer.borderColor = UIColor.white.cgColor
        btnSignup.layer.borderWidth = 1.0

        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        tfEmail.placeHolderColor = UIColor.lightGray
        tfPassword.placeHolderColor = UIColor.lightGray
        
        let tapBg = UITapGestureRecognizer(target: self, action:#selector(onTapBg(sender:)))
        self.view.addGestureRecognizer(tapBg)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.blackCover.isHidden = true
        
        if ((Auth.auth().currentUser?.uid) != nil)
        {
            self.blackCover.isHidden = false
            let spinner = JHSpinnerView.showOnView(view, spinnerColor:ColorPalette.laveshOrange, overlay:.roundedSquare, overlayColor:UIColor.darkGray.withAlphaComponent(0.8), text:nil)
            self.view.addSubview(spinner)
            
            let dbRef = Database.database().reference()
            dbRef.child("user_data").child((Auth.auth().currentUser?.uid)!).observeSingleEvent(of: .value, with: { (dataSnapshot) in
                
                spinner.dismiss()
                self.sharedManager.myUser.setUser(withDataSnapshot: dataSnapshot)
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let viCtrlTabs = storyboard.instantiateViewController(withIdentifier: "LMMyTabsViewController")
                self.navigationController?.pushViewController(viCtrlTabs, animated: true)
                
            }, withCancel: { (error) in
                spinner.dismiss()
                self.present(self.sharedManager.getErrorAlert(withError: error), animated: true, completion: nil)
            })
        }
        
    }
    
    // MARK - Own Methods
    @objc func onTapBg(sender:Any)
    {
        self.tfEmail.resignFirstResponder()
        self.tfPassword.resignFirstResponder()
    }
    
    func performLogin()
    {
        if self.tfEmail.text?.replacingOccurrences(of: " ", with: "") == "" {
            self.present(self.sharedManager.getAppAlert(withMsg: "Email is required."), animated: true, completion:nil)
            self.tfEmail.becomeFirstResponder()
            return
        }
        
        if self.tfPassword.text?.replacingOccurrences(of: " ", with: "") == "" {
            self.present(self.sharedManager.getAppAlert(withMsg: "Password is required."), animated: true, completion:nil)
            self.tfPassword.becomeFirstResponder()
            return
        }
        
        let spinner = JHSpinnerView.showOnView(view, spinnerColor:ColorPalette.laveshOrange, overlay:.roundedSquare, overlayColor:UIColor.darkGray.withAlphaComponent(0.8), text:nil)
        self.view.addSubview(spinner)
        
        Auth.auth().signIn(withEmail: self.tfEmail.text!, password: self.tfPassword.text!) { (authResult, error) in
            if error != nil{
                print(error)
                spinner.dismiss()
                self.present(self.sharedManager.getErrorAlert(withError: error!), animated: true, completion: nil)
            }
            else {
                let dbRef = Database.database().reference()
                dbRef.child("user_data").child((authResult?.user.uid)!).observeSingleEvent(of: .value, with: { (dataSnapshot) in
                    
                    spinner.dismiss()
                    self.sharedManager.myUser.setUser(withDataSnapshot: dataSnapshot)
                    
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let viCtrlTabs = storyboard.instantiateViewController(withIdentifier: "LMMyTabsViewController")
                    self.navigationController?.pushViewController(viCtrlTabs, animated: true)
                    
                }, withCancel: { (error) in
                    spinner.dismiss()
                    self.present(self.sharedManager.getErrorAlert(withError: error), animated: true, completion: nil)
                })
                
            }
        }
    }
    
    // MARK - Event Handlers
    @IBAction func onLogin(_ sender: Any) {
        self.performLogin()
    }
    
    
    // MARK - UITextFieldDelegate Methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.tfEmail
        {
            self.tfPassword.becomeFirstResponder()
        }
        else if textField == self.tfPassword {
            textField.resignFirstResponder()
            self.performLogin()
        }
        return true
    }

}

extension UITextField{
    @IBInspectable var placeHolderColor: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedStringKey.foregroundColor: newValue!])
        }
    }
}

