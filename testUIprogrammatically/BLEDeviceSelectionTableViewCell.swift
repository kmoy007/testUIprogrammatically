//
//  BLEDeviceSelectionTableViewCell.swift
//  testUIprogrammatically
//
//  Created by Ken Moynihan on 26/07/18.
//  Copyright © 2018 Ken Moynihan. All rights reserved.
//

import Foundation
import UIKit

class BLEDeviceSelectionTableViewCell: UITableViewCell {
    
    let deviceName_label = UILabel()
    let labMessage = UILabel()
    let lastSuccessTime_label = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        deviceName_label.translatesAutoresizingMaskIntoConstraints = false
        labMessage.translatesAutoresizingMaskIntoConstraints = false
        lastSuccessTime_label.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(deviceName_label)
        contentView.addSubview(labMessage)
        contentView.addSubview(lastSuccessTime_label)
        
        let viewsDict = [
            "deviceName" : deviceName_label,
            "message" : labMessage,
            "lastSuccessTime" : lastSuccessTime_label,
            ] as [String : Any]
        
       
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[deviceName]-[lastSuccessTime]-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[deviceName]-[message]-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[message]-|", options: [], metrics: nil, views: viewsDict))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
