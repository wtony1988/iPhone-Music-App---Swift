//
//  Singleton.swift
//
//

import Foundation
import UIKit
import AVFoundation
import CoreLocation
import Firebase

class Singleton {
    
    //MARK: Shared Instance
    
    static let sharedInstance : Singleton = {
        let instance = Singleton()
        return instance
    }()
    
    //MARK: Local Variable
    
    var postingFileURL: URL?
    //var arrCategories : [PNCategory] = [PNCategory]()
    
    var myUser: LMUser = LMUser.init()
    var arrLikedMusicIds = [String]()
    var dicRegisterValues = ["uid": "",
                       "email": "",
                       "username": "",
                       "first_name": "",
                       "last_name": "",
                       "company_name": "",
                       "phone": "",
                       "createdTimestamp": ""] as [String : Any]
    
    
    /*//MARK: Init
    
    convenience init() {
        self.init(array : [])
    }
    
    //MARK: Init Array
    
    init( array : [Dictionary]) {
        arrVideosInDraft = array
    }*/
    
    //MARK: General Methods
    
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    //func boldSubString(fromString: String, subString: String, font: UIFont, boldColor: UIColor) -> NSAttributedString {
    //    return attributedString(from: fromString, boldRange: fromString.lineRange(of: subString),font: font , boldColor: boldColor)
    //}
    
    /*func getUser(withId id: String, completion: @escaping (User?) -> Void) {
        
        let ref = FIRDatabase.database().reference()

        ref.child("users").child(id).observe(.value, with: { (snapshot) in
            guard let user = snapshot.value as? [String: Any] else {
                completion(nil)
                return
            }
            
            let name = user["name"] as! String
            let createdTimestamp = user["createdTimestamp"] as! Int
            
            var profileImageUrl: URL?
            if let profileImageUrlString = user["profileImageUrl"] as? String, !profileImageUrlString.isEmpty {
                profileImageUrl = URL(string: profileImageUrlString)
            }
            
            let role = user["role"] as! String
            let isVerified = user["is_verified"] as! String
            
            let _user = User(uid: id, name: name, profileImageUrl: profileImageUrl, createdTimestamp: createdTimestamp, listingIdsByType: [:], ratingsById: [:], groups: [], chats: [], isVerified: isVerified, role:role)
            
            completion(_user)
        })
    }*/
    
    func videoSnapshot(filePathLocal: String) -> UIImage? {
        
        let asset = AVAsset.init(url: URL.init(string: filePathLocal)!)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        
        let timestamp = CMTime(seconds: 1, preferredTimescale: 60)
        
        do {
            let imageRef = try generator.copyCGImage(at: timestamp, actualTime: nil)
            return UIImage.init(cgImage: imageRef)
        }
        catch let error as NSError
        {
            print("Image generation failed with error \(error)")
            return nil
        }
    }
    
    func setVideoSnapshot(filePathLocal: String, forImageView:UIImageView) {
        
        let asset = AVAsset.init(url: URL.init(string: filePathLocal)!)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        
        let timestamp = CMTime(seconds: 1, preferredTimescale: 60)
        
        do {
            let imageRef = try generator.copyCGImage(at: timestamp, actualTime: nil)
            forImageView.image = UIImage.init(cgImage: imageRef)
        }
        catch let error as NSError
        {
            print("Image generation failed with error \(error)")
        }
    }
    
    /*func attributedString(from string: String, boldRange: NSRange?, font: UIFont, boldColor: UIColor) -> NSAttributedString {
        let attrs = [
            NSAttributedStringKey.font: font
        ]
        let boldAttribute = [
            NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: font.pointSize),
            NSAttributedStringKey.foregroundColor: boldColor
            ]
        let attrStr = NSMutableAttributedString(string: string, attributes: attrs)
        if let range = boldRange {
            attrStr.setAttributes(boldAttribute, range: range)
        }
        return attrStr
    }*/
    
    func getTimeStringFromDouble(totalSeconds:Double) -> String {
        //let hours = Int(time) / 3600
        let minutes = Int(totalSeconds) / 60 % 60
        let seconds = Int(totalSeconds) % 60
        return String(format:"%02i:%02i", minutes, seconds)
    }
    
    func getTimeStringFromInt(totalSeconds:Int) -> String {
        //let hours = Int(time) / 3600
        let minutes = totalSeconds / 60 % 60
        let seconds = totalSeconds % 60
        return String(format:"%02i:%02i", minutes, seconds)
    }
    
    func getTimeStringFromCMTime(duration:CMTime) -> String {
        let totalSeconds = CMTimeGetSeconds(duration)
        let minutes = Int(totalSeconds) / 60 % 60
        let seconds = Int(totalSeconds) % 60
        return String(format:"%02i:%02i", minutes, seconds)
    }
    
