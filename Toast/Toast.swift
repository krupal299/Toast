//
//  Toast.swift
//  Toast
//
//  Created by Krupal on 26/12/16.
//  Copyright © 2016 Krupal. All rights reserved.
//

import UIKit


public var padding: CGFloat = 10.0

extension UIColor {
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor{
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
}

public extension UIView {
    
    private static var currentToast = "iCurrentToast"
    private static var toastViewQueue = "toastViewQueue"
    private static var nextToastText = "nextToastText"
    private static var nextToastType = "nextToastType"
    
    public enum ToastType {
        case success
        case warning
        case error
        case normal
    }
    
    func dissmisToast(_ timer: Timer) {
        if let toastView = timer.userInfo as? UIView {
            
            UIView.animate(withDuration: 0.2, delay: 0.0, options: [.curveEaseIn, .beginFromCurrentState], animations: { () -> Void in
                toastView.alpha = 0.0
            }) { (didFinish:Bool) -> Void in
                
                toastView.removeFromSuperview()
                objc_setAssociatedObject(self, &UIView.currentToast, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                
                if let queuedToastView = self.queue.firstObject as? UIView, let _ = objc_getAssociatedObject(queuedToastView, &UIView.nextToastText) as? String , let _ = objc_getAssociatedObject(queuedToastView, &UIView.nextToastType) as? ToastType{
                    
                    objc_setAssociatedObject(queuedToastView, &UIView.nextToastText, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                    objc_setAssociatedObject(queuedToastView, &UIView.nextToastType, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                    
                    self.queue.removeObject(at: 0)
                    self.showToast(toastView: queuedToastView)
                }
            }
        }
    }
    
    private var queue: NSMutableArray {
        get{
            if let queue = objc_getAssociatedObject(self, &UIView.toastViewQueue) as? NSMutableArray {
                return queue
            }else{
                let queue = NSMutableArray()
                objc_setAssociatedObject(self, &UIView.toastViewQueue, queue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return queue
            }
        }
    }
    
    private func showToast(toastView: UIView) {
        
        objc_setAssociatedObject(self, &UIView.currentToast, toastView, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        self.addSubview(toastView)
        
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut, animations: { () -> Void in
            toastView.alpha = 1.0
            
        }) { (finished) -> Void in
            let timer = Timer(timeInterval: 3.0, target: self, selector: #selector(UIView.dissmisToast(_:)), userInfo: toastView, repeats: false)
            RunLoop.main.add(timer, forMode: RunLoopMode.commonModes)
        }
    }
    
    public func createToastView(displayText:String?, type:ToastType) -> UIView{
        
        let displayLabel:UILabel? = {
            let label = UILabel()
            label.text = displayText
            label.numberOfLines = 0
            label.font = UIFont.systemFont(ofSize: 14.0)
            label.textColor = UIColor.white
            return label
        }()
        
        let image: UIImageView? = {
            let imageView = UIImageView()
            if type == ToastType.normal {
                imageView.image = UIImage(named: "ic_info")
            }else if type == ToastType.error {
                imageView.image = UIImage(named: "ic_error")
            }else if type == ToastType.success {
                imageView.image = UIImage(named: "ic_success")
            }else if type == ToastType.warning {
                imageView.image = UIImage(named: "ic_warning")
            }
            imageView.contentMode = .scaleAspectFit
            imageView.layer.masksToBounds = true
//            imageView.image = imageView.image!.withRenderingMode(.alwaysTemplate)
            imageView.image = imageView.image?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            imageView.tintColor = UIColor.white
            return imageView
        }()
        
        
        let toastView: UIView? = {
            let view = UIView()
            if type == ToastType.normal {
                view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
            }else if type == ToastType.error {
                view.backgroundColor = UIColor.rgb(red: 255, green: 26, blue: 26)
            }else if type == ToastType.success {
                view.backgroundColor = UIColor.rgb(red: 0, green: 179, blue: 0)
            }else if type == ToastType.warning {
                view.backgroundColor = UIColor.rgb(red: 179, green: 179, blue: 0)
            }
            view.layer.cornerRadius = 10
            
            return view
        }()
        
        let toastViewMaxHeight: CGFloat = 0.8
        let toastViewMaxWidth: CGFloat = 0.8
        
        image?.frame = CGRect(x: padding, y: padding, width: 20, height: 20)
        
        var imageRect = CGRect.zero
        if let imageView = image {
            imageRect.origin.x = padding
            imageRect.origin.y = padding
            imageRect.size.width = imageView.bounds.size.width
            imageRect.size.height = imageView.bounds.size.height
        }
        
        let maxDisplayTextSize = CGSize(width: (self.bounds.size.width * toastViewMaxWidth) - imageRect.size.width, height: self.bounds.size.width * toastViewMaxHeight)
        let sizeDisplayText = displayLabel?.sizeThatFits(maxDisplayTextSize)
        if let displayTextSize = sizeDisplayText {
            displayLabel?.frame = CGRect(x: 0.0, y: 0.0, width: min(displayTextSize.width, maxDisplayTextSize.width), height: min(displayTextSize.height, maxDisplayTextSize.height))
        }
        
        var displayTextRect = CGRect.zero
        if let displayLabel = displayLabel {
            displayTextRect.origin.x = imageRect.origin.x + imageRect.size.width + padding
            displayTextRect.origin.y = padding
            displayTextRect.size.width = displayLabel.bounds.size.width
            displayTextRect.size.height = displayLabel.bounds.size.height
        }
        
        let toastWidth = max((imageRect.size.width + (padding * 2.0)),(displayTextRect.origin.x + displayTextRect.size.width + padding))
        let toastHeight = max((displayTextRect.origin.y + displayTextRect.size.height + padding), (imageRect.size.height + (padding * 2.0)))
        
        
        toastView?.frame = CGRect(x: 0.0, y: 0.0, width: toastWidth, height: toastHeight)
        
        image?.frame = CGRect(x: padding, y: ((toastHeight / 2.0) - (imageRect.size.height / 2.0)), width: imageRect.size.width, height: imageRect.size.height)
        
        if let  displayLabel = displayLabel {
            displayLabel.frame = displayTextRect
            toastView?.addSubview(displayLabel)
        }
        
        if let  imageView = image {
            //            if type != ToastType.normal {
            toastView?.addSubview(imageView)
            //            }
            //            else{
            //                imageRect.size.width = 0
            //                imageRect.size.height = 0
            //            }
        }
        
        
        toastView?.center = CGPoint(x: self.bounds.size.width / 2.0, y: self.bounds.size.height - ((toastView?.bounds.size.height)! / 2.0) - 50)
        
        return toastView!
        
    }
    
    
    public func showToastView(displayText:String?, type:ToastType) {
        let toastView = self.createToastView(displayText: displayText, type: type)
        
        if let _ = objc_getAssociatedObject(self, &UIView.currentToast) as? UIView {
            
            objc_setAssociatedObject(toastView, &UIView.nextToastText, displayText, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            objc_setAssociatedObject(toastView, &UIView.nextToastType, type, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            self.queue.add(toastView)
            
        }else{
            
            showToast(toastView: toastView)
            
        }   
    }
}
