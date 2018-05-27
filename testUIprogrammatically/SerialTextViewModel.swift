//
//  SerialTextViewModel.swift
//  testUIprogrammatically
//
//  Created by Ken Moynihan on 27/05/18.
//  Copyright © 2018 Ken Moynihan. All rights reserved.
//

import Foundation

class SerialTextViewModel
{
    var theStrings = [String]()
    
    func updateIncomingData (receivedString : String)
    {
        let receivedStringArr = receivedString.components(separatedBy: "\n")
        for (index, value) in receivedStringArr.enumerated()
        {
            if (index > 0)
            {
                self.theStrings.append(String())
            }
            
            var newString = String();
            if let lastString = self.theStrings.popLast()
            {
                newString = lastString + value;
            }
            else
            {
                newString = value;
            }
            self.theStrings.append(newString)
        }
    }
}
