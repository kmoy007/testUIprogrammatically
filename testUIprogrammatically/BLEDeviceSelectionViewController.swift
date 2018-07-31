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
    var viewModel : BLEDeviceSelectionViewModel?
    
    private let disposeBag = DisposeBag() //Rx
    
    private var myTableView: UITableView!
    private var bleStateLabel : UILabel = UILabel()
    private var sv : UIView? //the spinner view
    private let refreshControl = UIRefreshControl()
    
    deinit
    {
        print ("deinit BLEDeviceSelectionViewController")
    }
    
    //MARK: Rx Setup
    private func setupBLEStateObserver() {
        //1
        viewModel?.btStateString.asObservable()
            .subscribe(onNext: { //2
                [weak self] btStateString in
                self?.bleStateLabel.text = btStateString;
                self?.bleStateLabel.setNeedsDisplay();
            })
            .disposed(by:disposeBag)
    }
    
    private func setupDiscoveredDevicesObserver() {
        //1
        viewModel?.devices.asObservable()
            .subscribe(onNext: {
                [weak self] devices in
                self?.myTableView.reloadData()
            })
            .disposed(by:disposeBag)
    }
    
    private func setupBlockUIObserver() {
        //1
        viewModel?.blockUI.asObservable()
            .subscribe(onNext: {
                [weak self] blockUI in
                if (blockUI)
                {
                    if (self != nil)
                    {
                        self?.sv = UIViewController.displaySpinner(onView: self!.view)
                    }
                }
                else
                {
                    if let spinnerView = self?.sv
                    {
                        UIViewController.removeSpinner(spinner: spinnerView)
                    }
                    self?.sv = nil;
                }
            })
            .disposed(by:disposeBag)
    }
    
    func setupRefreshControl()
    {
        myTableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(startScan(_:)), for: .valueChanged)
    }
    
    @objc func startScan(_ sender : Any)
    {
        viewModel?.startScanForDevices();
        self.refreshControl.endRefreshing()
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
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        if (viewModel == nil)
        {
            print("ERROR ViewModel is nil - BLEDeviceSelectionViewController")
            assert(false)
        }
        self.view.backgroundColor = UIColor.white;
        setupBleControlBar();
        setupTableView();
        setupLayoutConstraints();
        setupBLEStateObserver();
        setupDiscoveredDevicesObserver();
        setupBlockUIObserver();
        setupRefreshControl()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if let concreteViewModel = viewModel
        {
            return concreteViewModel.devices.value.count
        }
        else
        {
            return 0;
        }
    }
    
    // called when the cell is selected.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if let concreteViewModel = viewModel
        {
            concreteViewModel.connectDevice(device: concreteViewModel.devices.value[indexPath.row])
        }
        myTableView.reloadData() //redraw
    }
    
    // return cells
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "discoveredDeviceCell", for: indexPath) as! BLEDeviceSelectionTableViewCell
        
        if let concreteViewModel = viewModel
        {
            let thisDevice = concreteViewModel.devices.value[indexPath.row]
            cell.deviceName_label.text = "\(thisDevice.deviceName)"
            cell.labMessage.text = "RSSI: \(thisDevice.rssi)"
            cell.connectionState_label.text = thisDevice.getConnectionStateAsString();
            cell.lastSuccessTime_label.text = DateFormatter.localizedString(from: thisDevice.lastSuccess as Date, dateStyle: .short, timeStyle: .short)
            if (thisDevice.isConnected)
            {
                cell.info_button.tag = indexPath.row
                cell.info_button.addTarget(self, action: #selector(displayInfo(sender:)), for: .touchUpInside)
                cell.info_button.isHidden = false;
            }
            else
            {
                cell.info_button.removeTarget(nil, action: nil, for: .allEvents) //remove all targets
                cell.info_button.isHidden = true;
            }
        }

        return cell
  
    }
    
    @objc func displayInfo(sender: UIButton)
    {
        if let concreteViewModel = viewModel
        {
            if (sender.tag >= 0) && (sender.tag < concreteViewModel.devices.value.count) //in range
            {
                let device = concreteViewModel.devices.value[sender.tag]
                
                let infoViewModel = BLEDeviceCompleteInfoViewModel(theDevice: device);
                let infoViewController = BLEDeviceCompleteInfoViewController();
                infoViewController.viewModel = infoViewModel;
                if self.navigationController?.pushViewController(infoViewController, animated: true) == nil
                {
                    print("ERROR")
                    assert(false)
                }
            }
            else
            {
                let alertController = UIAlertController(title: "ERROR", message: "device is nil!", preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                self.present(alertController, animated:true, completion:nil)
            }
        }
        
    }
    
}
