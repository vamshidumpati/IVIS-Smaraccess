//
//  UserDetailsViewController.swift
//  SmartAccess
//
//  Created by Vamshirkishna on 09/04/25.
//

import UIKit

class UserDetailsViewController: UIViewController {
    @IBOutlet weak var detailsTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        detailsTableView.register(UINib(nibName: "InfoTableViewCell", bundle: nil), forCellReuseIdentifier: "InfoTableViewCell")
        // Do any additional setup after loading the view.
        self.navigationItem.hidesBackButton = true
    }
    
    @IBAction func onTapNext(_ sender: Any) {
        let faceIDVC = self.storyboard?.instantiateViewController(withIdentifier: "FaceBlinkViewController") as? FaceBlinkViewController
        self.navigationController?.pushViewController(faceIDVC!, animated: true)
    }
    
}

extension UserDetailsViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InfoTableViewCell") as? InfoTableViewCell
        cell?.profileName.text = "Hell0"
        return cell!
    }
}
