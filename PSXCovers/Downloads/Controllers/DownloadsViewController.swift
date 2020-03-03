//
//  DownloadsViewController.swift
//  PSXCovers
//
//  Created by Digital on 03/03/2020.
//  Copyright © 2020 digitalby. All rights reserved.
//

import UIKit

class DownloadsViewController: UIViewController {
    @IBOutlet var downloadsTableView: UITableView!
    @IBOutlet var noItemsView: NoItemsView!

    lazy var tableViewHelper = DownloadsTableViewHelper(viewController: self)

    override func viewDidLoad() {
        super.viewDidLoad()
        downloadsTableView.dataSource = tableViewHelper
        downloadsTableView.delegate = tableViewHelper
    }
}
