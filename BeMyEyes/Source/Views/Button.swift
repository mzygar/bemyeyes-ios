//
//  Button.swift
//  BeMyEyes
//
//  Created by Tobias DM on 08/10/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

import UIKit


@IBDesignable class MaskedButton: UIControl {

    @IBInspectable var title: String? {
        didSet {
            titleLabel.text = title
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
        label.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
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
        titleLabel.frame = bounds
    }
}

extension MaskedButton {
    
    func setup() {
        addSubview(titleLabel)
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
