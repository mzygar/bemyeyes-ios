//
//  InAppTestBadge.swift
//  BeMyEyes
//
//  Created by Tobias Due Munk on 05/11/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

import UIKit

@objc class InAppTestBadge: UIView {
    
    enum Type: String {
        case Beta = "Beta"
        case Alpha = "Alpha"
    }
    
    private var type: Type = .Beta
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFontOfSize(12)
        label.textColor = .whiteColor()
        label.textAlignment = .Center
        label.isAccessibilityElement = false
        return label
    }()
    
    init(type: Type) {
        self.type = type
        super.init(frame: CGRectNull)
        setup()
    }
    
    @objc convenience init(type typeString: String) {
        let type = Type(rawValue: typeString)
        if type == nil {
            assertionFailure("Invalid type " + typeString)
        }
        self.init(type: type!)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        hidden = false
        frame = UIScreen.mainScreen().bounds
        backgroundColor = .clearColor()
        userInteractionEnabled = false
        
        self.addSubview(label)
        update()
    }
    
    func update() {
        label.backgroundColor = { switch self.type {
            case .Alpha: return UIColor(red: 0.62, green: 0.04, blue: 0.05, alpha: 1)
            case .Beta: return UIColor(red: 0, green: 0.41, blue: 0.19, alpha: 1)
            }}()
        label.text = type.rawValue.uppercaseString
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        label.frame = CGRect(x: -48, y: 22, width: 130, height: 18);
        label.transform = CGAffineTransformMakeRotation(CGFloat(-45 * M_PI / 180.0));
    }
    
    func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
}
