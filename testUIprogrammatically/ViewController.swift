//
//  ViewController.swift
//  testUIprogrammatically
//
//  Created by Ken Moynihan on 23/05/18.
//  Copyright © 2018 Ken Moynihan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.red
        // Add "long" press gesture recognizer
        let tap = UILongPressGestureRecognizer(target: self, action: #selector(tapHandler))
        tap.minimumPressDuration = 0
        self.view.addGestureRecognizer(tap)
        // Do any additional setup after loading the view, typically from a nib.
    }

    // called by gesture recognizer
    @objc func tapHandler(gesture: UITapGestureRecognizer) {
        
        let serialViewController = SerialTextViewController()
       // self.navigationController?.pushViewController(serialViewController, animated: true)
        
        if  gesture.state == .ended
        {
            if self.navigationController?.pushViewController(serialViewController, animated: true) == nil
            {
                print("ERROR")
                assert(false)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

