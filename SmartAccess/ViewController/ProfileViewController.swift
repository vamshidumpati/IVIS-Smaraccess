//
//  ProfileViewController.swift
//  SmartAccess
//
//  Created by Vamshirkishna on 07/04/25.
//

import UIKit

class ProfileViewController: UIViewController {
    @IBOutlet weak var logoView: UIView!
    @IBOutlet weak var dataTableView: UITableView!
    @IBOutlet weak var nextBtn: UIButton!
    
    var selectedSite:Site?
    let loggedUserName =  DataStore.shared.userAuth?.fullName ?? "User"
    var selectedSegmentStr = ""
    var deviceInfo:[String:Any] = [:]
    var deviceStatus = ""
    
    var imagesArray = ["user_logo","building.fill"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let tableView = dataTableView{
            tableView.register(UINib(nibName: "InfoTableViewCell", bundle: nil), forCellReuseIdentifier: "InfoTableViewCell")
            tableView.register(UINib(nibName: "ProfileTableViewCell", bundle: nil), forCellReuseIdentifier: "ProfileTableViewCell")
            tableView.estimatedRowHeight = 100
            tableView.rowHeight = UITableView.automaticDimension
            setupI()
        }
        navigationItem.hidesBackButton = true
    }
    
    func loadInitialData() {
        let siteId = selectedSite?.siteId ?? 0
        let unitId = selectedSite?.unitId ?? 0
        // First API call - Get Vault Configuration
        NetworkManager.getVaultConfiguration(siteId: siteId, unitId: unitId) { result, error in
            if error == "" {
                // Success - proceed with second API call
                guard let deviceId = DataStore.shared.vaultData?.ivisVault?.unit?.ivisunitId else {
                    print("Error: Could not get device ID from vault data")
                    return
                }
                
                print("Vault config success. Device ID: \(deviceId)")
                
                // Second API call - Get Device Status
                let params: [String: Any] = [
                    "empId": DataStore.shared.userAuth?.employeeId ?? 0,
                    "deviceId": deviceId
                ]
                
                NetworkManager.getDeviceStatus(params: params) { data, error in
                    if error == ""{
                        self.deviceInfo = data
                        print(self.deviceInfo)
                        self.deviceStatus = self.deviceInfo["status"] as? String ?? ""
                        DispatchQueue.main.async {
                            self.dataTableView.reloadData()
                        }
                    }
                }
            } else {
                print("Vault config error: \(error)")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        dataTableView.reloadData()
    }
    
    func setupI(){
        loadInitialData()
        nextBtn.titleLabel?.font = UIFont(name: "Lato-Bold", size: 14.0)
        nextBtn.layer.cornerRadius = 5
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        logoView.applyBottomBorderAndShadow()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in
            self.dataTableView.beginUpdates()
            self.dataTableView.endUpdates()
        })
    }
    @IBAction func onTapNext(_ sender: Any) {
        if selectedSegmentStr == ""{
            self.displayAlert(title: "Error", message: "Please select one option from above list of options for requesting acess")
        } else if DataStore.shared.vaultData?.ivisVault?.unit?.ivisunitId ?? "" == ""{
            self.displayAlert(title: "Error", message: "User not configured to this site")
        }else {
            getDeviceStatus { status in
//                if status != "" && status != "ok"{
//                    let message = status == "failed" ? "User not configured to this site" : status
//                    self.displayAlert(title: "Error", message: message)
//                    return
//                } else {
//
//                }
                self.showConfirmationAlert(on: self, title: "Confirmation", message: "You've requested access with the \(self.selectedSegmentStr). Are you ready to proceed?") { isTappedYesOrNo in
                    if isTappedYesOrNo{
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let detailsVC = storyboard.instantiateViewController(withIdentifier: "UserDetailsViewController") as? UserDetailsViewController
                        detailsVC?.deviceStatus = self.deviceStatus
                        detailsVC?.modalPresentationStyle = .fullScreen
                        detailsVC?.modalTransitionStyle = .crossDissolve
                        self.navigationController?.pushViewController(detailsVC!, animated: true)
                    } else {
                        self.dismiss(animated: true)
                    }
                }
            }
        }
    }
    
    func getDeviceStatus(completion: @escaping (String) -> Void) {
        // Retrieve deviceId; if empty, notify immediately.
        let deviceId = DataStore.shared.vaultData?.ivisVault?.unit?.ivisunitId ?? ""
        NetworkManager.getDoorStatus(deviceId: deviceId) { doorData, error in
            if !error.isEmpty {
                completion("User not configured to this site")
            } else {
                completion(doorData["data"] as? String ?? "")
            }
        }
    }
}

extension ProfileViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 2 : 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        if indexPath.section == 0 {
            let infoCell = tableView.dequeueReusableCell(withIdentifier: "InfoTableViewCell") as? InfoTableViewCell
            infoCell?.profileImage?.tag = indexPath.row
            infoCell?.selectionStyle = .none
            infoCell?.leading.constant = 5
            if indexPath.row == 0{
                infoCell?.configure(name: loggedUserName, imageStr: imagesArray[indexPath.row], deviceStatus: deviceStatus)
            } else if indexPath.row == 1 && selectedSite != nil{
                infoCell?.configure(name: selectedSite!.siteName, imageStr: imagesArray[indexPath.row], deviceStatus: "")
            }
            cell = infoCell!
        } else if indexPath.section == 1{
            let profileCell = tableView.dequeueReusableCell(withIdentifier: "ProfileTableViewCell") as? ProfileTableViewCell
            profileCell?.delegate = self
            cell = profileCell!
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? UITableView.automaticDimension : 500
    }
}

extension ProfileViewController:ProfileTableViewCellDelegate{
    func selectedSegment(value: String) {
        selectedSegmentStr = value
    }
}
