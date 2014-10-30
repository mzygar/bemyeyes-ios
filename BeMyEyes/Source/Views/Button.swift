//
//  Button.swift
//  BeMyEyes
//
//  Created by Tobias DM on 08/10/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

import UIKit


@IBDesignable class Button: UIControl {

    @IBInspectable var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    @IBInspectable var font: UIFont = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline) {
        didSet {
            titleLabel.font = font
        }
    }
    
    var color: UIColor = UIColor.whiteColor()
    var highlightedColor: UIColor = UIColor.lightTextColor()
    var selectedColor: UIColor = UIColor.lightTextColor()
    var disabledColor: UIColor = UIColor.lightTextColor()
    
    override var enabled: Bool {
        didSet {
            updateToState()
        }
    }
    override var highlighted: Bool {
        didSet {
            updateToState()
        }
    }
    
    private lazy var titleLabel: MaskedLabel = {
        let label = MaskedLabel()
        label.font = self.font
        label.textAlignment = .Center
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
        titleLabel.frame = CGRectInset(bounds, 15, 7.5)
    }
    
    override func prepareForInterfaceBuilder() {
        setup()
    }
}

extension Button {
    
    func setup() {
        opaque = false
        backgroundColor = UIColor.clearColor()
        addSubview(titleLabel)
    }
    
    func accessibilityLabel() -> String! {
        return titleLabel.accessibilityLabel
    }
    
    func updateToState() {
        titleLabel.color = colorForState(state)
    }
    
    func colorForState(state: UIControlState) -> UIColor {
        switch (state) {
            case UIControlState.Normal: return color
            case UIControlState.Selected: return selectedColor
            case UIControlState.Highlighted: return highlightedColor
            case UIControlState.Disabled: return disabledColor
            default: return color
        }
    }
}
