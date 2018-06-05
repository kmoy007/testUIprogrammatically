//
//  ViewController.swift
//  testUIprogrammatically
//
//  Created by Ken Moynihan on 23/05/18.
//  Copyright © 2018 Ken Moynihan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let serialViewController = SerialTextViewController()
    
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
        
        //NEED TO SETUP ALL CONSTRAINTS
       // assert(false)
        if  gesture.state == .ended
        {
            if self.navigationController?.pushViewController(serialViewController, animated: true) == nil
            {
                print("ERROR")
                assert(false)
            }
           // setConstraints();
        }
    }
    
    /*func setConstraints()
    {
        serialViewController.view.translatesAutoresizingMaskIntoConstraints = false
        if let nav = self.navigationController
        {
            serialViewController.view.leadingAnchor.constraint(equalTo: nav.view.safeAreaLayoutGuide.leadingAnchor).isActive = true
            serialViewController.view.trailingAnchor.constraint(equalTo: nav.view.trailingAnchor).isActive = true
            serialViewController.view.topAnchor.constraint(equalTo: nav.view.topAnchor).isActive = true
            serialViewController.view.bottomAnchor.constraint(equalTo: nav.view.bottomAnchor).isActive = true
        }
    
    }*/
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

