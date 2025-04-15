//
//  MenuViewController.swift
//  SmartAccess
//
//  Created by Vamshirkishna on 07/04/25.
//

import UIKit

class MenuViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
    }

    
    func setupTabs() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        // Instantiate SitesViewController from Storyboard using its Storyboard ID
        let sitesVC = storyboard.instantiateViewController(withIdentifier: "SitesViewController") as! SitesViewController
        let nav1 = UINavigationController(rootViewController: sitesVC)
        nav1.tabBarItem = UITabBarItem(title: "Sites", image: UIImage(systemName: "building.fill"), tag: 0)

        // If ProfileViewController is from storyboard, load it the same way
        let profileVC = storyboard.instantiateViewController(withIdentifier: "UserProfileViewController") as! UserProfileViewController
        let nav2 = UINavigationController(rootViewController: profileVC)
        nav2.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "profile.fill.checkmark"), tag: 1)

        self.viewControllers = [nav1, nav2]
        
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(hex: "#F3F3F3")

        let blackTextAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Lato-Medium", size: 14.0)!,
            .foregroundColor: UIColor.gray
        ]

        let selectedTextAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Lato-Bold", size: 16.0)!,
            .foregroundColor: UIColor.black
        ]


        // Set same black text for both states
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = selectedTextAttributes
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = blackTextAttributes

        // Set icon tint
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor.black
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.black

        tabBar.standardAppearance = appearance
    }
}
