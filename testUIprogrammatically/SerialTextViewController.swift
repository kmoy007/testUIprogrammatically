//
//  SerialTextTableViewController.swift
//  testUIprogrammatically
//
//  Created by Ken Moynihan on 23/05/18.
//  Copyright © 2018 Ken Moynihan. All rights reserved.
//

import UIKit

class SerialTextViewController: UIViewController
{
    var scrollView : UIScrollView = UIScrollView()
    var multiLineTextView : UITextView = UITextView()
    var wordWrap: Bool  = true {
        didSet {
            textViewSetupSizeForWordWrapping()
            }
    }
    var scrollPaused: Bool = false;
    
    let animals : [String] = ["Dogs","Cats","Mice","class SerialTextViewController: UIViewController, UITableViewDelegate, UITableViewDataSource", "lastone"]
    
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
            self.textViewSetupSizeForWordWrapping()
        }), completion: nil)
    }
        
    func wordWrapSwitchSetup()
    {
        let wordWrapSwitch=UISwitch(frame:CGRect(x: 300, y: 50, width: 0, height: 0))
        wordWrapSwitch.addTarget(self, action: #selector(SerialTextViewController.switchStateDidChange(_:)), for: .valueChanged)
        wordWrapSwitch.setOn(wordWrap, animated: false)
        self.view.addSubview(wordWrapSwitch)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        scrollViewSetup()
        textViewSetup()
        wordWrapSwitchSetup()
    }
    
    @objc func switchStateDidChange(_ sender:UISwitch!)
    {
        wordWrap = sender.isOn;
    }
    
    func scrollViewSetup()
    {
        scrollView = UIScrollView(frame: UIScreen.main.bounds)
        self.view.addSubview(self.scrollView)
    }
    
    func textViewSetup()
    {
        multiLineTextView = UITextView(frame: UIScreen.main.bounds)
        multiLineTextView.text = String();
        multiLineTextView.isEditable = false
        multiLineTextView.isScrollEnabled = false//let textView becomes unScrollable
        for theTextLine in animals
        {
            multiLineTextView.text.append(theTextLine + "\n")
        }
        
        scrollView.addSubview(self.multiLineTextView)
        textViewSetupSizeForWordWrapping()
    }
    
    func textViewSetupSizeForWordWrapping()
    {
        // from here: https://stackoverflow.com/questions/33407356/how-to-let-textview-be-able-to-scroll-horizontally
        
        
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
            multiLineTextView.frame.size = UIScreen.main.bounds.size
            scrollView.contentSize = UIScreen.main.bounds.size
        }
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
