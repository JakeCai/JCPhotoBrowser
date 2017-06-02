//
//  JCPhotoBrowser.swift
//  JCPhotoBrowser-Swift
//
//  Created by Jake on 01/06/2017.
//  Copyright © 2017 Jake. All rights reserved.
//

import UIKit
import Kingfisher

enum JCPhotoBrowserInteractiveDismissalStyle {
    case scale
    case slide
    case none
}

enum JCPhotoBrowserPageIndicatorStyle {
    case dot
    case text
}

enum JCPhotoBrowserImageLoadingStyle {
    case determinate
    case indeterminate
}

class JCPhotoBrowser: UIViewController , UIScrollViewDelegate{
    var dismissalStyle:JCPhotoBrowserInteractiveDismissalStyle = .scale
    var pageIndicatorStyle:JCPhotoBrowserPageIndicatorStyle = .dot
    var loadingStyle:JCPhotoBrowserImageLoadingStyle = .determinate
    
    let kAnimationDuration:TimeInterval = 0.3
    
    fileprivate var scrollView:UIScrollView!
    
    fileprivate var present:Bool! = false
    fileprivate var startLocation:CGPoint!
    
    fileprivate var photoItems:Array<JCPhotoItem>!
    fileprivate var reuseableItemViews:Set<JCPhotoView>!
    fileprivate var visibleItemViews:Array<JCPhotoView>!
    fileprivate var currentPage:UInt!
    
    fileprivate var pageControl:UIPageControl!
    fileprivate var pageLabel:UILabel!
    
