//
//  SerialTextTableViewCell.swift
//  testUIprogrammatically
//
//  Created by Ken Moynihan on 23/05/18.
//  Copyright © 2018 Ken Moynihan. All rights reserved.
//

import UIKit

class SerialTextTableViewCell: UITableViewCell {

    let lineNumber = UILabel()
    let lineText = UILabel()
    var wordWrap : Bool = false {
        didSet {
            if wordWrap == true
            {
                lineText.lineBreakMode = NSLineBreakMode.byWordWrapping
                lineNumber.numberOfLines = 0;
            }
            else
            {
                lineText.lineBreakMode = NSLineBreakMode.byTruncatingTail
                lineNumber.numberOfLines = 1;
            }
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        lineNumber.translatesAutoresizingMaskIntoConstraints = false
        lineText.translatesAutoresizingMaskIntoConstraints = false
        
       // labTime.translatesAutoresizingMaskIntoConstraints = false
        
        lineNumber.textAlignment = NSTextAlignment.right
        lineNumber.numberOfLines = 0
        lineText.numberOfLines = 0
        lineText.textAlignment = NSTextAlignment.left
        if wordWrap == true
        {
            lineText.lineBreakMode = NSLineBreakMode.byWordWrapping
            lineNumber.numberOfLines = 0;
        }
        else
        {
            lineText.lineBreakMode = NSLineBreakMode.byTruncatingTail
            lineNumber.numberOfLines = 1;
        }
       // lineText.text
        contentView.addSubview(lineNumber)
        contentView.addSubview(lineText)
        
        let viewsDict = [
            "lineNumber" : lineNumber,
            "lineText" : lineText,
            ] as [String : Any]
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[lineNumber]->=8-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[lineText]->=8-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[lineNumber]-[lineText]-|", options: [], metrics: nil, views: viewsDict))
        
       /* contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[image(10)]", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[labTime]-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[username]-[message]-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[username]-[image(10)]-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[message]-[labTime]-|", options: [], metrics: nil, views: viewsDict)) */
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
       /* if wordWrap == true
        {
            lineText.lineBreakMode = NSLineBreakMode.byWordWrapping
        }
        else
        {
            lineText.lineBreakMode = NSLineBreakMode.byTruncatingTail
        }*/
        //remove data if needed etc..
    }

}
