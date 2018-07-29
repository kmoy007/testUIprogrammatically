//
//  BLEDeviceSelectionViewController.swift
//  testUIprogrammatically
//
//  Created by Ken Moynihan on 26/07/18.
//  Copyright © 2018 Ken Moynihan. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class BLEDeviceSelectionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    let disposeBag = DisposeBag()
    let viewModel = BLEDeviceSelectionViewModel();
    
    private var myTableView: UITableView!
    private var bleStateLabel : UILabel = UILabel()
    
    //MARK: Rx Setup
    private func setupBLEStateObserver() {
        //1
        viewModel.btStateString.asObservable()
            .subscribe(onNext: { //2
                btStateString in
                self.bleStateLabel.text = btStateString;
                self.bleStateLabel.setNeedsDisplay();
            })
            .addDisposableTo(disposeBag) //3
    }
    
    func refresh()
    {
    //    bleStateLabel.text = viewModel.getBTStateAtString()
    //    bleStateLabel.setNeedsDisplay()
        myTableView.reloadData() //redraw
    }
    
    func setupLayoutConstraints()
    {
        bleStateLabel.translatesAutoresizingMaskIntoConstraints = false
        myTableView.translatesAutoresizingMaskIntoConstraints = false
        
       /* bleStateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        bleStateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        bleStateLabel.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        bleStateLabel.bottomAnchor.constraint(equalTo: myTableView.topAnchor).isActive = true
        
        myTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        myTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        myTableView.topAnchor.constraint(equalTo: bleStateLabel.bottomAnchor).isActive = true
        myTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        */
        
        self.view.addSubview(bleStateLabel)
        self.view.addSubview(myTableView)
        
        let viewsDict = [
            "bleStateLabel" : bleStateLabel,
            "tableView" : myTableView,
            ] as [String : Any]
        
        
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[bleStateLabel]-|", options: [], metrics: nil, views: viewsDict))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[tableView]-|", options: [], metrics: nil, views: viewsDict))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[bleStateLabel]-[tableView]-|", options: [], metrics: nil, views: viewsDict))
    }
    
    func setupBleControlBar()
    {
        bleStateLabel.numberOfLines = 1;
        bleStateLabel.text = "BLE State Here"
       
       /* let maxSize = CGSize(width: 200, height: 30)
        let size = bleStateLabel.sizeThatFits(maxSize)
        //bleStateLabel.sizeToFit()*/
        
    }
    
    func setupTableView()
    {
        myTableView = UITableView();
        
        myTableView.register(BLEDeviceSelectionTableViewCell.self, forCellReuseIdentifier: "discoveredDeviceCell")         // register cell name
        
        myTableView.dataSource = self
        myTableView.delegate = self
        
        //Auto-set the UITableViewCells height (requires iOS8+)
        myTableView.rowHeight = UITableViewAutomaticDimension
        myTableView.estimatedRowHeight = 44
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated);
        //myTableView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.viewController = self;
        self.view.backgroundColor = UIColor.white;
        setupBleControlBar();
        setupTableView();
        setupLayoutConstraints();
        setupBLEStateObserver();
        refresh();
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.devices.count
    }
    
    // called when the cell is selected.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
        print("Num: \(indexPath.row)")
        print("Name: \(viewModel.devices[indexPath.row].deviceName)")
        myTableView.reloadData() //redraw
    }
    
    // return cells
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "discoveredDeviceCell", for: indexPath) as! BLEDeviceSelectionTableViewCell
        
        cell.deviceName_label.text = "\(viewModel.devices[indexPath.row].deviceName)"
        cell.labMessage.text = "RSSI: \(viewModel.devices[indexPath.row].rssi)"
        cell.lastSuccessTime_label.text = DateFormatter.localizedString(from: viewModel.devices[indexPath.row].lastSuccess as Date, dateStyle: .short, timeStyle: .short)
        
        return cell
  
    }
    
}
