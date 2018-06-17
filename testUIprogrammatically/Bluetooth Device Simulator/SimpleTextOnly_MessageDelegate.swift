//
//  SimpleTextOnlySimulator_UART.swift
//  testUIprogrammatically
//
//  Created by Ken Moynihan on 3/06/18.
//  Copyright © 2018 Ken Moynihan. All rights reserved.
//

import Foundation

protocol DummyTextGenerator
{
    var messageSink: SendMessageFormattingBuffer? {get set}
    func pumpString()
}

//CURRENTLY CONVERTING THIS INTO A DELEGATE SO THAT WE CAN THEN MAKE THE DEVICE SIMULATOR AS A MORE COMPLEX VERSION OF THIS
class SimpleTextOnly_MessageDelegate :ReceiveMessageDelegate, DummyTextGenerator
{
    var messageSink: SendMessageFormattingBuffer?
    
    func pumpString()
    {
        let multiLineString = """
            To be, or not to be - that is the question;
            Whether 'tis nobler in the mind to suffer
            The slings and arrows of outrageous fortune,
            Or to take arms against a sea of troubles,
            """
        messageSink?.formatAndSendData(stringToSend : multiLineString.data(using: .utf8)!)
    }
    
    func receiveStringFromUART(receive: Data) //from user
    {
        if let theString = String(data: receive, encoding: .utf8)
        {
            if theString.hasPrefix("testcommand ")
            {
                let returnString = theString.dropFirst(String("testcommand ").count)
                messageSink?.formatAndSendData(stringToSend: String("sure thing, I will do: " + returnString + "\n").data(using: .utf8)!)
            }
            else
            {
                messageSink?.formatAndSendData(stringToSend: String("unrecognized command" + "\n").data(using: .utf8)!)
            }
        }
        else
        {
            assert(false);  //not utf8?
        }
    }
}
