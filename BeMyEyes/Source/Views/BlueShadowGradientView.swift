//
//  BlueShadowGradientView.swift
//  BeMyEyes
//
//  Created by Tobias Due Munk on 28/10/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

import UIKit

class BlueShadowGradientView: GradientView {

    override func setup() {
        super.setup()
        
        let color = UIColor(red: 0.1, green: 0.22, blue: 0.36, alpha: 1)
        colors = [color.colorWithAlphaComponent(0),
                    color.colorWithAlphaComponent(0.3)]
        startPoint = CGPoint(x: 0, y: 0)
        endPoint = CGPoint(x: 0, y: 1)
    }

}
