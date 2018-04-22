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
    @IBOutlet weak var memberTypeLabel: UILabel!
    @IBOutlet var tabView: UIView!
    
    var camachoButton: CamachoButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Nav Bar
        navigationController?.navigationBar.barTintColor = Color.forest
        navigationController?.navigationBar.titleTextAttributes = Font.makeAttrs(size: 30, color: Color.white, type: .sunn)
        self.navigationItem.title = "New Member"
        
        
        //Text field
        let attributes = [NSAttributedStringKey.foregroundColor: UIColor.gray,
            NSAttributedStringKey.font : UIFont(name: "SUNN", size: 40)! ]
        nameField.attributedPlaceholder = NSAttributedString(string: "Full Name", attributes:attributes)
        nameField.borderStyle = UITextBorderStyle.roundedRect
        //nameField.sizeToFit()
        parentField.attributedPlaceholder = NSAttributedString(string: "Parent/Guardian's Name", attributes:attributes)
        parentField.borderStyle = UITextBorderStyle.roundedRect
       // parentField.sizeToFit()
        emailField.attributedPlaceholder = NSAttributedString(string: "Email Address", attributes:attributes)
        emailField.borderStyle = UITextBorderStyle.roundedRect
        //emailField.sizeToFit()
        
        //Label
        let labelAttributes = [NSAttributedStringKey.foregroundColor: UIColor.black,NSAttributedStringKey.font : UIFont(name: "SUNN", size: 40)! ]
        memberTypeLabel.attributedText = NSAttributedString(string: "Member Type", attributes: labelAttributes)
        memberTypeLabel.center.x = self.view.center.x
    
        //Camacho button
        let button_width = 0.2 * view.width
        camachoButton = CamachoButton(frame: CGRect(x: 0, y: 0, width: button_width, height: button_width), text: "Create", backgroundColor: Color.orange)
        camachoButton.touchUpInside = { button in
            button.bubble()
            
            let memberView = self.storyboard?.instantiateViewController(withIdentifier: "TabViewController")
            self.navigationController?.present(memberView!, animated: false, completion: nil)
        }
        
        //Member Type Button
        let member_width = 0.35 * view.width
        let member_height = 0.07 * view.height
        let member_button_1 = MemberTypeButton(frame: CGRect(x: 0, y: 0, width: member_width, height: member_height), text: "Staff", image: "staff", isSelected: true, themeColor: Color.orange)
        member_button_1.center = CGPoint(x: 0.3 * view.width, y: 0.6 * view.height)
        member_button_1.touchUpInside = { button in
            button.bubble(x: 0.9, y: 0.9, velocity: 5, options: .allowUserInteraction)
             member_button_1.toggleSelected()
         }
        
        let member_button_2 = MemberTypeButton(frame: CGRect(x: 0, y: 0, width: member_width, height: member_height), text: "Participant", image: "peep", isSelected: true, themeColor: Color.blue)
        member_button_2.center = CGPoint(x: 0.7 * view.width, y: 0.6 * view.height)
        member_button_2.touchUpInside = { button in
            button.bubble(x: 0.9, y: 0.9, velocity: 5, options: .allowUserInteraction)
            member_button_2.toggleSelected()
        }
        
        self.view.addSubview(member_button_1)
        self.view.addSubview(member_button_2)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        camachoButton.addToView()
         
    }
    

    
    
}