    init(_photoItems:Array<JCPhotoItem> , selectedIndex:UInt) {
        super.init(nibName: nil, bundle: nil)
        
        self.modalPresentationStyle = UIModalPresentationStyle.custom
        self.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        
        currentPage = selectedIndex
        
        reuseableItemViews = Set.init()
        visibleItemViews = Array.init()
        photoItems = Array.init()
        photoItems = _photoItems
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.clear
        
        var rect = self.view.bounds
        rect.origin.x -= 10.0
        rect.size.width += 2 * 10.0
        scrollView = UIScrollView.init(frame: rect)
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        self.view.addSubview(scrollView)
        
        if pageIndicatorStyle == .dot {
            pageControl = UIPageControl.init(frame: CGRect.init(x: 0, y: self.view.bounds.size.height-40, width: self.view.bounds.size.width, height: 20))
            pageControl.numberOfPages = photoItems.count
            pageControl.currentPage = Int(currentPage)
            self.view.addSubview(pageControl)
        }else{
            pageLabel = UILabel.init(frame: CGRect.init(x: 0, y: self.view.bounds.size.height-40, width: self.view.bounds.size.width, height: 20))
            pageLabel.textColor = UIColor.white
            pageLabel.font = UIFont.systemFont(ofSize: 16)
            pageLabel.textAlignment = NSTextAlignment.center
            self.configPageLabelWith(Page: currentPage)
            self.view.addSubview(pageLabel)
        }
        
        let contentSize = CGSize.init(width: rect.size.width * CGFloat(photoItems.count), height: rect.size.height)
        scrollView.contentSize = contentSize
        
        self.addGestureRecognizer()
        
        let contentOffset = CGPoint.init(x: scrollView.frame.size.width * CGFloat(currentPage), y: 0)
        scrollView.setContentOffset(contentOffset, animated: false)
        if contentOffset.x == 0 {
            self.scrollViewDidScroll(scrollView)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let item = photoItems?[Int(currentPage)]
        let photoView = self.photoViewFor(currentPage)
        
        if KingfisherManager.shared.cache.retrieveImageInMemoryCache(forKey: (item?.imageUrl.absoluteString)!) != nil {
            self.config(photoView!, item: item)
        }else{
            photoView?.imageView.image = item?.thumbImage
            photoView?.resizeImageView()
        }
        
        let endRect = photoView?.imageView.frame
        var sourceRect:CGRect!
        let systemVersion = (UIDevice.current.systemVersion as NSString).floatValue
        if systemVersion >= 8.0 && systemVersion < 9.0 {
            sourceRect = item?.sourceView.superview?.convert((item?.sourceView.frame)!, to: photoView)
        }else{
            sourceRect = item?.sourceView.superview?.convert((item?.sourceView.frame)!, to: photoView)
        }
        photoView?.imageView.frame = sourceRect
        
        UIView.animate(withDuration:kAnimationDuration , animations: { 
            photoView?.imageView.frame = endRect!
            self.view.backgroundColor = UIColor.black
        }) { (finish) in
            self.config(photoView!, item: item)
            self.present = true
            UIApplication.shared.setStatusBarHidden(true, with: UIStatusBarAnimation.fade)
        }
    }
    
    @objc public func showFrom (_ viewController:UIViewController){
        viewController.present(self, animated: false, completion: nil)
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        return UIInterfaceOrientationMask.portrait
    }
    
    @objc fileprivate func configPageLabelWith(Page:UInt){
        pageLabel.text = "\(Page+1) / \(photoItems.count)"
    }
    
    @objc fileprivate func photoViewFor(_ page:UInt) -> JCPhotoView? {
        for photoView in visibleItemViews {
            if(photoView.tag == Int(page)){
                return photoView
            }
        }
        return nil
    }
    
    @objc fileprivate func dequeueReuseableItemView() -> JCPhotoView?{
        var photoView:JCPhotoView? = reuseableItemViews.first
        if photoView == nil {
            photoView = JCPhotoView.init(frame: scrollView.frame)
        }else{
            reuseableItemViews.remove(photoView!)
        }
        photoView?.tag = -1
        return photoView
    }
    
    @objc fileprivate func updateReuseableItemView() {
        for photoView in visibleItemViews {
            if photoView.frame.origin.x + photoView.frame.size.width < scrollView.contentOffset.x - scrollView.frame.size.width ||
                photoView.frame.origin.x > scrollView.contentOffset.x + 2 * scrollView.frame.size.width{
                photoView.removeFromSuperview()
                self.config(photoView, item: nil)
                reuseableItemViews.insert(photoView)
                visibleItemViews.removeFirst()
            }
        }
    }
    
    @objc fileprivate func configItemViews() {
        let page = Int(scrollView.contentOffset.x / scrollView.frame.size.width + 0.5)
        var i = page - 1
        while i<=page+1 {
            if i<0 || i>=photoItems.count {
                i += 1
                continue
            }
            var photoView = self.photoViewFor(UInt(i))
            if photoView == nil {
                photoView = self.dequeueReuseableItemView()
                var rect = scrollView.bounds
                rect.origin.x = CGFloat(i) * scrollView.bounds.size.width
                photoView?.frame = rect
                photoView?.tag = i
                scrollView.addSubview(photoView!)
                visibleItemViews.append(photoView!)
            }
            if photoView?.item == nil && present {
                let item = photoItems[i]
                self.config(photoView!, item: item)
            }
            i += 1
        }
        
        if page != Int(currentPage) && present {
            currentPage = UInt(page)
            if pageIndicatorStyle == .dot {
                pageControl.currentPage = page
            }else{
                self.configPageLabelWith(Page: currentPage)
            }
        }
    }
    
    @objc fileprivate func dismiss(_ animated:Bool){
        for photoView in visibleItemViews {
            photoView.cancelCurrentImageLoad()
        }
        let item = photoItems[Int(currentPage)]
        if animated {
            UIView.animate(withDuration: kAnimationDuration, animations: { 
                item.sourceView.alpha = 1
            })
        }else{
            item.sourceView.alpha = 1
        }
        self.dismiss(animated: false, completion: nil)
    }
    
    @objc fileprivate func config(_ photoView:JCPhotoView,item:JCPhotoItem?) {
        photoView.set(_item: item, determinate: (loadingStyle == .determinate))
    }
    
    //MARK: Gesture
    @objc fileprivate func performScaleWith(_ pan:UIPanGestureRecognizer) {
        let point = pan.translation(in: self.view)
        let location = pan.location(in: self.view)
        let velocity = pan.velocity(in: self.view)
        let photoView = self.photoViewFor(currentPage)
        
        switch pan.state {
        case .began:
            startLocation = location
            self.handlePanBegin()
            break
        case .changed:
            var percent = 1 - fabs(point.y) / (self.view.frame.size.height / 2)
            percent = max(percent, 0)
            let s = max(percent, 0.5)
            let translation = CGAffineTransform.init(translationX: point.x / s, y: point.y / s)
            let scale = CGAffineTransform.init(scaleX: s, y: s)
            photoView?.imageView.transform = translation.concatenating(scale)
            self.view.backgroundColor = UIColor.init(white: 0, alpha: percent)
            break
        case .ended: fallthrough
        case .cancelled:
            if fabs(point.y) > 100.0 || fabs(velocity.y) > 500 {
                self.showDismissalAnimation()
            }else{
                self.showCancellationAnimation()
            }
            break
        default:
            break
        }
        
    }
    
    @objc fileprivate func performSlideWith(_ pan:UIPanGestureRecognizer) {
        let point = pan.translation(in: self.view)
        let location = pan.location(in: self.view)
        let velocity = pan.velocity(in: self.view)
        let photoView = self.photoViewFor(currentPage)
        
        switch pan.state {
        case .began:
            startLocation = location
            self.handlePanBegin()
            break
        case .changed:
            let percent = 1 - fabs(point.y) / (self.view.frame.size.height / 2)
            photoView?.imageView.transform = CGAffineTransform.init(translationX: 0, y: point.y)
            self.view.backgroundColor = UIColor.init(white: 0, alpha: percent)
            break
        case .ended: fallthrough
        case .cancelled:
            if fabs(point.y) > 200.0 || fabs(velocity.y) > 500 {
                self.showSlideCompletionAnimationFrom(point: point)
            }else{
                self.showCancellationAnimation()
            }
            break
        default:
            break
        }
        
    }
    
    @objc fileprivate func handlePanBegin() {
        let photoView = self.photoViewFor(currentPage)
        photoView?.cancelCurrentImageLoad()
        let item = photoItems[Int(currentPage)]
        UIApplication.shared.isStatusBarHidden = false
        photoView?.progressLayer.isHidden = true
        item.sourceView.alpha = 0
    }
    
    //MARK: Gesture Recognizer
    @objc fileprivate func addGestureRecognizer() {
        let doubleTap = UITapGestureRecognizer.init(target: self, action:#selector(didDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        self.view.addGestureRecognizer(doubleTap)
        
        let singleTap = UITapGestureRecognizer.init(target: self, action:#selector(didSingleTap(_:)))
        singleTap.numberOfTapsRequired = 1
        singleTap.require(toFail: doubleTap)
        self.view.addGestureRecognizer(singleTap)
        
        let longPress = UILongPressGestureRecognizer.init(target: self, action:#selector(didLongPress(_:)))
        self.view.addGestureRecognizer(longPress)
        
        let pan = UIPanGestureRecognizer.init(target: self, action:#selector(didPan(_:)))
        self.view.addGestureRecognizer(pan)
    }
    
    @objc fileprivate func didSingleTap(_ tap:UITapGestureRecognizer){
        self.showDismissalAnimation()
    }
    
    @objc fileprivate func didDoubleTap(_ tap:UITapGestureRecognizer){
        let photoView = self.photoViewFor(currentPage)
        let item = photoItems[Int(currentPage)]
        if !item.finished {
            return
        }
        if (photoView?.zoomScale)! > CGFloat(1) {
            photoView?.setZoomScale(1, animated: true)
        }else{
            let location = tap.location(in: self.view)
            let maxZoomScale = photoView?.maximumZoomScale
            let width = self.view.bounds.size.width / CGFloat(maxZoomScale!)
            let height = self.view.bounds.size.height / CGFloat(maxZoomScale!)
            photoView?.zoom(to:CGRect.init(x: location.x - width / 2, y: location.y - height / 2, width: width, height: height), animated: true)
        }
    }
    
    @objc fileprivate func didLongPress(_ longPress:UILongPressGestureRecognizer){
        if longPress.state != .began {
            return
        }
        let photoView = self.photoViewFor(currentPage)
        let path = KingfisherManager.shared.cache.cachePath(forKey: (photoView?.item.imageUrl.absoluteString)!)
        let imageData = NSData.init(contentsOfFile: path)
        let vc  = UIActivityViewController.init(activityItems: [imageData!], applicationActivities: nil)
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc fileprivate func didPan(_ pan:UIPanGestureRecognizer){
        let photoView = self.photoViewFor(currentPage)
        if (photoView?.zoomScale)! > CGFloat(1.1) {
            return
        }
        
        switch dismissalStyle {
        case .scale:
            self.performScaleWith(pan)
            break
        case .slide:
            self.performSlideWith(pan)
            break
        default:
            break
        }
    }
    
    
    //MARK: Animation
    @objc fileprivate func showCancellationAnimation() {
        let item = photoItems[Int(currentPage)]
        let photoView = self.photoViewFor(currentPage)
        item.sourceView.alpha = 1
        if !item.finished {
            photoView?.progressLayer.isHidden = false
        }
        UIView.animate(withDuration: kAnimationDuration, animations: {
            photoView?.imageView.transform = CGAffineTransform.identity
            self.view.backgroundColor = UIColor.black
        }) { (finish) in
            UIApplication.shared.setStatusBarHidden(true, with: UIStatusBarAnimation.fade)
            self.config(photoView!, item: item)
        }
    }
    
    @objc fileprivate func showDismissalAnimation() {
        let item = photoItems[Int(currentPage)]
        let photoView = self.photoViewFor(currentPage)
        photoView?.cancelCurrentImageLoad()
        UIApplication.shared.isStatusBarHidden = false
        photoView?.progressLayer.isHidden = true
        item.sourceView.alpha = 0
        var source:CGRect!
        let systemVersion = (UIDevice.current.systemVersion as NSString).floatValue
        if systemVersion >= 8.0 && systemVersion < 9.0 {
            source = item.sourceView.superview?.convert(item.sourceView.frame, to: photoView)
        }else{
            source = item.sourceView.superview?.convert(item.sourceView.frame, to: photoView)
        }
        UIView.animate(withDuration: kAnimationDuration, animations: { 
            photoView?.imageView.frame = source
            self.view.backgroundColor = UIColor.clear
        }) { (finish) in
            self.dismiss(false)
        }
    }
    
    @objc fileprivate func showSlideCompletionAnimationFrom(point:CGPoint) {
        let photoView = self.photoViewFor(currentPage)
        let throwToTop = point.y < 0
        var toTranslationY = CGFloat(0.0)
        if throwToTop {
            toTranslationY = -self.view.frame.size.height
        }else{
            toTranslationY = self.view.frame.size.height
        }
        UIView.animate(withDuration: kAnimationDuration, animations: {
            photoView?.imageView.transform = CGAffineTransform.init(translationX: 0, y: toTranslationY)
            self.view.backgroundColor = UIColor.clear
        }) { (finish) in
            self.dismiss(false)
        }
    }
    
    //MARK: ScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.updateReuseableItemView()
        self.configItemViews()
    }
    
}
