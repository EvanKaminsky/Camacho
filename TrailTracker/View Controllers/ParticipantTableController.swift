//
//  ParticipantTableController.swift
//  TrailTracker
//
//  Created by Evan Kaminsky on 4/11/18.
//  Copyright © 2018 Camacho. All rights reserved.
//

import UIKit

class ParticipantTableController: UIViewController {
    
    // Fields //
    
    @IBOutlet weak var tableView: UITableView!
    let refresher = UIRefreshControl()
    
    var participants: [Member] = []
    
    
    
    // Methods //
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.barTintColor = Color.forest
        navigationController?.navigationBar.titleTextAttributes = Font.makeAttrs(size: 30, color: Color.white, type: .sunn)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.refreshControl = refresher
        refresher.addTarget(self, action: #selector(ParticipantTableController.update), for: .valueChanged)
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refresher.beginRefreshingManually(animated: false)
        self.update()
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
        return MemberTableCell.height
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
        guard let _ = participants[safe: indexPath.row] else {
            return
        }
        
        // TODO: Go to ParticipantViewController
        // let vc = ParticipantViewController(nibName: nil, bundle: nil)
        // vc.participant = participant
        // self.navigationController?.pushViewController(vc, animated: true)
    }
    
}





