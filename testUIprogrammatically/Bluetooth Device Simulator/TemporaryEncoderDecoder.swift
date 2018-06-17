//
//  TemporaryEncoderDecoder.swift
//  testUIprogrammatically
//
//  Created by Ken Moynihan on 6/06/18.
//  Copyright © 2018 Ken Moynihan. All rights reserved.
//

import Foundation

class TwoStringCommaSeparatedEncoderDecoder
{
    func Decode(toDecode: Data) -> (String, String)?
    {
        let theStringToDecode = String(data: toDecode, encoding: .utf8)!
        guard let theIndex = theStringToDecode.index(of: ",") else { return nil; }
        
        let key = theStringToDecode[..<theIndex]
        let message = theStringToDecode[theStringToDecode.index(after:theIndex)...]
        return (String(key), String(message))
    }
    
    func Encode(key: String, message: String) -> Data
    {
        let theString = key + "," + message;
        return theString.data(using: .utf8)!;
    }
}
