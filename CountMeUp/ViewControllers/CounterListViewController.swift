//
//  CounterListViewController.swift
//  CountMeUp
//
//  Created by Gustav Schmid on 14.03.19.
//  Copyright © 2019 Gustav Schmid. All rights reserved.
//

import Foundation
import UIKit

class CounterListViewController: UITableViewController {
    
    var counters: [Counter]
    
    var cellIdentifier = "counterCell"
    
    var updater: Timer?
    
    init(style: UITableView.Style, counters: [Counter]) {
        self.counters = counters
        super.init(style: style)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(CounterTableCell.self, forCellReuseIdentifier: cellIdentifier)
        styleNavBar()
    }
    
    func styleNavBar() {
        navigationItem.title = "Counters"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addCounter))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startUpdater()
    }
    
    func startUpdater() {
        updater = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(requestRefresh), userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        updater?.invalidate()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return counters.count
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let counter = counters[indexPath.row]
            confirmDeletion(of: counter)
        }
    }
    
    func confirmDeletion(of counter: Counter) {
        let alertController = UIAlertController(title: "Are you sure?", message: "Confirm deletion of " + counter.name, preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Delete", style: .destructive) { (_) in
            requestSender.delete(counter) {
                self.requestRefresh()
            }
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        updater?.invalidate()
    }
    override func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        startUpdater()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let counter = counters[indexPath.row]
        transition(to: counter)
    }
    
    func transition(to counter: Counter) {
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? CounterTableCell else {
            fatalError()
        }
        let currentLastItem = counters[indexPath.row]
        cell.counter = currentLastItem
        return cell
    }
    
    @objc func requestRefresh(){
        requestSender.getAllCounters(completion: { (counters) in
            guard let allCounters = counters else {
                return
            }
            self.counters = allCounters
            self.tableView.reloadData()
        })
    }
    
    @objc func addCounter() {
        let alertController = UIAlertController(title: "Enter Name and Value?", message: "Enter the counters name and starting value", preferredStyle: .alert)
        
        //the confirm action taking the inputs
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { (_) in
            
            //getting the input values from user
            guard let name = alertController.textFields?[0].text,
                !name.isEmpty,
                self.isValid(name),
                let value = alertController.textFields?[1].text,
                !value.isEmpty,
                let initialValue = Int64(value) else {
                return
            }
            self.sendCreationRequest(name: name, initialValue: initialValue)
        }
        
        //the cancel action doing nothing
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        //adding textfields to our dialog box
        alertController.addTextField { (textField) in
            textField.placeholder = "Enter Name"
        }
                
        alertController.addTextField { (textField) in
            textField.placeholder = "Enter Starting value"
            textField.keyboardType = .numberPad
        }
        
        //adding the action to dialogbox
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        //finally presenting the dialog box
        self.present(alertController, animated: true, completion: nil)
    }
    
    func isValid(_ name: String) -> Bool {
        for char in name {
            if char.isLetter || char.isNumber || char.isWhitespace {
                continue
            }
            return false
        }
        return true
    }
    
    func sendCreationRequest(name: String, initialValue: Int64) {
        requestSender.create(counter: name, withStartingValue: initialValue, completion: {counter in
            self.requestRefresh()
            })
    }
}
