//
//  LMSingleMusic.swift
//  LAVESHMUSIC
//
//  Created by Admin on 1/27/19.
//  Copyright © 2019 Tony Wang. All rights reserved.
//

import UIKit

class LMSingleMusic: NSObject {

    var id: String = ""
    var singer: String = ""
    var title: String = ""
    var fileURL = URL(string: "")
    var thumbImageURL = URL(string: "")
    var versionType: String = ""
    
    func setValues(withDictionary: Dictionary<String, AnyObject>) {
        id = withDictionary["id"] as! String
        singer = withDictionary["singer"] as! String
        title = withDictionary["title"] as! String
        
        if (withDictionary["version_type"] != nil) {
            versionType = withDictionary["version_type"] as! String
        }
        
        fileURL = URL(string: withDictionary["file_url"] as! String)
        thumbImageURL = URL(string: withDictionary["thumb_image"] as! String)
    }
}
