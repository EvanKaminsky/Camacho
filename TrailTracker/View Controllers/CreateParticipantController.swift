//
//  CreateParticipantController.swift
//  TrailTracker
//
//  Created by Evan Kaminsky on 4/11/18.
//  Copyright © 2018 Camacho. All rights reserved.
//

import UIKit

class CreateParticipantController: UIViewController {

    // Fields //
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var parentField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var memberTypeLabel: UILabel!
    @IBOutlet var tabView: UIView!
    
    var camachoButton: CamachoButton!
    var staffButton: MemberTypeButton!
    var participantButton: MemberTypeButton!
    
    var memberType: Member.MemberType!
    
    
    // Methods //
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Nav Bar
        navigationController?.navigationBar.barTintColor = Color.forest
        navigationController?.navigationBar.titleTextAttributes = Font.makeAttrs(size: 30, color: Color.white, type: .sunn)
        self.navigationItem.title = "New Member"
        
        // Text field
        let attributes = Font.makeAttrs(size: 40, color: Color.gray, type: .sunn)
        nameField.attributedPlaceholder = NSAttributedString(string: "Full Name", attributes:attributes)
        nameField.borderStyle = UITextBorderStyle.roundedRect
        parentField.attributedPlaceholder = NSAttributedString(string: "Parent/Guardian's Name", attributes:attributes)
        parentField.borderStyle = UITextBorderStyle.roundedRect
        emailField.attributedPlaceholder = NSAttributedString(string: "Email Address", attributes:attributes)
        emailField.borderStyle = UITextBorderStyle.roundedRect
        
        // Label
        let labelAttributes = Font.makeAttrs(size: 40, color: Color.black, type: .sunn)
        memberTypeLabel.attributedText = NSAttributedString(string: "Member Type", attributes: labelAttributes)
    
        // Camacho button
        let button_width = 0.2 * view.width
        camachoButton = CamachoButton(frame: CGRect(x: 0, y: 0, width: button_width, height: button_width), text: "Create", backgroundColor: Color.orange)
        camachoButton.touchUpInside = { [weak self] button in
            button.bubble()
            self?.createParticipant()
        }
        
        // Member Type Buttons
        let member_width = 0.35 * view.width
        let member_height = 0.07 * view.height
        staffButton = MemberTypeButton(frame: CGRect(x: 0, y: 0, width: member_width, height: member_height), text: "Staff", image: "staff", isSelected: true, themeColor: Color.orange)
        participantButton = MemberTypeButton(frame: CGRect(x: 0, y: 0, width: member_width, height: member_height), text: "Participant", image: "peep", isSelected: true, themeColor: Color.blue)
        staffButton.touchUpInside = { [weak self] button in
            button.bubble(x: 0.9, y: 0.9, velocity: 5, options: .allowUserInteraction)
            self?.setMember(type: .staff)
        }
        participantButton.touchUpInside = { [weak self] button in
            button.bubble(x: 0.9, y: 0.9, velocity: 5, options: .allowUserInteraction)
            self?.setMember(type: .participant)
        }
        
        // Keyboard Management
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self,action: #selector(CreateParticipantController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        // Set default member type
        self.memberType = .participant
        participantButton.setIsSelected()
        staffButton.setIsNotSelected()
        
        // Placements
        memberTypeLabel.center = CGPoint(x: self.view.center.x, y: 0.52 * view.height)
        staffButton.center = CGPoint(x: 0.3 * view.width, y: 0.6 * view.height)
        participantButton.center = CGPoint(x: 0.7 * view.width, y: 0.6 * view.height)
        self.view.addSubview(staffButton)
        self.view.addSubview(participantButton)
        
    }
    
    func createParticipant() {
        guard let name = nameField.text?.trimmingCharacters(in: .whitespacesAndNewlines), name.count > 0 else {
            debugPrint("Error: Cannot create participant with no name!")
            return
        }
        
        let guardian_name = parentField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let guardian_email = emailField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        Member.create(type: self.memberType, name: name, guardianName: guardian_name, guardianEmail: guardian_email)
        
        SHOULD_RELOAD_MEMBERS = true
        self.navigationController?.popViewController(animated: true)
    }
    
    func setMember(type: Member.MemberType) {
        switch type {
        case .staff:
            self.memberType = .staff
            staffButton.setIsSelected()
            participantButton.setIsNotSelected()
        case .participant:
            self.memberType = .participant
            staffButton.setIsNotSelected()
            participantButton.setIsSelected()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        camachoButton.addToView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        camachoButton.removeFromSuperview()
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    

    
    
}
