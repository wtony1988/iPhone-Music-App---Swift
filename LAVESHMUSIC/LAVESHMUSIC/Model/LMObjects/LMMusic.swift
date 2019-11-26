//
//  LMMusic.swift
//  LAVESHMUSIC
//
//  Created by Admin on 1/27/19.
//  Copyright © 2019 Tony Wang. All rights reserved.
//

import UIKit

class LMMusic: NSObject {

    var id: String = ""
    var genreId: String = ""
    var musicTitle: String = ""
    var arrVersions = [LMSingleMusic]()
    
    func setValues(withDictionary: Dictionary<String, AnyObject>) {
        id = withDictionary["id"] as! String
        genreId = String.init(format: "%d", (withDictionary["genre_id"]?.uintValue)!)
        musicTitle = withDictionary["music_title"] as! String
        
        if let versionValues = withDictionary["versions"]?.allObjects {
            for dicVersion in versionValues {
                
                let version = LMSingleMusic()
                version.setValues(withDictionary: (dicVersion as? Dictionary<String, AnyObject>)!)
                self.arrVersions.append(version)
            }
        }
    }
}
