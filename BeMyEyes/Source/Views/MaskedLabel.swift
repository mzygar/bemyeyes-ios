//
//  MaskedLabel.swift
//  BeMyEyes
//
//  Created by Tobias DM on 08/10/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

import UIKit

@IBDesignable class MaskedLabel: UILabel {
    
    @IBInspectable var color: UIColor = UIColor.whiteColor() {
        didSet {
            setup()
        }
    }
    @IBInspectable var textInset: UIEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    
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
    
    func setup() {
        opaque = false
        backgroundColor = UIColor.clearColor()
        textColor = UIColor.whiteColor()
        setNeedsDisplay()
    }
    
    override func drawRect(rect: CGRect) {
        super.drawTextInRect(UIEdgeInsetsInsetRect(rect, textInset))
        
        let context = UIGraphicsGetCurrentContext();
        CGContextConcatCTM(context, CGAffineTransformMake(1, 0, 0, -1, 0, CGRectGetHeight(rect)))
        
        // create a mask from the normally rendered text
        let image = CGBitmapContextCreateImage(context)
        let mask = CGImageMaskCreate(CGImageGetWidth(image), CGImageGetHeight(image), CGImageGetBitsPerComponent(image), CGImageGetBitsPerPixel(image), CGImageGetBytesPerRow(image), CGImageGetDataProvider(image), CGImageGetDecode(image), CGImageGetShouldInterpolate(image))
        
        // wipe the slate clean
        CGContextClearRect(context, rect)
        
        CGContextSaveGState(context)
        CGContextClipToMask(context, rect, mask)
        
        if self.layer.cornerRadius != 0.0 {
            CGContextAddPath(context, CGPathCreateWithRoundedRect(rect, self.layer.cornerRadius, self.layer.cornerRadius, nil))
            CGContextClip(context)
        }
        
        color.set()
        CGContextFillRect(context, rect)
        
        CGContextRestoreGState(context)
    }
    
    override func intrinsicContentSize() -> CGSize {
        var size = super.intrinsicContentSize()
        size.width += self.textInset.left + self.textInset.right;
        size.height += self.textInset.top + self.textInset.bottom;
        return size
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        
        text = "Masked label"
    }
}
