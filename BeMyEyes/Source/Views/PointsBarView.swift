//
//  PointsBarView.swift
//  BeMyEyes
//
//  Created by Tobias DM on 23/09/14.
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
        color = UIColor.redColor()
    }
}


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
    
    override func drawRect(rect: CGRect) {
      
        let frame = bounds
        leftLabel.frame = frame
        rightLabel.frame = frame
        
        draw(rightLabel, rect: rect, mask: rightRect())
        draw(leftLabel, rect: rect, mask: leftRect())
    }
    
    func draw(view: UIView, rect: CGRect, mask: CGRect) {
        
        let context = UIGraphicsGetCurrentContext();
        
        CGContextSaveGState(context)
        let image = CGBitmapContextCreateImage(context)
        let imageMask = CGImageMaskCreate(UInt(mask.width), UInt(mask.height), CGImageGetBitsPerComponent(image), CGImageGetBitsPerPixel(image), CGImageGetBytesPerRow(image), CGImageGetDataProvider(image), CGImageGetDecode(image), CGImageGetShouldInterpolate(image))
        CGContextClipToMask(context, mask, imageMask)
        view.drawRect(rect)
        CGContextRestoreGState(context)
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



@IBDesignable class PointsBarView: UIView {

    @IBInspectable var color: UIColor = UIColor.lightTextColor() {
        didSet {
            setup()
        }
    }
    
    @IBInspectable var text: String = "" {
        didSet {
            label.text = text
        }
    }
    
    @IBInspectable var progress: Float = 0.0 {
        didSet {
            UIView.animateWithDuration(1) {
                self.label.split = self.progress
            }
        }
    }
    
    private lazy var label: SplitMaskedLabel = {
        let label = SplitMaskedLabel()
        label.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        label.text = self.text
        label.textAlignment = .Center
        label.color = self.color
        self.addSubview(label)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
     
        // Since border is inside frame, adjust label to be inside border
        var labelFrame = bounds
        let borderComp = self.layer.borderWidth
        labelFrame.origin.x += borderComp * 0.5
        labelFrame.origin.y += borderComp * 0.5
        labelFrame.size.width -= borderComp * 1.5
        labelFrame.size.height -= borderComp * 1.5
        label.frame = labelFrame
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        
        setup()
    }
}

extension PointsBarView {
    
    func setup() {
        self.layer.borderColor = color.CGColor
        self.layer.borderWidth = 1
        
        backgroundColor = UIColor.clearColor()
        label.textColor = color
    }
}
