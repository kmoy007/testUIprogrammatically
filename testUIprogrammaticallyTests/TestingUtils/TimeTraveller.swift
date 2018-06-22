//
//  TimeNow.swift
//  testUIprogrammatically
//
//  Created by Ken Moynihan on 20/06/18.
//  Copyright © 2018 Ken Moynihan. All rights reserved.
//

import Foundation

class TimeTraveller
{
    private var date = Date()
    
    func travel (by timeInterval: TimeInterval)
    {
        date = date.addingTimeInterval(timeInterval)
    }
    
    func generateDate() -> Date
    {
        return date
    }
}
