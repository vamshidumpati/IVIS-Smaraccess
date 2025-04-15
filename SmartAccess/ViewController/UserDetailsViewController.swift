//
//  UserDetailsViewController.swift
//  SmartAccess
//
//  Created by Vamshirkishna on 09/04/25.
//

import UIKit

class UserDetailsViewController: UIViewController {
    @IBOutlet weak var detailsTableView: UITableView!
    
    var data:[String:Any] = [:]
    var deviceStatus:String?
    var selectedNames: [Int: String] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindDeviceData()
        detailsTableView.allowsSelection = true
        detailsTableView.delegate = self
        detailsTableView.register(UINib(nibName: "InfoTableViewCell", bundle: nil), forCellReuseIdentifier: "InfoTableViewCell")
        detailsTableView.register(UINib(nibName: "DropDownTableViewCell", bundle: nil), forCellReuseIdentifier: "DropDownTableViewCell")
        detailsTableView.separatorStyle = .none
        detailsTableView.estimatedRowHeight = 50
        // Do any additional setup after loading the view.
        self.navigationItem.hidesBackButton = true
    }
    
    @IBAction func onTapNext(_ sender: Any) {
        let faceIDVC = self.storyboard?.instantiateViewController(withIdentifier: "FaceBlinkViewController") as? FaceBlinkViewController
        self.navigationController?.pushViewController(faceIDVC!, animated: true)
    }
    
    func bindDeviceData(){
        data["ASite Name"] = DataStore.shared.vaultData?.ivisVault?.unit?.unitName ?? ""
        data["BAuth Type"] = DataStore.shared.vaultData?.ivisVaultConfiguration?.authenticationType ?? ""
        data["COTP Type"] = DataStore.shared.vaultData?.ivisVaultConfiguration?.otpType ?? ""
        data["DUser Type"] = DataStore.shared.vaultData?.userType ?? ""
        data["EBLE MAC"] = DataStore.shared.vaultData?.ivisVault?.macId ?? ""
        data["FDevice ID"] = DataStore.shared.vaultData?.ivisVault?.unit?.ivisunitId ?? ""
        data["GDevice Status"] = deviceStatus ?? ""
        
        let privaryUser = (DataStore.shared.vaultData?.primaryUserProfiles?[0].firstName ?? "") + " "  + (DataStore.shared.vaultData?.primaryUserProfiles?[0].lastName ?? "")
        data["H\(privaryUser)"] = "Primary user"
        let secondaryUser = (DataStore.shared.vaultData?.secondaryUserProfiles?[0].firstName ?? "") + " "  + (DataStore.shared.vaultData?.secondaryUserProfiles?[0].lastName ?? "")
        data["I\(secondaryUser)"] = "Secondary user"
        data["JN/A"] = ""
        
        DispatchQueue.main.async {
            self.detailsTableView.reloadData()
        }
    }
    
    func presentPicker(namesList:[String], forRow row: Int) {
        let pickerVC = PickerModalViewController()
        pickerVC.options = namesList
        pickerVC.onOptionSelected = { [weak self] selected in
            self?.selectedNames[row] = selected
            self?.detailsTableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .automatic)
        }
        presentPanModal(pickerVC)  // Must use PanModal's presentation
    }
    
    func getNamesList(from profiles: [UserProfile]?) -> [String] {
        guard let profiles = profiles else { return [] }
        
        return profiles.compactMap { profile in
            let firstName = profile.firstName ?? ""
            let lastName = profile.lastName ?? ""
            let fullName = "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
            return fullName.isEmpty ? nil : fullName
        }
    }
}

extension UserDetailsViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.keys.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        let keys = Array(data.keys).sorted()
        var keyString = keys[indexPath.row]
        keyString.removeFirst()
        if indexPath.row > 6{
            let dropDownCell = tableView.dequeueReusableCell(withIdentifier: "DropDownTableViewCell") as? DropDownTableViewCell
            if let selectedName = selectedNames[indexPath.row] {
                dropDownCell?.nameLbl?.text = selectedName  // previously selected name
            } else {
                dropDownCell?.nameLbl.text = "\(keyString)"
            }
            dropDownCell?.contentView.isUserInteractionEnabled = true
            dropDownCell?.isUserInteractionEnabled = true

            // Extract user type from the key string
            let userType = data[keys[indexPath.row]] as? String ?? ""
            if userType == "Primary user"{
                  let numberOfPrimaryUsers = DataStore.shared.vaultData?.primaryUserProfiles?.count ?? 0
                  let shouldEnable = numberOfPrimaryUsers > 1
                  dropDownCell?.contentView.alpha = shouldEnable ? 1.0 : 0.5
                  dropDownCell?.nameLbl.alpha = shouldEnable ? 1.0 : 0.5
              } else if userType == "Secondary user" {
                  let numberOfSecondaryUsers = DataStore.shared.vaultData?.secondaryUserProfiles?.count ?? 0
                  let shouldEnable = numberOfSecondaryUsers > 1
                  dropDownCell?.contentView.alpha = shouldEnable ? 1.0 : 0.5
                  dropDownCell?.nameLbl.alpha = shouldEnable ? 1.0 : 0.5
              } else {
                  dropDownCell?.contentView.alpha = 0.5
                  dropDownCell?.nameLbl.alpha = 0.5
              }
            cell = dropDownCell!
        } else {
            let infoCell = tableView.dequeueReusableCell(withIdentifier: "InfoTableViewCell") as? InfoTableViewCell
            infoCell?.leading.constant = 0
            infoCell?.imageViewWidth.constant = 5
            infoCell?.profileName.text = "\(keyString) : \(data["\(keys[indexPath.row])"] ?? "")"
            cell = infoCell!
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let keys = Array(data.keys).sorted()
        let userType = data[keys[indexPath.row]] as? String ?? ""
        if userType == "Primary user"{
            let primaryUsersList = getNamesList(from: DataStore.shared.vaultData?.primaryUserProfiles)
            if primaryUsersList.count > 1{
                presentPicker(namesList: primaryUsersList, forRow: indexPath.row)
            }
        } else if userType == "Secondary user"{
            let secondaryUserList = getNamesList(from: DataStore.shared.vaultData?.secondaryUserProfiles)
            if secondaryUserList.count > 1{
                presentPicker(namesList: secondaryUserList, forRow: indexPath.row)
            }
        } else {
            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
