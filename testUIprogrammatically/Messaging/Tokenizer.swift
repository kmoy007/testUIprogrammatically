//
//  tokenizer.swift
//  testUIprogrammatically
//
//  Created by Ken Moynihan on 22/06/18.
//  Copyright © 2018 Ken Moynihan. All rights reserved.
//

import Foundation

class Tokenizer
{
    static func getNextStringTokenizedBynewline(dataIn : inout Data) -> Data?
    {
        var returnData : Data? = nil;
        // let char = Character("\n")
        
        if let theIndex = dataIn.index(of: "\n".utf8.map{ UInt8($0) }[0])
        {
            returnData = dataIn.prefix(through: theIndex)
            dataIn.removeSubrange(...theIndex)
        }
        return returnData;
    }

}

