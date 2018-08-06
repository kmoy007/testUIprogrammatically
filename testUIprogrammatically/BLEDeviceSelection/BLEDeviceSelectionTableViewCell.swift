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
    let connectionState_label = UILabel()
    let info_button = UIButton(type: UIButtonType.infoLight)
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        deviceName_label.translatesAutoresizingMaskIntoConstraints = false
        labMessage.translatesAutoresizingMaskIntoConstraints = false
        lastSuccessTime_label.translatesAutoresizingMaskIntoConstraints = false
        connectionState_label.translatesAutoresizingMaskIntoConstraints = false
        info_button.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(deviceName_label)
        contentView.addSubview(labMessage)
        contentView.addSubview(lastSuccessTime_label)
        contentView.addSubview(connectionState_label)
        contentView.addSubview(info_button)
        
        let viewsDict = [
            "deviceName" : deviceName_label,
            "message" : labMessage,
            "lastSuccessTime" : lastSuccessTime_label,
            "connectionState" : connectionState_label,
            "info_button" :info_button,
            ] as [String : Any]
        
       
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[deviceName]-[lastSuccessTime]-[info_button]-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[deviceName]-[message]-|", options: [], metrics: nil, views: viewsDict))
         contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[info_button]-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[lastSuccessTime]-[connectionState]-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[message]", options: [], metrics: nil, views: viewsDict))
         contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[connectionState]-[info_button]-|", options: [], metrics: nil, views: viewsDict))
        
        setTextColor(color: .black)
    }
    
    func setTextColor(color: UIColor)
    {
        deviceName_label.textColor = color;
        labMessage.textColor = color;
        lastSuccessTime_label.textColor = color;
        connectionState_label.textColor = color;
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
