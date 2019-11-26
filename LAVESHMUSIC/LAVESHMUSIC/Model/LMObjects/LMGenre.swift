//
//  LMGenre.swift
//  LAVESHMUSIC
//
//  Created by Admin on 1/26/19.
//  Copyright © 2019 Tony Wang. All rights reserved.
//

import UIKit

class LMGenre: NSObject {

    var id: String = ""
    var title: String = ""
    var thumbImageURL = URL(string: "")
    
    func setValues(withDictionary: Dictionary<String, AnyObject>) {
        id = String.init(format: "%d", (withDictionary["id"]?.uintValue)!)
        title = withDictionary["title"] as! String
        thumbImageURL = URL(string: withDictionary["thumb_image"] as! String)
    }
}
