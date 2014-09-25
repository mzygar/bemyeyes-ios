//
//  PointsTableViewCell.swift
//  BeMyEyes
//
//  Created by Tobias DM on 23/09/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

import UIKit

@objc class PointsTableViewCell: UITableViewCell {

    @IBOutlet var descriptionLabel: UILabel?
    @IBOutlet var dateLabel: UILabel?
    @IBOutlet var pointsLabel: UILabel?
    var pointsDescription: String = "" {
        didSet {
            if let descriptionLabel = descriptionLabel {
                descriptionLabel.text = pointsDescription
            }
        }
    }
    var date: NSDate? {
        didSet {
            if let dateLabel = dateLabel {
                if let date = date {
                    dateLabel.text = self.dateFormatter.stringFromDate(date)
                } else {
                    dateLabel.text = ""
                }
            }
        }
    }
    
    lazy var dateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .MediumStyle
        return formatter
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
