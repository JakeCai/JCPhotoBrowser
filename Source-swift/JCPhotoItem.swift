//
//  JCPhotoItem.swift
//  JCPhotoBrowser-Swift
//
//  Created by Jake on 31/05/2017.
//  Copyright © 2017 Jake. All rights reserved.
//

import UIKit


class JCPhotoItem: NSObject {
    fileprivate(set) var sourceView:UIView!
    fileprivate(set) var thumbImage:UIImage!
    fileprivate(set) var image:UIImage?
    fileprivate(set) var imageUrl:URL?
    var finished = false
    

    @objc public init(_ source:UIView?,_ thumb:UIImage?,_ url:URL?) {
        super.init()
        self.sourceView = source
        self.thumbImage = thumb
        self.imageUrl = url
    }
    
    @objc public convenience init(_ source:UIImageView?,_ url:URL?) {
        self.init(source,source?.image,url)
    }
    
    @objc public init(_ source:UIImageView?,_image:UIImage?) {
        super.init()
        self.sourceView = source
        self.thumbImage =  _image
        self.imageUrl = nil
        self.image = _image
    }
    
}
