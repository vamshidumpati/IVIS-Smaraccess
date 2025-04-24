//
//  SitesViewController.swift
//  SmartAccess
//
//  Created by Vamshirkishna on 07/04/25.
//

import UIKit
import SVProgressHUD

class SitesViewController: UIViewController {
    @IBOutlet weak var logoView: UIView!
    @IBOutlet weak var sitesTableView: UITableView!
    @IBOutlet weak var siteSearchBar: UISearchBar!
    @IBOutlet weak var logoutBtn: UIButton!
    
    var siteListResponse: SiteResponseModel!
    var sitesData: [Site] = []
    var filterdData: [Site] = []
        
    override func viewDidLoad() {
        super.viewDidLoad()
        sitesTableView.delegate = self
        sitesTableView.dataSource = self
        siteSearchBar.delegate = self
        sitesTableView.estimatedRowHeight = 40
        sitesTableView.rowHeight = UITableView.automaticDimension
        self.view.bringSubviewToFront(logoutBtn)
        bindSiteList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        siteSearchBar.resignFirstResponder()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        logoView.applyBottomBorderAndShadow()
    }
    
    
    func bindSiteList() {
        guard let userName = DataStore.shared.userAuth?.username,
              let tokenStr = DataStore.shared.userAuth?.accessToken,
              let customerName = DataStore.shared.userAuth?.mappedCustomers?[0].customerName,
              let customerId =  DataStore.shared.userAuth?.mappedCustomers?[0].pkCustomerId,
              let fkTenantId =  DataStore.shared.userAuth?.mappedCustomers?[0].fkTenantId else {
            return
        }
        SVProgressHUD.show()
        NetworkManager.fetchSiteList(
            userName: userName,
            token: tokenStr,
            customerId: customerId.description,
            customerName: customerName,
            tenantId: fkTenantId.description
        ) { result in
            switch result {
            case .success(let response):
                self.siteListResponse = response
                self.filterdData = response.results.sitesList
                self.sitesData = self.filterdData
            case .failure(let error):
                print("API Error: \(error.localizedDescription)")
                let alert = UIAlertController(
                    title: "Sorry",
                    message: "Something went wrong, please try again later.",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            }
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                self.sitesTableView.reloadData()
            }
        }
    }
    @IBAction func onTapLogoutAction(_ sender: Any) {
        let accountVC = AccountViewController() // Recreate if needed
        navigationController?.setViewControllers([accountVC], animated: true)
    }
}

extension SitesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterdData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SiteCell", for: indexPath) as? SiteCell else {
            fatalError("SiteCell not registered or incorrect class")
        }
        cell.siteName.font = UIFont(name: "Lato-medium", size: 14.0)
        if !filterdData.isEmpty{
            cell.siteName.text = filterdData[indexPath.row].siteName
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedSite = filterdData[indexPath.row]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vaultAccessVC = storyboard.instantiateViewController(withIdentifier: "ProfileViewController") as? ProfileViewController
        vaultAccessVC?.selectedSite = selectedSite
        self.navigationController?.pushViewController(vaultAccessVC!, animated: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.filterdData = sitesData
        self.siteSearchBar.text = ""
        self.siteSearchBar.resignFirstResponder()
        sitesTableView.reloadData()
    }
}

extension SitesViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            // Show all data when search is cleared
            filterdData = sitesData
        } else {
            // Always search in the full original list
            filterdData = sitesData.filter {
                $0.siteName.lowercased().contains(searchText.lowercased())
            }
        }

        DispatchQueue.main.async {
            self.sitesTableView.reloadData()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder() // Dismisses the keyboard
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        filterdData = sitesData
        sitesTableView.reloadData()
    }
}






