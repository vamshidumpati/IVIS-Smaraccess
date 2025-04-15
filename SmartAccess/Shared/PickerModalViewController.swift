//
//  PickerModalViewController.swift
//  SmartAccess
//
//  Created by Vamshirkishna on 14/04/25.
//

import UIKit
import PanModal

class PickerModalViewController: UIViewController, PanModalPresentable {
    
    var options: [String] = []
    var onOptionSelected: ((String) -> Void)?
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.isScrollEnabled = false  // disables scroll
        table.delegate = self
        table.dataSource = self
        table.tableFooterView = UIView()
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - PanModalPresentable
    var panScrollable: UIScrollView? { nil }
    
    var shortFormHeight: PanModalHeight {
        return .contentHeight(CGFloat(options.count * 50)) // 50 is row height
    }
    
    var longFormHeight: PanModalHeight {
        return shortFormHeight
    }
}

extension PickerModalViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = options[indexPath.row]
        cell.textLabel?.textAlignment = .center
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        onOptionSelected?(options[indexPath.row])
        dismiss(animated: true)
    }
}


