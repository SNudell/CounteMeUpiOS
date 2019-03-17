//
//  CounterViewController.swift
//  CountMeUp
//
//  Created by Gustav Schmid on 17.03.19.
//  Copyright © 2019 Gustav Schmid. All rights reserved.
//

import Foundation
import UIKit

class CounterViewController : UIViewController {
    
    var counter: Counter
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, counter: Counter) {
        self.counter = counter
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
