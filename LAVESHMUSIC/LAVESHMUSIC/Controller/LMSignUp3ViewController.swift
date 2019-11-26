//
//  LMSignUp3ViewController.swift
//  LAVESHMUSIC
//
//  Created by Admin on 1/5/19.
//  Copyright © 2019 Tony Wang. All rights reserved.
//

import UIKit
import SSProgressBar

class LMSignUp3ViewController: UIViewController, UITextFieldDelegate {

    let stepProgressBar = SSProgressBar()
    @IBOutlet weak var btnSkip: UIButton!
    @IBOutlet weak var tfCardNumber: UITextField!
    @IBOutlet weak var tfMM: UITextField!
    @IBOutlet weak var tfCVC: UITextField!
    @IBOutlet weak var scrlViContainer: UIScrollView!
    
    let sharedManager:Singleton = Singleton.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        btnSkip.layer.borderColor = UIColor.white.cgColor
        btnSkip.layer.borderWidth = 1.0
        
        self.stepProgressBar.frame = CGRect(x: 20, y: 94, width: SCREEN_WIDTH - 40, height: 10)
        stepProgressBar.withProgressGradientBackground(from: ColorPalette.progressGradient1, to: ColorPalette.progressGradient2, direction: .topToBottom)
        self.stepProgressBar.progress = 66
        self.stepProgressBar.gradientDirection = .leftToRight
        
        self.stepProgressBar.layer.masksToBounds = true
        self.stepProgressBar.layer.cornerRadius = stepProgressBar.frame.size.height / 2.0
        self.view.addSubview(self.stepProgressBar)
        
        self.tfCardNumber.placeHolderColor3 = UIColor.lightGray
        self.tfMM.placeHolderColor3 = UIColor.lightGray
        self.tfCVC.placeHolderColor3 = UIColor.lightGray
        
        self.scrlViContainer.contentSize = CGSize(width: self.scrlViContainer.frame.size.width, height: 900)
        let tapBg = UITapGestureRecognizer(target: self, action:#selector(onTapBg(sender:)))
        self.view.addGestureRecognizer(tapBg)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated
        )
        UIView.animate(withDuration: 0.5) {
            self.stepProgressBar.progress = 100
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
    func saveValue()
    {
    }
    
    // MARK: - Event Handlers
    @objc func onTapBg(sender:Any)
    {
        self.tfCardNumber.resignFirstResponder()
        self.tfMM.resignFirstResponder()
        self.tfCVC.resignFirstResponder()
    }
    
    @IBAction func onSkip(_ sender: Any) {
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
        self.navigationController!.popToViewController(viewControllers[viewControllers.count - 4], animated: true)

    }
    
    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - UITextFieldDelegate Methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.tfCardNumber {
            self.tfMM.becomeFirstResponder()
        }
        else if textField == self.tfMM {
            self.tfCVC.becomeFirstResponder()
        }
        else if textField == self.tfCVC {
            textField.resignFirstResponder()
            self.saveValue()
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == tfMM || textField == tfCVC {
            UIView.animate(withDuration: 0.4) {
                self.scrlViContainer.contentOffset = CGPoint(x: 0, y: 240)
            }
        }
    }
}

extension UITextField{
    @IBInspectable var placeHolderColor3: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedStringKey.foregroundColor: newValue!])
        }
    }
}
