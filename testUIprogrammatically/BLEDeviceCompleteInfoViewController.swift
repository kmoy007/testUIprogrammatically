//
//  BLEDeviceCompleteInfoViewController.swift
//  testUIprogrammatically
//
//  Created by Ken Moynihan on 30/07/18.
//  Copyright © 2018 Ken Moynihan. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class BLEDeviceCompleteInfoViewController : UIViewController
{
    private let disposeBag = DisposeBag()
    var viewModel : BLEDeviceCompleteInfoViewModel?
    
    private let multiLineTextView : UITextView = UITextView()
    deinit
    {
        print ("deinit BLEDeviceCompleteInfoViewController")
    }
    
    //MARK: Rx Setup
    private func setupDeviceInfoObserver() {
        viewModel?.textOfDeviceInfo.asObservable()
            .subscribe(onNext: {
                [weak self] textOfDeviceInfo in
                self?.multiLineTextView.text = textOfDeviceInfo;
                self?.multiLineTextView.setNeedsDisplay()
            })
            .disposed(by:disposeBag)
    }
    
    func setConstraints()
    {
        multiLineTextView.translatesAutoresizingMaskIntoConstraints = false
        
        multiLineTextView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        multiLineTextView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        multiLineTextView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        multiLineTextView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (viewModel == nil)
        {
            print("ERROR - BLEDeviceCompleteInfoViewController is nil")
            assert(false)
        }
        self.view.backgroundColor = UIColor.white;
        multiLineTextView.text = String();
        multiLineTextView.isEditable = false
        multiLineTextView.isScrollEnabled = true//let textView becomes unScrollable
        
        self.view.addSubview(self.multiLineTextView)
        
        setupDeviceInfoObserver();
        setConstraints();
        viewModel?.triggerUpdate() //race condition so manually trigger to be sure
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
