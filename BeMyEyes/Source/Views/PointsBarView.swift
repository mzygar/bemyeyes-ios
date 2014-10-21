//
//  PointsBarView.swift
//  BeMyEyes
//
//  Created by Tobias DM on 23/09/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

import UIKit

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
        let label = SplitMaskedLabel(frame: CGRectZero)
        label.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        label.text = self.text
        label.textAlignment = .Center
        label.color = self.color
        self.addSubview(label)
        return label
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
     
        label.frame = bounds
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        
        setup()
    }
}

extension PointsBarView {
    
    func setup() {
        backgroundColor = UIColor.clearColor()
        label.textColor = color
    }
}
