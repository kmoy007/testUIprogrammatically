//
//  BasicCommandProcessor.swift
//  testUIprogrammatically
//
//  Created by Ken Moynihan on 7/06/18.
//  Copyright © 2018 Ken Moynihan. All rights reserved.
//

import Foundation

class BasicCommandProcessor
{
    var responseDelegate : ReceiveMessageDelegate?
    var commands = [String : (String)->Bool]()
    var coder = TwoStringCommaSeparatedEncoderDecoder()
    
    func ProcessCommand(incomingMessage : Data) -> Bool
    {
        guard let (key, message) = coder.Decode(toDecode: incomingMessage) else
        { responseDelegate?.receiveStringFromUART(receive: "Couldnt decode command".data(using: .utf8)!); return false}
        
        var success = false
        if let theFunction = commands[key]
        {
            success = theFunction(message)
        }
        else
        {
            responseDelegate?.receiveStringFromUART(receive: String("UnknownCommand["+key+"]").data(using: .utf8)!)
        }
        return success
     
    }
    
}
