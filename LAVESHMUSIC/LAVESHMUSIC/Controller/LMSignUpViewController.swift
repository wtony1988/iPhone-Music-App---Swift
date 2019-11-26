//
//  LMSignUpViewController.swift
//  LAVESHMUSIC
//
//  Created by Tony Wang on 1/4/19.
//  Copyright © 2019 Tony Wang. All rights reserved.
//

import UIKit
import SSProgressBar

class LMSignUpViewController: UIViewController, UITextFieldDelegate {

    let stepProgressBar = SSProgressBar()
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var scrlViContainer: UIScrollView!
    @IBOutlet weak var tfFirstName: UITextField!
    @IBOutlet weak var tfLastName: UITextField!
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfCompany: UITextField!
    @IBOutlet weak var tfPhoneNumber: UITextField!
    
    let sharedManager:Singleton = Singleton.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        btnNext.layer.borderColor = UIColor.white.cgColor
        btnNext.layer.borderWidth = 1.0
        
        self.stepProgressBar.frame = CGRect(x: 20, y: 94, width: SCREEN_WIDTH - 40, height: 10)
        self.stepProgressBar.withProgressGradientBackground(from: ColorPalette.progressGradient1, to: ColorPalette.progressGradient2, direction: .topToBottom)
        self.stepProgressBar.progress = 0
        self.stepProgressBar.gradientDirection = .leftToRight
        
        self.stepProgressBar.layer.masksToBounds = true
        self.stepProgressBar.layer.cornerRadius = self.stepProgressBar.frame.size.height / 2.0
        self.view.addSubview(self.stepProgressBar)
        
        tfFirstName.placeHolderColor1 = UIColor.lightGray
        tfLastName.placeHolderColor1 = UIColor.lightGray
        tfEmail.placeHolderColor1 = UIColor.lightGray
        tfCompany.placeHolderColor1 = UIColor.lightGray
        tfPhoneNumber.placeHolderColor1 = UIColor.lightGray
        
        self.scrlViContainer.contentSize = CGSize(width: self.scrlViContainer.frame.size.width, height: 900)
        let tapBg = UITapGestureRecognizer(target: self, action:#selector(onTapBg(sender:)))
        self.view.addGestureRecognizer(tapBg)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated
        )
        UIView.animate(withDuration: 0.5) {
            self.stepProgressBar.progress = 33
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
        self.tfEmail.resignFirstResponder()
        self.tfFirstName.resignFirstResponder()
        self.tfLastName.resignFirstResponder()
        self.tfCompany.resignFirstResponder()
        self.tfPhoneNumber.resignFirstResponder()
    }
    
    func validateAndSaveValue()
    {
        if self.tfFirstName.text?.trimmingCharacters(in: .whitespaces) == ""
        {
            self.present(self.sharedManager.getAppAlert(withMsg: "First Name is required. Please enter your first name."), animated: true) {
                self.hideKeyboards()
                self.tfFirstName.becomeFirstResponder()
                return
            }
        }
        else if self.tfLastName.text?.trimmingCharacters(in: .whitespaces) == ""
        {
            self.present(self.sharedManager.getAppAlert(withMsg: "Last Name is required. Please enter your last name."), animated: true) {
                self.hideKeyboards()
                self.tfLastName.becomeFirstResponder()
                return
            }
        }
        else if self.tfEmail.text?.trimmingCharacters(in: .whitespaces) == ""
        {
            self.present(self.sharedManager.getAppAlert(withMsg: "Email is required. Please enter your email address."), animated: true) {
                self.hideKeyboards()
                self.tfEmail.becomeFirstResponder()
                return
            }
        }
        else if !self.sharedManager.isValidEmail(testStr: self.tfEmail.text!)
        {
            self.present(self.sharedManager.getAppAlert(withMsg: "Please input correct email address."), animated: true) {
                self.hideKeyboards()
                self.tfEmail.becomeFirstResponder()
                return
            }
        }
        else if self.tfCompany.text?.trimmingCharacters(in: .whitespaces) == ""
        {
            self.present(self.sharedManager.getAppAlert(withMsg: "Company Name is required. Please enter your company name."), animated: true) {
                self.hideKeyboards()
                self.tfCompany.becomeFirstResponder()
                return
            }
        }
        else if self.tfPhoneNumber.text?.trimmingCharacters(in: .whitespaces) == ""
        {
            self.present(self.sharedManager.getAppAlert(withMsg: "Phone Number is required. Please enter your phone number."), animated: true) {
                self.hideKeyboards()
                self.tfPhoneNumber.becomeFirstResponder()
                return
            }
        }
        self.sharedManager.dicRegisterValues["first_name"] = self.tfFirstName.text
        self.sharedManager.dicRegisterValues["last_name"] = self.tfLastName.text
        self.sharedManager.dicRegisterValues["email"] = self.tfEmail.text
        self.sharedManager.dicRegisterValues["company_name"] = self.tfCompany.text
        self.sharedManager.dicRegisterValues["phone"] = self.tfPhoneNumber.text

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
    
    // MARK: - UITextFieldDelegate Methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.tfFirstName {
            self.tfLastName.becomeFirstResponder()
        }
        else if textField == self.tfLastName {
            self.tfEmail.becomeFirstResponder()
        }
        else if textField == self.tfEmail {
            self.tfCompany.becomeFirstResponder()
        }
        else if textField == self.tfCompany {
            self.tfPhoneNumber.becomeFirstResponder()
        }
        else if textField == self.tfPhoneNumber {
            textField.resignFirstResponder()
            self.validateAndSaveValue()
        }
        
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == tfCompany || textField == tfPhoneNumber {
            UIView.animate(withDuration: 0.4) {
                self.scrlViContainer.contentOffset = CGPoint(x: 0, y: 240)
            }
        }
    }

}

extension UITextField{
    @IBInspectable var placeHolderColor1: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedStringKey.foregroundColor: newValue!])
        }
    }
}
