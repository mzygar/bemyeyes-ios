//
//  GradientView.swift
//  BeMyEyes
//
//  Created by Tobias DM on 22/09/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

import UIKit

@IBDesignable class GradientView: UIView {
    
    private lazy var gradientLayer: CAGradientLayer = {
        var layer = CAGradientLayer()
        return layer
    }()
    
    
    var colors: [UIColor] = [UIColor(red: 0.24, green: 0.56, blue: 0.71, alpha: 1), UIColor(red: 0.1, green: 0.22, blue: 0.36, alpha: 1)] {
        didSet {
            update()
        }
    }
    
    init(colors: UIColor...) {
        self.colors = colors
        
        super.init(frame: CGRectZero)
        
        self.layer.addSublayer(gradientLayer)
        update()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        
        self.layer.addSublayer(gradientLayer)
        update()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        gradientLayer.frame = bounds
    }
    
    func update() {
        gradientLayer.colors = colors.map { return $0.CGColor }
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        
        update()
    }
}