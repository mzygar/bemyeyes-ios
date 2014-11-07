//
//  BlueShadowGradientView.swift
//  BeMyEyes
//
//  Created by Tobias Due Munk on 28/10/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

import UIKit

class LightBlueShadowView: GradientView {
    
    override func setup() {
        super.setup()
        
        let color = UIColor.lightBlueColor()
        colors = [color.colorWithAlphaComponent(0),
            color.colorWithAlphaComponent(0.3)]
        startPoint = CGPoint(x: 0, y: 0)
        endPoint = CGPoint(x: 0, y: 1)
    }
}

class LightBlueShadowViewReverse: LightBlueShadowView {
    
    override func setup() {
        super.setup()
    
        startPoint = CGPoint(x: 0, y: 1)
        endPoint = CGPoint(x: 0, y: 0)
    }
}

class DarkBlueShadowView: GradientView {
    
    override func setup() {
        super.setup()
        
        let color = UIColor.darkBlueColor()
        colors = [color.colorWithAlphaComponent(0),
            color.colorWithAlphaComponent(0.3)]
        startPoint = CGPoint(x: 0, y: 0)
        endPoint = CGPoint(x: 0, y: 1)
    }
}

class DarkBlueShadowViewReverse: DarkBlueShadowView {
    
    override func setup() {
        super.setup()
        
        startPoint = CGPoint(x: 0, y: 1)
        endPoint = CGPoint(x: 0, y: 0)
    }
}


class LightBlueOverlayView: GradientView {
    
    override func setup() {
        super.setup()
        
        let color = UIColor.lightBlueColor()
        colors = [color.colorWithAlphaComponent(0),
            color.colorWithAlphaComponent(1)]
        startPoint = CGPoint(x: 0, y: 0)
        endPoint = CGPoint(x: 0, y: 1)
    }
}

class LightBlueOverlayViewReverse: LightBlueOverlayView {
    
    override func setup() {
        super.setup()
        
        startPoint = CGPoint(x: 0, y: 1)
        endPoint = CGPoint(x: 0, y: 0)
    }
}

class DarkBlueOverlayView: GradientView {
    
    override func setup() {
        super.setup()
        
        let color = UIColor.darkBlueColor()
        colors = [color.colorWithAlphaComponent(0),
            color.colorWithAlphaComponent(1)]
        startPoint = CGPoint(x: 0, y: 0)
        endPoint = CGPoint(x: 0, y: 1)
    }
}

class DarkBlueOverlayViewReverse: DarkBlueOverlayView {
    
    override func setup() {
        super.setup()
        
        startPoint = CGPoint(x: 0, y: 1)
        endPoint = CGPoint(x: 0, y: 0)
    }
}
