//
//  ProfileTableViewCell.swift
//  SmartAccess
//
//  Created by Vamshirkishna on 08/04/25.
//

import UIKit
protocol ProfileTableViewCellDelegate:AnyObject{
    func selectedSegment(value:String)
}


class ProfileTableViewCell: UITableViewCell {
    @IBOutlet weak var profileCollectionView: UICollectionView!
    
    var data = ["Customer","Audit","Vigilance","Packet Counting","Others"]
    var selectedSegment = ""
    
    weak var delegate:ProfileTableViewCellDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        profileCollectionView.delegate = self
        profileCollectionView.dataSource = self
        profileCollectionView.setCollectionViewLayout(layout, animated: false)
        profileCollectionView.register(UINib(nibName: "VaultReasonCollectionCell", bundle: nil), forCellWithReuseIdentifier: "VaultReasonCollectionCell")
        profileCollectionView.register(UINib(nibName: "VaultCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "VaultCollectionViewCell")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        profileCollectionView.collectionViewLayout.invalidateLayout()
    }
}

extension ProfileTableViewCell:UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VaultCollectionViewCell", for: indexPath) as? VaultCollectionViewCell
        cell?.configureData(name: data[indexPath.row])
        if selectedSegment == data[indexPath.row]{
            cell?.checkBtn.tintColor =  UIColor.green
        } else{
            cell?.checkBtn.tintColor = UIColor(hex: "#1692DF")
        }
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if selectedSegment != data[indexPath.row]{
            selectedSegment = data[indexPath.row]
            delegate?.selectedSegment(value: selectedSegment)
        } else {
            selectedSegment = ""
            delegate?.selectedSegment(value: selectedSegment)
        }
        collectionView.reloadData()
    }
    
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        let spacing = 5.0
        let sectionInsets = layout.sectionInset
        
        let width = collectionView.bounds.width
        let height = collectionView.bounds.height
        let availableWidth = width - sectionInsets.left - sectionInsets.right
        
        var numberOfCellsInRow: CGFloat = 2

        if width > height {
            // Landscape: Fit as many cells as possible with minimum 185pt width
            let fixedCellWidth: CGFloat = 180
            numberOfCellsInRow = floor(availableWidth / (fixedCellWidth))
        }
        
        let totalSpacing = spacing * (numberOfCellsInRow)
        let actualCellWidth = (availableWidth - totalSpacing) / numberOfCellsInRow
        let cellHeight = actualCellWidth * 0.6// Or a fixed height if preferred
        
        return CGSize(width: actualCellWidth, height: cellHeight)
    }
}
