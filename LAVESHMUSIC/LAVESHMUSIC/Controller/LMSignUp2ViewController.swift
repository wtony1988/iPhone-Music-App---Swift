//
//  LMSignUp2ViewController.swift
//  LAVESHMUSIC
//
//  Created by Admin on 1/5/19.
//  Copyright © 2019 Tony Wang. All rights reserved.
//

import UIKit
import SSProgressBar
import JHSpinner
import Firebase

class LMSignUp2ViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    let stepProgressBar = SSProgressBar()
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var scrlViContainer: UIScrollView!
    @IBOutlet weak var imgViAvatar: UIImageView!
    @IBOutlet weak var tfUsername: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    
    let sharedManager:Singleton = Singleton.sharedInstance
    var isPhotoTaken:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        imgViAvatar.layer.masksToBounds = true
        imgViAvatar.layer.cornerRadius = imgViAvatar.frame.size.height / 2.0
        btnNext.layer.borderColor = UIColor.white.cgColor
        btnNext.layer.borderWidth = 1.0
        
        self.stepProgressBar.frame = CGRect(x: 20, y: 94, width: SCREEN_WIDTH - 40, height: 10)
        self.stepProgressBar.withProgressGradientBackground(from: ColorPalette.progressGradient1, to: ColorPalette.progressGradient2, direction: .topToBottom)
        self.stepProgressBar.progress = 33
        self.stepProgressBar.gradientDirection = .leftToRight
        
        self.stepProgressBar.layer.masksToBounds = true
        self.stepProgressBar.layer.cornerRadius = stepProgressBar.frame.size.height / 2.0
        self.view.addSubview(self.stepProgressBar)
        
        tfUsername.placeHolderColor2 = UIColor.lightGray
        tfPassword.placeHolderColor2 = UIColor.lightGray
        
        self.scrlViContainer.contentSize = CGSize(width: self.scrlViContainer.frame.size.width, height: 900)
        let tapBg = UITapGestureRecognizer(target: self, action:#selector(onTapBg(sender:)))
        self.view.addGestureRecognizer(tapBg)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated
        )
        UIView.animate(withDuration: 0.5) {
            self.stepProgressBar.progress = 66
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    func hideKeyboards()
    {
        self.tfUsername.resignFirstResponder()
        self.tfPassword.resignFirstResponder()
    }
    
    func validateAndSaveValue()
    {
        if self.tfUsername.text?.trimmingCharacters(in: .whitespaces) == ""
        {
            self.present(self.sharedManager.getAppAlert(withMsg: "Username is required. Please enter your unique username."), animated: true) {
                self.hideKeyboards()
                self.tfUsername.becomeFirstResponder()
                return
            }
        }
        else if self.tfPassword.text?.trimmingCharacters(in: .whitespaces) == ""
        {
            self.present(self.sharedManager.getAppAlert(withMsg: "Password is required. Please enter your password."), animated: true) {
                self.hideKeyboards()
                self.tfPassword.becomeFirstResponder()
                return
            }
        }
        self.sharedManager.dicRegisterValues["username"] = self.tfUsername.text
        
        self.registerUser()
    }
    
    func uploadPhoto(image:UIImage)
    {
        let spinner = JHSpinnerView.showOnView(view, spinnerColor:ColorPalette.laveshOrange, overlay:.roundedSquare, overlayColor:UIColor.darkGray.withAlphaComponent(0.8), text:"...Photo")
        self.view.addSubview(spinner)
        
        let storageRef = Storage.storage().reference()
        let imageData = UIImageJPEGRepresentation(image, 0.8)!
        let uuid = UUID().uuidString
        let imageRef = storageRef.child("user_images/\(uuid).jpg")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        imageRef.putData(imageData, metadata: metadata) { (metadata, error) in
            if error != nil {
                
                spinner.dismiss()
                self.present(self.sharedManager.getErrorAlert(withError: error!), animated: true, completion: nil)
                
            } else {
                spinner.dismiss()
                imageRef.downloadURL { (url, error) in
                    guard let downloadURL = url else {
                        // Uh-oh, an error occurred!
                        return
                    }
                    
                    self.sharedManager.dicRegisterValues["user_photo"] = downloadURL.absoluteString
                    self.updateUserData()
                }
                
            }
        }
    }
    
    func updateUserData()
    {
        let spinner = JHSpinnerView.showOnView(view, spinnerColor:ColorPalette.laveshOrange, overlay:.roundedSquare, overlayColor:UIColor.darkGray.withAlphaComponent(0.8), text:"...Data")
        self.view.addSubview(spinner)
        
        let dbRef = Database.database().reference()
        self.sharedManager.dicRegisterValues["uid"] = Auth.auth().currentUser?.uid
        dbRef.child("user_data").child(self.sharedManager.dicRegisterValues["uid"] as! String).updateChildValues(self.sharedManager.dicRegisterValues, withCompletionBlock: { (error, dataRef) in
            
            if error != nil{
                spinner.dismiss()
                self.present(self.sharedManager.getErrorAlert(withError: error!), animated: true, completion: nil)
            }
            else {
                spinner.dismiss()
                self.sharedManager.myUser.setUser(withUserDataDic: self.sharedManager.dicRegisterValues)
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let viCtrlSignUp3 = storyboard.instantiateViewController(withIdentifier: "LMSignUp3ViewController")
                self.navigationController?.pushViewController(viCtrlSignUp3, animated: true)
            }
            
        })
    }
    
    func registerUser() {
        
        let spinner = JHSpinnerView.showOnView(view, spinnerColor:ColorPalette.laveshOrange, overlay:.roundedSquare, overlayColor:UIColor.darkGray.withAlphaComponent(0.8), text:"Updating")
        self.view.addSubview(spinner)
        
        let email = self.sharedManager.dicRegisterValues["email"] as! String
        let password = self.tfPassword.text
        Auth.auth().createUser(withEmail: email, password: password!) { (authResult, error) in
        
            if error != nil{
                spinner.dismiss()
                self.present(self.sharedManager.getErrorAlert(withError: error!), animated: true, completion: nil)
            }
            else {
                spinner.dismiss()
                if self.isPhotoTaken
                {
                    self.uploadPhoto(image: self.imgViAvatar.image!)
                }
                else {
                    self.sharedManager.dicRegisterValues["user_photo"] = ""
                    self.updateUserData()
                }
                
            }
        }
    }
    
    // MARK: - Event Handlers
    @objc func onTapBg(sender:Any)
    {
        self.hideKeyboards()
    }
    
    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onNext(_ sender: Any) {
        self.validateAndSaveValue()
    }
    
    @IBAction func onTakePhoto(_ sender: Any) {
        
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        let actionSheet = UIAlertController(title: "Pick a photo from", message: nil, preferredStyle: .actionSheet)
        let actionCameraRoll = UIAlertAction(title: "Photo Library", style: .default) { (_) in
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: {
                
            })
        }
        
        let actionCamera = UIAlertAction(title: "Camera", style: .default) { (_) in
            imagePicker.sourceType = .camera
            self.present(imagePicker, animated: true, completion: {
                
            })
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        actionSheet.addAction(actionCameraRoll)
        actionSheet.addAction(actionCamera)
        actionSheet.addAction(cancelAction)
        
        self.present(actionSheet, animated: true, completion: nil)
        
    }
    
    // MARK: - UIImagePickerControllerDelegate Methods
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage
        {
            self.imgViAvatar.image = image
            self.isPhotoTaken = true
        }
        
    }
    
    // MARK: - UITextFieldDelegate Methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.tfUsername {
            self.tfPassword.becomeFirstResponder()
        }
        else if textField == self.tfPassword {
            textField.resignFirstResponder()
            self.validateAndSaveValue()
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == tfPassword {
            UIView.animate(withDuration: 0.4) {
                self.scrlViContainer.contentOffset = CGPoint(x: 0, y: 240)
            }
        }
    }
}

extension UITextField{
    @IBInspectable var placeHolderColor2: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedStringKey.foregroundColor: newValue!])
        }
    }
}
