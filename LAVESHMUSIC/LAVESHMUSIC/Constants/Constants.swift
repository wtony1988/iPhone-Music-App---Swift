//
//  Constants.swift
//
//

import UIKit

let APP_NAME = "LAVESHMUSIC"
let SCREEN_SIZE = UIScreen.main.bounds
let SCREEN_WIDTH = SCREEN_SIZE.width
let SCREEN_HEIGHT = SCREEN_SIZE.height

let SELECTED_NONE_STRING = ""
let SELECTED_NONE = -1
let SELECTED_NONE_ID = "-1"

struct Constants {
    struct API {
        static let BaseURL = "https://jsonplaceholder.typicode.com"
    }
    
    struct Errors {
        
    }
    
    struct MailGun {
        static let domain_name = "sandbox0b1ac20421a9495c8f80a55a6df715c4.mailgun.org"
        static let apiKey = "fa75221b81adbe18e4a3a825c7f46088-acb0b40c-4baee674"
    }
    
    struct Keys {
        static let twitterConsumer = "KlZpfN0QPqvxEJQKgcqv6c7kc"
        static let twitterConsumerSecret = "BurExMlhdxnpFsjsU8kXhAem4BJJLKECSzHTggVIrRwiwRvTgm"
    }
    
    static let bottomMarginFirstResponder: CGFloat = 20.0
}
