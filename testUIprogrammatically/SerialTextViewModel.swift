//
//  SerialTextViewModel.swift
//  testUIprogrammatically
//
//  Created by Ken Moynihan on 27/05/18.
//  Copyright © 2018 Ken Moynihan. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa


class SerialTextViewModel : ReceiveMessageDelegate
{
    weak var serialTextView : SerialTextViewController? // for now - this needs to be replaced with RxSwift Observer pattern
    
    var downStream : SendMessageFormattingBuffer? {
        didSet {
            downStream?.messageDestination = self //autowire - cant be ! because tests reset to nil
        }
    }
    
    var theStrings = [String]()
   
    func sendStringFromUser(send : String)
    {
        var newString : String = send
        if newString.count != newString.utf8.count
        {
            let errorMessageString = String(format: "Entered String is not UTF8 (character count mismatch UTF8:%d String %d)",newString.utf8.count, newString.count)
            
            serialTextView?.userAlert(title: "UTF8 only", alertMessage: errorMessageString)
            newString = String(newString.utf8) //convert to UTF8
            //error
        }
        
        if downStream != nil
        {
            downStream?.formatAndSendData(stringToSend: send.data(using: .utf8)!);
    //        serialTextView?.bleDeviceInterface.waitForAResponse(timeToWait: 5)
        }
        
        //self.sendString(sendUTF8String: sendUTF8String)
        //serialTextView?.multiLineTextView.text.append(sendUTF8String) //echo string back - test only
        
    }
    
    func receiveStringFromUART(receive: Data)
    {
        self.addIncomingString_WithCorrectFormatting(receivedString: String(data: receive, encoding: .utf8)!)
        serialTextView?.textViewSetupSizeForWordWrapping() //recalculate widths etc..
    }
    
    /*func pumpForSomething()
    {
        let textGenerator = Simulator_UARTTextGenerator();
        textGenerator.delegate = self;
        textGenerator.pumpString();
    }
    */
    
    func addIncomingString_WithCorrectFormatting (receivedString : String)
    {
        serialTextView?.multiLineTextView.text.append(receivedString)
        
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
