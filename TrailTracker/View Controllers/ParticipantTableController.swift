//
//  ParticipantTableController.swift
//  TrailTracker
//
//  Created by Evan Kaminsky on 4/11/18.
//  Copyright © 2018 Camacho. All rights reserved.
//

import UIKit

class ParticipantTableController: UIViewController, getMemberInfoPrototcol {
    
    // Fields //
    
    @IBOutlet weak var tableView: UITableView!
    var camachoButton: CamachoButton!
    let refresher = UIRefreshControl()
    
    var participants: [Member] = []
    
    var selectedRow: Int = -1
    
    
    // Methods //
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Nav Bar
        navigationController?.navigationBar.barTintColor = Color.forest
        navigationController?.navigationBar.titleTextAttributes = Font.makeAttrs(size: 30, color: Color.white, type: .sunn)
        
        // Table
        tableView.delegate = self
        tableView.dataSource = self
        tableView.refreshControl = refresher
        refresher.addTarget(self, action: #selector(ParticipantTableController.update), for: .valueChanged)

        // Camacho Button
        let button_width = 0.2 * view.width
        camachoButton = CamachoButton(frame: CGRect(x: 0, y: 0, width: button_width, height: button_width), text: "New", backgroundColor: Color.orange)
        camachoButton.touchUpInside = { button in
            button.bubble()
            let newMemberView = self.storyboard?.instantiateViewController(withIdentifier: "CreateParticipantController")
            self.navigationController?.pushViewController(newMemberView!, animated: false)
            
        }
    
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        camachoButton.addToView()
        if self.participants.isEmpty || SHOULD_RELOAD_MEMBERS {
            refresher.beginRefreshingManually(animated: false)
            self.update()
            SHOULD_RELOAD_MEMBERS = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        camachoButton.removeFromSuperview()
    }
    
    @objc func update() {
        Member.getMembers { [weak self] (status, members) in
            DispatchQueue.main.async {
                self?.refresher.endRefreshing()
                if status == .success {
                    self?.participants = members
                    self?.tableView.reloadData()
                }
            }
        }
    }
    
}


extension ParticipantTableController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return participants.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    // Cell Creation
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let participant = participants[safe: indexPath.row] else {
            return UITableViewCell()
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemberTableViewCell", for: indexPath) as! MemberTableCell
        cell.update(with: participant)
        return cell
    }
    
    // Cell Selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let participant = participants[safe: indexPath.row] else {
            return
        }
        tableView.deselectSelectedRow()
        self.selectedRow = indexPath.row
        
   
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "memberSegue",
            let destination = segue.destination as? ParticipantViewController
        {
            destination.membersDelegate = self
        }
        
    }
    
    func getMemberInfo() -> Member {
        return participants[self.selectedRow]
        
        
    }
    
    

    
}





