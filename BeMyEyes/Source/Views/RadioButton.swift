//
//  RadioButton.swift
//  BeMyEyes
//
//  Created by Tobias DM on 08/10/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

import UIKit

class RadioButton: UIButton {
    
    private let strokeWidth: CGFloat = 3
    
    override init() {
        super.init()
        setup()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func drawRect(rect: CGRect)
    {
        super.drawRect(rect)
        
        let circleRect = CGRectInset(bounds, strokeWidth/2, strokeWidth/2)
        let borderPath = UIBezierPath(ovalInRect: circleRect)
        borderPath.lineWidth = 3
        UIColor.whiteColor().setStroke()
        borderPath.stroke()
        
        if (selected) {
            let dotRect = CGRectInset(circleRect, strokeWidth*1.5, strokeWidth*1.5)
            let borderPath = UIBezierPath(ovalInRect: dotRect)
            UIColor.whiteColor().setFill()
            borderPath.fill()
        }
    }
}

extension RadioButton {
    
    func setup() {
        self.addTarget(self, action: "touchUpInside", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    func touchUpInside() {
//        selected = !selected
//        setNeedsDisplay()
    }
}
