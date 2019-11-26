//
//  LMEditProfileViewController.swift
//  LAVESHMUSIC
//
//  Created by Admin on 3/7/19.
//  Copyright © 2019 Tony Wang. All rights reserved.
//

import UIKit
import JHSpinner
import Firebase

class LMEditProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var tblViProfile: UITableView!
    
    @IBOutlet weak var viInput: UIView!
    @IBOutlet weak var lblInputTitle: UILabel!
    
    @IBOutlet weak var viInputValue1: UIView!
    @IBOutlet weak var tfInputValue1: UITextField!
    
    @IBOutlet weak var viInputValue2: UIView!
    @IBOutlet weak var tfInputValue2: UITextField!
    
    @IBOutlet weak var btnInputOk: UIButton!
    @IBOutlet weak var btnInputCancel: UIButton!
    
    private let textCellReuseIdentifier = "EditTextTableViewCell"
    private let photoCellReuseIdentifier = "EditPhotoTableViewCell"

    var nSelectedEditFieldIdx = SELECTED_NONE
    let sharedManager:Singleton = Singleton.sharedInstance
    var arrFields = [[String: String]]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tblViProfile.register(UINib(nibName: "EditTextTableViewCell", bundle: nil), forCellReuseIdentifier: textCellReuseIdentifier)
        tblViProfile.register(UINib(nibName: "EditPhotoTableViewCell", bundle: nil), forCellReuseIdentifier: photoCellReuseIdentifier)
        
        self.btnInputOk.layer.borderWidth = 1.0
        self.btnInputOk.layer.borderColor = UIColor.black.cgColor
        
        self.btnInputCancel.layer.borderWidth = 1.0
        self.btnInputCancel.layer.borderColor = UIColor.black.cgColor
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.reloadFields()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Own Methods
    func reloadFields()
    {
        self.arrFields = [
            ["title": "Change your @username", "value": self.sharedManager.myUser.username, "type": "text"],
            ["title": "Edit your first name", "value": self.sharedManager.myUser.firstName, "type": "text"],
            ["title": "Edit your last name", "value": self.sharedManager.myUser.lastName, "type": "text"],
            ["title": "Change your email address", "value": self.sharedManager.myUser.email, "type": "text"],
            ["title": "Change your password", "value": "Tap here to change your password", "type": "text"],
            ["title": "Change your phone number", "value": self.sharedManager.myUser.phone, "type": "text"],
            ["title": "Change your photo", "value": "", "type": "photo"],
            ["title": "Edit your company name", "value": self.sharedManager.myUser.company, "type": "text"]
            ] as! [[String : String]]
        self.tblViProfile.reloadData()
    }
    func showPhotoPicker()
    {
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
    
    func showInputView()
    {
        
        let fieldData = self.arrFields[self.nSelectedEditFieldIdx]
        self.lblInputTitle.text = fieldData["title"]?.uppercased()

        if self.nSelectedEditFieldIdx == 4 {
            self.viInputValue2.isHidden = false
            
            self.viInputValue1.frame = CGRect(x: 16, y: 60, width: 268, height: 40)
            self.viInputValue2.frame = CGRect(x: 16, y: 124, width: 268, height: 40)
            
            self.tfInputValue1.text = ""
            self.tfInputValue1.placeholder = "Old Password"
            self.tfInputValue2.text = ""
            self.tfInputValue2.placeholder = "New Password"
            
            self.tfInputValue1.isSecureTextEntry = true
            self.tfInputValue2.isSecureTextEntry = true

        }
        else {
            self.viInputValue2.isHidden = true
            self.viInputValue1.frame = CGRect(x: 16, y: 90, width: 268, height: 40)
            
            self.tfInputValue1.placeholder = fieldData["title"]
            self.tfInputValue1.text = fieldData["value"]
            
            self.tfInputValue1.isSecureTextEntry = false
        }
        
        self.viInput.alpha = 0
        self.viInput.isHidden = false
        
        UIView.animate(withDuration: 0.3) {
            self.viInput.alpha = 1.0
        }
    }

    func updateEdited()
    {
        var fieldName:String = ""
        switch self.nSelectedEditFieldIdx {
        case 0:
            fieldName = "username"
            break
        case 1:
            fieldName = "first_name"
            break
        case 2:
            fieldName = "last_name"
            break
        case 3:
            fieldName = "email"
            break
        case 5:
            fieldName = "phone"
            break
        case 7:
            fieldName = "company_name"
            break
        
        default:
            break
        }
        
        let spinner = JHSpinnerView.showOnView(view, spinnerColor:ColorPalette.laveshOrange, overlay:.roundedSquare, overlayColor:UIColor.darkGray.withAlphaComponent(0.8), text:nil)
        self.view.addSubview(spinner)
        
        if self.nSelectedEditFieldIdx == 4 {
            
            let user = Auth.auth().currentUser
            let credential = EmailAuthProvider.credential(withEmail: self.sharedManager.myUser.email!, password: self.tfInputValue1.text!)
            
            user?.reauthenticateAndRetrieveData(with: credential, completion: { (dataResult, error) in
                if let error = error {
                    // An error happened.
                    spinner.dismiss()
                    self.present(self.sharedManager.getErrorAlert(withError: error), animated: true, completion: nil)
                    
                } else {
                    // User re-authenticated.
                    Auth.auth().currentUser?.updatePassword(to: self.tfInputValue2.text!) { (error) in
                        
                        if let error = error {
                            // An error happened.
                            spinner.dismiss()
                            self.present(self.sharedManager.getErrorAlert(withError: error), animated: true, completion: nil)
                            
                        } else {
                            spinner.dismiss()
                        }
                    }
                }
            })
            
        }
        else {
            let dbRef = Database.database().reference()
            dbRef.child("user_data").child(self.sharedManager.dicRegisterValues["uid"] as! String).child(fieldName).setValue(self.tfInputValue1.text) { (error, dataRef) in
                if error != nil{
                    spinner.dismiss()
                    self.present(self.sharedManager.getErrorAlert(withError: error!), animated: true, completion: nil)
                }
                else {
                    spinner.dismiss()
                    
                    switch self.nSelectedEditFieldIdx {
                    case 0:
                        self.sharedManager.myUser.username = self.tfInputValue1.text
                        break
                    case 1:
                        self.sharedManager.myUser.firstName = self.tfInputValue1.text
                        break
                    case 2:
                        self.sharedManager.myUser.lastName = self.tfInputValue1.text
                        break
                    case 3:
                        self.sharedManager.myUser.email = self.tfInputValue1.text
                        break
                    case 5:
                        self.sharedManager.myUser.phone = self.tfInputValue1.text
                        break
                    case 7:
                        self.sharedManager.myUser.company = self.tfInputValue1.text
                        break
                        
                    default:
                        break
                    }
                    self.reloadFields()
                    
                }
            }
        }
    }
    
    func uploadPhoto(image:UIImage)
    {
        let spinner = JHSpinnerView.showOnView(view, spinnerColor:ColorPalette.laveshOrange, overlay:.roundedSquare, overlayColor:UIColor.darkGray.withAlphaComponent(0.8), text:nil)
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
                    
                    self.sharedManager.myUser.userAvatarURL = URL(string: downloadURL.absoluteString)
                    self.reloadFields()
                }
                
            }
        }
    }
    
    // MARK: - Event Handlers
    @IBAction func onInputOk(_ sender: Any) {
        
        UIView.animate(withDuration: 0.3, animations: {
            self.viInput.alpha = 0.0

        }) { (complete) in
            self.viInput.isHidden = true
            self.tfInputValue1.resignFirstResponder()
            self.tfInputValue2.resignFirstResponder()
            self.updateEdited()
        }
    }
    
    @IBAction func onInputCancel(_ sender: Any) {
        
        UIView.animate(withDuration: 0.3, animations: {
            self.viInput.alpha = 0.0
            
        }) { (complete) in
            self.viInput.isHidden = true
            self.tfInputValue1.resignFirstResponder()
            self.tfInputValue2.resignFirstResponder()
        }
    }
    
    @objc func onLogout(sender: Any) {
        
        let spinner = JHSpinnerView.showOnView(view, spinnerColor:ColorPalette.laveshOrange, overlay:.roundedSquare, overlayColor:UIColor.darkGray.withAlphaComponent(0.8), text:nil)
        self.view.addSubview(spinner)
        
        try! Auth.auth().signOut()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
            spinner.dismiss()
            
            self.tabBarController?.navigationController?.popToRootViewController(animated: true)
        })
    }
    
    // MARK: - UIImagePickerControllerDelegate Methods
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage
        {
            self.uploadPhoto(image: image)
        }
        
    }

    // MARK: - UITableView Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrFields.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let fieldData = self.arrFields[indexPath.row]
        
        if fieldData["type"] == "photo"
        {
            return 88
        }
        return 60
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 80
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 80))
        let btnSignOut = UIButton(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 80))
        btnSignOut.setTitle("LOG OUT", for: .normal)
        btnSignOut.setTitleColor(ColorPalette.laveshOrange, for: .normal)
        
        btnSignOut.addTarget(self, action: #selector(onLogout(sender:)), for: .touchUpInside)
        
        footer.addSubview(btnSignOut)
        
        return footer
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let fieldData = self.arrFields[indexPath.row]
        
        if fieldData["type"] == "photo"
        {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: photoCellReuseIdentifier, for: indexPath) as? EditPhotoTableViewCell
                else {
                    return UITableViewCell()
            }
            cell.lblLabel.text = fieldData["title"]?.uppercased()
            
            cell.imgViPhoto.layer.masksToBounds = true
            cell.imgViPhoto.layer.cornerRadius = cell.imgViPhoto.frame.size.height / 2.0
            cell.imgViPhoto.sd_setImage(with: sharedManager.myUser.userAvatarURL, placeholderImage: UIImage(named: "avatarEmpty"), options: [], completed: nil)
            return cell
        }
        else
        {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: textCellReuseIdentifier, for: indexPath) as? EditTextTableViewCell
                else {
                    return UITableViewCell()
            }
            
            cell.lblLabel.text = fieldData["title"]?.uppercased()
            cell.lblTitle.text = fieldData["value"]

            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.reloadRows(at: [indexPath], with: .fade)
        
        self.nSelectedEditFieldIdx = indexPath.row
        
        let fieldData = self.arrFields[indexPath.row]
        
        if fieldData["type"] == "photo"
        {
            self.showPhotoPicker()
        }
        else {
            self.showInputView()
        }
        
    }
}
