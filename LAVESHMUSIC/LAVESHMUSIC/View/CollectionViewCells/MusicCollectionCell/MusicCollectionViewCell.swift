//
//  MusicCollectionViewCell.swift
//  LAVESHMUSIC
//
//  Created by Admin on 1/8/19.
//  Copyright © 2019 Tony Wang. All rights reserved.
//

import UIKit

class MusicCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imgViMusicThumb: UIImageView!
    @IBOutlet weak var lblMusicTitle: UILabel!
    @IBOutlet weak var imgViSinger: UIImageView!
    @IBOutlet weak var lblSinger: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
