//
//  CommandAndSerialViewController.swift
//  testUIprogrammatically
//
//  Created by Ken Moynihan on 12/07/18.
//  Copyright © 2018 Ken Moynihan. All rights reserved.
//

import Foundation
import UIKit

class CommandAndSerialViewController: UIViewController
{
    let serialView = SerialTextViewController();
    let commandView = TestingViewController();
    private let topStackView = UIStackView()
    
    let bleDeviceInterface = BLEDeviceInterface()
    let bleFriendSimulator = BLEFriendSimulator()
    let electronSimulator = ElectronSimulator()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white;
        setupStackView();
        addContentController(commandView, to: topStackView)
        addContentController(serialView, to: topStackView)
        createAllObjects()
    }
    
    func createAllObjects()
    {
        bleDeviceInterface.theDevice = bleFriendSimulator.downstreamReceiver!
        bleFriendSimulator.upStreamDevice = bleDeviceInterface.upstreamReceiver!
        
        bleFriendSimulator.downStreamDevice.messageDestination = electronSimulator
        electronSimulator.upstreamDevice = bleFriendSimulator.upstreamReceiver!
        
        //connect the serial view
        serialView.viewModel.downStream = DoNothingSendMessageFormattingBuffer()//BLEFriend_SendMessageFormattingBuffer()
        serialView.viewModel.downStream?.messageDestination = bleDeviceInterface.downstreamReceiver!
        bleDeviceInterface.upstream_TEMP = serialView.viewModel
        
        //connect the command view
        commandView.setBleInterface(bleInterface:bleDeviceInterface)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        super.viewWillTransition(to: size, with: coordinator)
        topStackView.axis = axisForSize(size)
    }
    private func setupStackView() {
        
        topStackView.axis = axisForSize(view.bounds.size)
        topStackView.alignment = .fill
        topStackView.distribution = .fillEqually
        topStackView.spacing = 8.0
        
        topStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(topStackView)
        
        let margins = view.layoutMarginsGuide
        NSLayoutConstraint.activate([
            topStackView.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            topStackView.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            topStackView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: 8.0),
            bottomLayoutGuide.topAnchor.constraint(equalTo: topStackView.bottomAnchor, constant: 8.0)
            ])
    }
    
    private func axisForSize(_ size: CGSize) -> UILayoutConstraintAxis {
        return size.width > size.height ? .horizontal : .vertical
    }
    private func addContentController(_ child: UIViewController, to stackView: UIStackView) {
        
        addChildViewController(child)
        stackView.addArrangedSubview(child.view)
        child.didMove(toParentViewController: self)
    }
    
   
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

