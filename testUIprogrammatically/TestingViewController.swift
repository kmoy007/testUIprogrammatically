//
//  SerialTextTableViewController.swift
//  testUIprogrammatically
//
//  Created by Ken Moynihan on 23/05/18.
//  Copyright © 2018 Ken Moynihan. All rights reserved.
//

import UIKit

class TestingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    deinit
    {
        print("deinit TestingViewController")
    }
    
    let viewModel = TestingViewModel();
    private var myTableView: UITableView!
    
    private let sections: NSArray = ["command", "fruit", "vegetable"]
    private let fruit: NSArray = ["apple", "orange", "banana", "strawberry", "lemon"]
    private let vegetable: NSArray = ["carrots", "avocado", "potato", "onion"]
    
    func setBleInterface(bleInterface : BLEDeviceInterface)
    {
        viewModel.setBLEInterface(bleInterface: bleInterface)
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated);
        myTableView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.viewController = self;
        
        // get width and height of View
        let barHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height
        let navigationBarHeight: CGFloat = 0//self.navigationController!.navigationBar.frame.size.height
        let displayWidth: CGFloat = self.view.frame.width
        let displayHeight: CGFloat = self.view.frame.height
        
        myTableView = UITableView(frame: CGRect(x: 0, y: barHeight+navigationBarHeight, width: displayWidth, height: displayHeight - (barHeight+navigationBarHeight)))
        myTableView.register(TestCommandTableViewCell.self, forCellReuseIdentifier: "commandCell")         // register cell name
        myTableView.register(DummyCommandTableViewCell.self, forCellReuseIdentifier: "dummyCell")         // register cell name
        
        
        myTableView.dataSource = self
        myTableView.delegate = self
        
        //Auto-set the UITableViewCells height (requires iOS8+)
        myTableView.rowHeight = UITableViewAutomaticDimension
        myTableView.estimatedRowHeight = 44
        
        self.view.addSubview(myTableView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // return the number of sections
    func numberOfSections(in tableView: UITableView) -> Int{
        return sections.count
    }
    
    
    
    // return the title of sections
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section] as? String
    }
    
    
    // called when the cell is selected.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
        print("Num: \(indexPath.row)")
        if indexPath.section == 0
        {
            viewModel.commands[indexPath.row].doSomething()
            myTableView.reloadData() //redraw
        }
        if indexPath.section == 1
        {
            print("Value: \(fruit[indexPath.row])")
        } else if indexPath.section == 2 {
            print("Value: \(vegetable[indexPath.row])")
        }
    }
    
    // return the number of cells each section.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return fruit.count
        } else if section == 2 {
            return vegetable.count
        } else {
            return viewModel.commands.count
        }
    }
    
    // return cells
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if indexPath.section == 0
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "commandCell", for: indexPath) as! TestCommandTableViewCell
            cell.aButton.setTitle("SomeButton", for: .normal)
            
            cell.commandName_label.text = "\(viewModel.commands[indexPath.row].commandName)"
            cell.labMessage.text = "Message \(indexPath.row)"
            cell.lastSuccessTime_label.text = DateFormatter.localizedString(from: viewModel.commands[indexPath.row].lastSuccess as Date, dateStyle: .short, timeStyle: .short)
            
            switch viewModel.commands[indexPath.row].lastAttemptSuccessful
            {
            case .NotCalled:
                cell.imgUser.backgroundColor = UIColor.blue
            case .NoSuccess:
                cell.imgUser.backgroundColor = UIColor.red
            case .Success:
                cell.imgUser.backgroundColor = UIColor.green
            default:
                cell.imgUser.backgroundColor = UIColor.black
            }
            
            
            
            return cell
        }
        else if indexPath.section == 1
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "dummyCell", for: indexPath) as! DummyCommandTableViewCell
            cell.commandName_label.text = "\(fruit[indexPath.row])"
            cell.labMessage.text = "Message \(indexPath.row)"
            return cell
        }
        else if indexPath.section == 2
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "dummyCell", for: indexPath) as! DummyCommandTableViewCell
            cell.commandName_label.text = "\(vegetable[indexPath.row])"
            cell.labMessage.text = "Message \(indexPath.row)"
            return cell;
        }
        
        
        
        return UITableViewCell()
    }
    
}
