//
//  ProfileImageView.swift
//  BeMyEyes
//
//  Created by Tobias Due Munk on 29/10/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

import UIKit

class ProfileImageView: UIImageView {
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        clipsToBounds = true
        layer.borderColor = UIColor.whiteColor().CGColor
        layer.borderWidth = 2
        contentMode = .ScaleAspectFill
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = max(bounds.size.height, bounds.size.width) / 2
    }
}
