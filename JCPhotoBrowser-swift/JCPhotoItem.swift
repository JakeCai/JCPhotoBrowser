//
//  JCPhotoItem.swift
//  JCPhotoBrowser-Swift
//
//  Created by Jake on 31/05/2017.
//  Copyright © 2017 Jake. All rights reserved.
//

import UIKit


class JCPhotoItem: NSObject {
    var sourceView:UIView!
    var thumbImage:UIImage!
    var image:UIImage!
    var imageUrl:URL!
    var finished:Bool! = false
    

    public init(source:UIView?, thumb:UIImage?, url:URL?) {
        super.init()
        self.sourceView = source
        self.thumbImage = thumb
        self.imageUrl = url
    }
    
    public convenience init(source:UIImageView?, url:URL?) {
        self.init(source: source, thumb: source?.image, url: url)
    }
    
    public init(source:UIImageView?, _image:UIImage?) {
        super.init()
        self.sourceView = source
        self.thumbImage =  image
        self.imageUrl = nil
        self.image = _image
    }
    
}
