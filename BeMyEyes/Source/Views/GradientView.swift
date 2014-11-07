//
//  GradientView.swift
//  BeMyEyes
//
//  Created by Tobias DM on 22/09/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

import UIKit

extension UIColor {
    
    class func lightBlueColor() -> UIColor {
        return UIColor(red: 0.24, green: 0.56, blue: 0.71, alpha: 1)
    }
    class func darkBlueColor() -> UIColor {
        return UIColor(red: 0.1, green: 0.22, blue: 0.36, alpha: 1)
    }
}

@IBDesignable class GradientView: UIView {
    
    private lazy var gradientLayer: CAGradientLayer = {
        var layer = CAGradientLayer()
        return layer
    }()
    
    
    var colors: [UIColor] = [.lightBlueColor(), .darkBlueColor()] {
        didSet {
            update()
        }
    }
    
    var startPoint: CGPoint = CGPoint(x: 0, y: 0) {
        didSet {
            update()
        }
    }
    var endPoint: CGPoint = CGPoint(x: 1, y: 1) {
        didSet {
            update()
        }
    }
    
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
        update()
        backgroundColor = .clearColor()
        layer.addSublayer(gradientLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
    
    func update() {
        gradientLayer.colors = colors.map { return $0.CGColor }
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        
        update()
    }
}