    func stringDateAndTimeOfNewzForNow() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM/dd/yyyy - HH:mm a"
        return dateFormatter.string(from: Date())
    }
    
    func stringDateAndTimeOfNewzWithFormat1(newzDate:Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm a - dd MMM yyyy"
        return dateFormatter.string(from: newzDate)
    }
    
    func stringDateAndTimeOfNewzWithFormat2(newzDate:Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy - HH:mm a"
        return dateFormatter.string(from: newzDate)
    }
    
    func calculateDistanceInMeters(fromLatitude:Double, fromLongitude: Double, toLatitude:Double, toLongitude:Double) -> Double
    {
        let coordinate0 = CLLocation(latitude: fromLatitude, longitude: fromLongitude)
        let coordinate1 = CLLocation(latitude: toLatitude, longitude: toLongitude)
        
        return coordinate0.distance(from: coordinate1) 
    }
    
    //MARK: App Methods
    
    func getLikedMusics()
    {
        self.arrLikedMusicIds.removeAll()
        let dbRef = Database.database().reference()
        dbRef.child("user_data").child(self.myUser.uid!).child("liked_musics").observeSingleEvent(of: .value, with: { (dataSnapshot) in
            
            if let snapshots = dataSnapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshots {
                    self.arrLikedMusicIds.append(snap.value as! String)
                }
            }
            
        }, withCancel: { (error) in
            print(error)
        })
    }
    
    func isLikedMusic(musicId:String) -> Bool {
        for tempId in self.arrLikedMusicIds
        {
            if tempId == musicId
            {
                return true
            }
        }
        return false
    }
    
    func getAppAlert(withMsg:String) -> UIAlertController {
        let alert = UIAlertController(title: APP_NAME, message: withMsg, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            alert.dismiss(animated: true, completion: {
                
            })
        }))
        return alert;
    }
    
    func getAlertWith(title: String, andMsg:String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: andMsg, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            alert.dismiss(animated: true, completion: {
            })
        }))
        return alert;
    }
    
    func getErrorAlert(withError:Error) -> UIAlertController {
        let alert = UIAlertController(title: "Error", message: withError.localizedDescription , preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            alert.dismiss(animated: true, completion: {
                
            })
        }))
        return alert;
    }
    
    /*func attachAddNewzProgress(withSate:ADD_NEWZ_PROGRESS, toView:UIView){
        let arrTitles = ["ADD MAIN\nVIDEO/S", "Add\nCommentary", "Add\nInterview", "Add\nDescription", "PUBLISH\nNEWZ"]
        
        let stateViewWidth = SCREEN_WIDTH / 5.0
        //let viProgress = UIView.init(frame: CGRect.init(x: 0, y: 64, width: SCREEN_WIDTH, height: 66))
        for i in 0...arrTitles.count - 1 {
            let stateView = UIView.init(frame: CGRect.init(x: CGFloat(i) * stateViewWidth, y: 0, width: stateViewWidth, height: 66))
            let markerLabel = UILabel.init(frame: CGRect.init(x: (stateViewWidth - 20.0) / 2.0, y: 20, width: 20, height: 20))
            markerLabel.font = UIFont.systemFont(ofSize: 12.0, weight: UIFont.Weight.medium)
            markerLabel.textColor = UIColor.white
            markerLabel.textAlignment = NSTextAlignment.center
            markerLabel.layer.masksToBounds = true
            markerLabel.layer.cornerRadius = 10.0
            
            let titleLabel = UILabel.init(frame: CGRect.init(x: (stateViewWidth - 66.0) / 2.0, y: 46, width: 66, height: 20))
            titleLabel.font = UIFont.systemFont(ofSize: 8.0, weight: UIFont.Weight.medium)
            titleLabel.textAlignment = NSTextAlignment.center
            titleLabel.numberOfLines = 2
            titleLabel.text = arrTitles[i].uppercased()
            
            if i < withSate.key()
            {
                markerLabel.backgroundColor = PN_COLOR_BLACK_BLUE
                markerLabel.text = String.init("✓")
                titleLabel.textColor = UIColor.black
            }
            else if i == withSate.key(){
                markerLabel.backgroundColor = PN_COLOR_BLACK_BLUE
                markerLabel.text = String.init(format: "%d", i + 1)
                
                if  withSate == .addNewzStart
                {
                    titleLabel.textColor = UIColor.white
                }
                else {
                    titleLabel.textColor = UIColor.black
                }
            }
            else {
                markerLabel.backgroundColor = UIColor.lightGray
                markerLabel.text = String.init(format: "%d", i + 1)
                titleLabel.textColor = UIColor.lightGray
            }
            
            stateView.addSubview(markerLabel)
            stateView.addSubview(titleLabel)
            toView.addSubview(stateView)
        }
    }*/
    
    func addBottomBlackGradient(toView:UIView) {
        let gradient = CAGradientLayer()
        gradient.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: toView.frame.size.height)
        gradient.colors = [
            UIColor.clear.cgColor,
            UIColor.black.cgColor
        ]
        gradient.locations = [0, 1]
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1)
        toView.layer.addSublayer(gradient)
    }
    
    // MARK: - MailGun Methods
    
    func sendMailTo(receiverName:String, receiverEmail:String, subject:String, text:String, html: String)
    {
        let request: NSMutableURLRequest = NSMutableURLRequest(url: URL(string: String(format: "https://api.mailgun.net/v3/%@/messages", Constants.MailGun.domain_name))!)
        request.httpMethod = "POST"
        
        // Basic Authentication
        let loginString = String(format: "api:%@", Constants.MailGun.apiKey)
        let loginData: Data = loginString.data(using: .utf8)!
        let base64LoginString = loginData.base64EncodedString(options: [])
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        
        let bodyStr = String(format: "from=LAVESHMUSIC <mailgun@%@>&to=%@ <%@>&subject=%@&text=%@&html=%@", Constants.MailGun.domain_name, receiverName, receiverEmail, subject, text, html)
        
        // appending the data
        request.httpBody = bodyStr.data(using: .utf8)
        
        
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            // ... do other stuff here
            print("mail error: %@", error)
        })
        
        task.resume()
        
    }
}
