//
//  LMSongView.swift
//  LAVESHMUSIC
//
//  Created by Admin on 2/22/19.
//  Copyright © 2019 Tony Wang. All rights reserved.
//

import UIKit

class LMSongView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    @IBOutlet weak var viContents: UIView!
    @IBOutlet weak var imgViThumb: UIImageView!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var timeSlider: UISlider!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSinger: UILabel!
    
}

extension UIView {
    class func fromNib<T: UIView>() -> T {
        return Bundle.main.loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as! T
    }
}
