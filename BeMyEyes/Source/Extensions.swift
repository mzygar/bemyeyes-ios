//
//  Extensions.swift
//  BeMyEyes
//
//  Created by Simon Støvring on 21/01/15.
//  Copyright (c) 2015 Be My Eyes. All rights reserved.
//

import UIKit
import AVFoundation

extension UIDevice {
	
	class func isiPad() -> Bool {
		return UIDevice.currentDevice().userInterfaceIdiom == .Pad
	}
	
}

extension UIImage {
    func scaleToProfileImageSize() -> UIImage {
        
        let profileImageSize = CGSizeMake(200, 200)
        
        let hasAlpha = false
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
        
        let desiredRect = CGRectMake(0, 0, profileImageSize.width, profileImageSize.height)
        let rect = AVMakeRectWithAspectRatioInsideRect(self.size, desiredRect)
        
        UIGraphicsBeginImageContextWithOptions(rect.size, !hasAlpha, scale)
        self.drawInRect(CGRect(origin: CGPointZero, size: rect.size))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
}