//
//  SplitMaskedLabel.swift
//  BeMyEyes
//
//  Created by Tobias DM on 08/10/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

import UIKit

@IBDesignable class SplitMaskedLabel: UILabel {
    
    @IBInspectable var split: Float = 0.0 {
        didSet {
            split = min(max(split, 0), 1)
        }
    }
    
    private lazy var leftLabel: MaskedLabel = {
        let label = MaskedLabel()
        return label
    }()
    
    private lazy var rightLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    override var text: String? {
        didSet {
            leftLabel.text = text
            rightLabel.text = text
        }
    }
    
    override var textAlignment: NSTextAlignment {
        didSet {
            leftLabel.textAlignment = textAlignment
            rightLabel.textAlignment = textAlignment
        }
    }
    
    @IBInspectable var color: UIColor = UIColor.whiteColor() {
        didSet {
            leftLabel.color = color
            rightLabel.textColor = color
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func drawRect(rect: CGRect) {
        
        let frame = bounds
        leftLabel.frame = frame
        rightLabel.frame = frame
        
        // Draw line border for right part
        draw(rect, masked: rightRect()) {
            let borderPath = UIBezierPath(rect: rect)
            borderPath.lineWidth = 2
            self.color.setStroke()
            borderPath.stroke()
        }
        draw(rightLabel, rect: rect, mask: rightRect())
        draw(leftLabel, rect: rect, mask: leftRect())
    }
    
    func draw(view: UIView, rect: CGRect, mask: CGRect) {
        
        draw(rect, masked: mask) {
            view.drawRect(rect)
        }
    }
    func draw(rect: CGRect, masked mask: CGRect, content: () -> ()) {
        let context = UIGraphicsGetCurrentContext();
        
        CGContextSaveGState(context)
        let image = CGBitmapContextCreateImage(context)
        let imageMask = CGImageMaskCreate(UInt(mask.width), UInt(mask.height), CGImageGetBitsPerComponent(image), CGImageGetBitsPerPixel(image), CGImageGetBytesPerRow(image), CGImageGetDataProvider(image), CGImageGetDecode(image), CGImageGetShouldInterpolate(image))
        CGContextClipToMask(context, mask, imageMask)
        content()
        CGContextRestoreGState(context)
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        
        text = "Testing"
        backgroundColor = UIColor.redColor()
    }
}

extension SplitMaskedLabel {
    
    func leftRect() -> CGRect {
        var rect = self.frame
        rect.size.width *= CGFloat(self.split)
        return rect
    }
    func rightRect() -> CGRect {
        let offset = leftRect().width
        let width = self.frame.width - offset
        var rect = self.frame
        rect.origin.x = offset
        rect.size.width = width
        return rect
    }
}
