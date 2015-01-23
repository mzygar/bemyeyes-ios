//
//  Extensions.swift
//  BeMyEyes
//
//  Created by Simon Støvring on 21/01/15.
//  Copyright (c) 2015 Be My Eyes. All rights reserved.
//

import UIKit

extension UIDevice {
	
	class func isiPad() -> Bool {
		return UIDevice.currentDevice().userInterfaceIdiom == .Pad
	}
	
}