//
//  TestCommandTableViewCell.swift
//  testUIprogrammatically
//
//  Created by Ken Moynihan on 23/06/18.
//  Copyright © 2018 Ken Moynihan. All rights reserved.
//

import Foundation
import UIKit

class DummyCommandTableViewCell: UITableViewCell {
    
    let imgUser = UIImageView()
    let commandName_label = UILabel()
    let labMessage = UILabel()
  //  let lastSuccessTime_label = UILabel()
  //  let aButton = UIButton(type: UIButtonType.system)
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        imgUser.backgroundColor = UIColor.blue
        
        imgUser.translatesAutoresizingMaskIntoConstraints = false
        commandName_label.translatesAutoresizingMaskIntoConstraints = false
        labMessage.translatesAutoresizingMaskIntoConstraints = false
  //      lastSuccessTime_label.translatesAutoresizingMaskIntoConstraints = false
  //      aButton.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(imgUser)
        contentView.addSubview(commandName_label)
        contentView.addSubview(labMessage)
  //      contentView.addSubview(lastSuccessTime_label)
  //      contentView.addSubview(aButton)
        
        let viewsDict = [
            "image" : imgUser,
            "commandName" : commandName_label,
            "message" : labMessage,
  //          "lastSuccessTime" : lastSuccessTime_label,
  //          "aButton" : aButton,
            ] as [String : Any]
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[image(10)]", options: [], metrics: nil, views: viewsDict))
      //  contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[lastSuccessTime]-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[commandName]-[message]-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[commandName]-[image(10)]-|", options: [], metrics: nil, views: viewsDict))
      //  contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[username]-[image(10)]-|", options: [], metrics: nil, views: viewsDict))
         contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[message]-|", options: [], metrics: nil, views: viewsDict))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
