//
//  VaultAccessViewController.swift
//  SmartAccess
//
//  Created by Vamshirkishna on 08/04/25.
//

import UIKit

class VaultAccessViewController: UIViewController {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var siteImage: UIImageView!
    @IBOutlet weak var siteNameLabel: UILabel!
    @IBOutlet weak var vaultCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        vaultCollectionView.collectionViewLayout = layout
        vaultCollectionView.delegate = self
        vaultCollectionView.dataSource = self
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        vaultCollectionView.collectionViewLayout.invalidateLayout()
    }
}

extension VaultAccessViewController:UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        collectionView.register(UINib(nibName: "VaultCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "VaultCollectionViewCell")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VaultCollectionViewCell", for: indexPath) as? VaultCollectionViewCell
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                          sizeForItemAt indexPath: IndexPath) -> CGSize {
          
          let isPad = UIDevice.current.userInterfaceIdiom == .pad
          let numberOfItemsPerRow: CGFloat = isPad ? 4 : 2  // You can increase for iPad
          let spacing: CGFloat = 10

          let totalSpacing = (numberOfItemsPerRow - 1) * spacing
          let availableWidth = collectionView.bounds.width - totalSpacing
          let itemWidth = floor(availableWidth / numberOfItemsPerRow)

          return CGSize(width: itemWidth, height: 100) // Adjust height as needed
      }
}

