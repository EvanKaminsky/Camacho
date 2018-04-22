//
//  CreateParticipantController.swift
//  TrailTracker
//
//  Created by Evan Kaminsky on 4/11/18.
//  Copyright © 2018 Camacho. All rights reserved.
//

import UIKit

class CreateParticipantController: UIViewController {
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var parentField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet var tabView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabView?.addSubview(createButton)
    }
    
    @IBAction func onCreatePressed(_ sender: Any) {
        
    }
    
    
}
