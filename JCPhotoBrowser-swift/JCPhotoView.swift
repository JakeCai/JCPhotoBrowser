//
//  JCPhotoView.swift
//  JCPhotoBrowser-Swift
//
//  Created by Jake on 01/06/2017.
//  Copyright © 2017 Jake. All rights reserved.
//

import UIKit
import Kingfisher

class JCPhotoView: UIScrollView , UIScrollViewDelegate{
    let kJCPhotoViewMaxScale = 3.0
    let kJCPhotoViewPadding = 10.0
    fileprivate(set) var imageView:UIImageView!
    fileprivate(set) var progressLayer:JCProgressLayer!
    fileprivate(set) var item:JCPhotoItem!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.bouncesZoom = true
        self.maximumZoomScale = CGFloat(kJCPhotoViewMaxScale)
        self.isMultipleTouchEnabled = true
        self.showsVerticalScrollIndicator = true
        self.showsHorizontalScrollIndicator = true
        self.delegate = self
        
        imageView = UIImageView.init()
        imageView.backgroundColor = UIColor.darkGray
        imageView.contentMode = UIViewContentMode.scaleAspectFill
        imageView.clipsToBounds = true
        self.addSubview(imageView!)
        self.resizeImageView()
        
        progressLayer = JCProgressLayer.init(Frame: CGRect.init(x: 0, y: 0, width: 40, height: 40))
        progressLayer.position = CGPoint.init(x: frame.size.width/2, y: frame.size.height/2)
        progressLayer.isHidden = true
        self.layer.addSublayer(progressLayer!)
    }
    
    public func set(_item:JCPhotoItem?, determinate:Bool){
        item = _item
        imageView?.kf.cancelDownloadTask()
        if (_item == nil) {
            progressLayer.stopPin()
            progressLayer.isHidden = true
            imageView.image = nil
        }else{
            if (item.image != nil){
                imageView.image = item.image
                item.finished = true
                progressLayer.stopPin()
                progressLayer.isHidden = true
                self.resizeImageView()
                return
            }
            var progressBlock:DownloadProgressBlock? = nil
            if determinate {
                progressBlock = { [weak self](_ receivedSize: Int64, _ totalSize: Int64)-> Void in
                    let weakSelf = self
                    let progress = CGFloat(receivedSize) / CGFloat(totalSize)
                    weakSelf?.progressLayer.isHidden = false
                    weakSelf?.progressLayer.progress = max(progress, 0.01)
                }
            }else{
                progressLayer.startPin()
            }
            progressLayer.isHidden = false
            
            imageView.image = item.thumbImage
            imageView.kf.setImage(with: item.imageUrl, placeholder: item.thumbImage,
                                  options: [KingfisherOptionsInfoItem.backgroundDecode],
                                  progressBlock: progressBlock)
            { [weak self] (image, error, cacheType, imageURL) in
                let weakSelf = self
                if(error == nil){
                    weakSelf?.resizeImageView()
                }
                weakSelf?.progressLayer.stopPin()
                weakSelf?.progressLayer.isHidden = true
                weakSelf?.item.finished = true
            }
        }
        self.resizeImageView()
    }
    
    public func resizeImageView(){
        if imageView.image != nil {
            let imageSize:CGSize! = imageView.image?.size
            let width = imageView.frame.size.width
            let height = width * (imageSize.height / imageSize.width)
            let rect = CGRect.init(x: 0, y: 0, width: width, height: height)
            imageView.frame = rect
            
            if height <= self.bounds.size.height {
                imageView.center = CGPoint.init(x: self.bounds.size.width/2, y: self.bounds.size.height/2)
            }else{
                imageView.center = CGPoint.init(x: self.bounds.size.width/2, y: height/2)
            }
            
            if width / height > 2 {
                self.maximumZoomScale = self.bounds.size.height / height
            }
        }else{
            let width = self.frame.size.width - 2 * CGFloat(kJCPhotoViewPadding)
            imageView.frame = CGRect.init(x: 0, y: 0, width: width, height: width * 2.0 / 3)
            imageView.center = CGPoint.init(x: self.bounds.size.width/2, y: self.bounds.size.height/2)
        }
        self.contentSize = imageView.frame.size
    }
    
    public func cancelCurrentImageLoad(){
        imageView.kf.cancelDownloadTask()
        progressLayer.stopPin()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width) ?
        (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0
        
        let offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height) ?
        (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0
        
        imageView.center = CGPoint.init(x: scrollView.contentSize.width * 0.5 + offsetX, y: scrollView.contentSize.height * 0.5 + offsetY)
        
    }
}
