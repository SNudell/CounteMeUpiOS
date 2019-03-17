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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updater = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(requestRefresh), userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        updater = nil
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
}
