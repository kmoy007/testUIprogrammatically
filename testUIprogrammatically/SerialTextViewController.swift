//
//  SerialTextTableViewController.swift
//  testUIprogrammatically
//
//  Created by Ken Moynihan on 23/05/18.
//  Copyright © 2018 Ken Moynihan. All rights reserved.
//

import UIKit

class SerialTextViewController: UIViewController, UITextFieldDelegate
{
    let viewModel = SerialTextViewModel()
    
    var multiLineTextView : UITextView = UITextView()

    var scrollView : UIScrollView = UIScrollView()
    var sendTextField : UITextField = UITextField()
    var wordWrapSwitch : UISwitch = UISwitch()
    var sendTextLabel : UILabel = UILabel()
    
    var wordWrap: Bool  = true {
        didSet {
            textViewSetupSizeForWordWrapping()
            }
    }
    var scrollPaused: Bool = false;
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white;
        viewModel.serialTextView = self;
    
        scrollViewSetup()
        textViewSetup()
        wordWrapSwitchSetup()
        sendTextSetup()
        
        setConstraints()
    }
    
    func setConstraints()
    {
        
        multiLineTextView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        wordWrapSwitch.translatesAutoresizingMaskIntoConstraints = false
        sendTextField.translatesAutoresizingMaskIntoConstraints = false
        sendTextLabel.translatesAutoresizingMaskIntoConstraints = false
        
        multiLineTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        multiLineTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        multiLineTextView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        multiLineTextView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        
        wordWrapSwitch.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        wordWrapSwitch.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
       // wordWrapSwitch.widthAnchor.constraint(equalToConstant: 50).isActive = true
        //wordWrapSwitch.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: wordWrapSwitch.bottomAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: sendTextField.topAnchor, constant : 8).isActive = true
        
        let maxSize = CGSize(width: 200, height: 30)
        let size = sendTextLabel.sizeThatFits(maxSize)
        
        sendTextLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant : 8).isActive = true;
        sendTextLabel.widthAnchor.constraint(equalToConstant: size.width).isActive = true;
        sendTextLabel.bottomAnchor.constraint(equalTo: sendTextField.bottomAnchor).isActive = true;
        sendTextLabel.topAnchor.constraint(equalTo: sendTextField.topAnchor).isActive = true;
        
        
        sendTextField.leadingAnchor.constraint(equalTo: sendTextLabel.trailingAnchor, constant : 8).isActive = true;
        sendTextField.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant : -8).isActive = true;
        sendTextField.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant : -8).isActive = true;
        /*
        
        bookTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        bookTextView.bottomAnchor.constraint(equalTo: view.bottomAnchor,constant: -20).isActive = true
        
        bookTextView.heightAnchor.constraint(equalTo: view.heightAnchor,multiplier: 0.65).isActive = true*/
    }
    
    func userAlert(title : String, alertMessage : String)
    {
        let alertController = UIAlertController(title: title, message: alertMessage, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        self.present(alertController, animated:true, completion:nil)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator)
    {
        //call super
        super.viewWillTransition(to: size, with: coordinator)
        //code here is before transition.
        
        //this will be called happen during transition (so UIScreen.main.bounds.size is correct for new orientation
        coordinator.animateAlongsideTransition(in: self.view, animation: (
            { context in
            self.view.frame.size = size;
            self.scrollView.frame.size = size;
            self.wordWrapSwitch.frame.size = size;
            self.textViewSetupSizeForWordWrapping()
        }), completion: nil)
    }
        
    func wordWrapSwitchSetup()
    {
       // wordWrapSwitch=UISwitch()
        wordWrapSwitch.addTarget(self, action: #selector(SerialTextViewController.switchStateDidChange(_:)), for: .valueChanged)
        wordWrapSwitch.setOn(wordWrap, animated: false)
        self.view.addSubview(wordWrapSwitch)
    }
    
   
    
    @objc func switchStateDidChange(_ sender:UISwitch!)
    {
        wordWrap = sender.isOn;
    }
    
    func scrollViewSetup()
    {
        //scrollView = UIScrollView(frame: UIScreen.main.bounds)
        self.view.addSubview(self.scrollView)
    }
    
    func textViewSetup()
    {
       // multiLineTextView = UITextView(frame: UIScreen.main.bounds)
        multiLineTextView.text = String();
        multiLineTextView.isEditable = false
        multiLineTextView.isScrollEnabled = false//let textView becomes unScrollable
     
        scrollView.addSubview(self.multiLineTextView)
        textViewSetupSizeForWordWrapping()
    }
    
    func sendTextSetup()
    {
        self.view.addSubview(sendTextField)
        self.view.addSubview(sendTextLabel)
        sendTextField.delegate = self
        sendTextField.borderStyle = UITextBorderStyle.bezel
        sendTextField.returnKeyType = .done
        sendTextField.autocorrectionType =  UITextAutocorrectionType.no //no autocorrect
        sendTextField.autocapitalizationType = UITextAutocapitalizationType.none
        
        sendTextLabel.text = "Send:"
        sendTextLabel.sizeToFit()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        if let userInput = textField.text
        {
            viewModel.sendStringFromUser(send: userInput + "\n")
            textField.text?.removeAll();
        }
        
        
        //to dismiss keyboard on Return.. but lets keep it so we can enter multiple lines
        //textField.resignFirstResponder()
        return true
    }
    
    func textViewSetupSizeForWordWrapping()
    {
        // from here: https://stackoverflow.com/questions/33407356/how-to-let-textview-be-able-to-scroll-horizontally
        
        /*
        if (!wordWrap)
        {
            let maxSize = CGSize(width: 3000, height: 3000)
            let font = UIFont(name: "Menlo", size: 16)!
            //key function below
            let strSize = (multiLineTextView.text as NSString).boundingRect(with: maxSize, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font : font], context: nil)
            
            multiLineTextView.frame.size.width = maxSize.width
            multiLineTextView.frame.size.height = maxSize.height
            
            scrollView.contentSize = CGSize(width: strSize.width, height: strSize.height)
        }
         else
        {
            multiLineTextView.frame.size = scrollView.frame.size//UIScreen.main.bounds.size
            scrollView.contentSize = UIScreen.main.bounds.size
        }*/
    }
    
    func scrollTextViewToBottom()
    {
        if multiLineTextView.text.count > 0
        {
            let location = multiLineTextView.text.count - 1
            let bottom = NSMakeRange(location, 1)
            multiLineTextView.scrollRangeToVisible(bottom)
        }
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
