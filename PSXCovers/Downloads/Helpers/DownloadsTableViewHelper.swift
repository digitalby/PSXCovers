//
//  DownloadsTableViewHelper.swift
//  PSXCovers
//
//  Created by Digital on 03/03/2020.
//  Copyright © 2020 digitalby. All rights reserved.
//

import UIKit

class DownloadsTableViewHelper: NSObject, UITableViewDataSource, UITableViewDelegate {
    weak var viewController: DownloadsViewController? = nil

    init(viewController: DownloadsViewController) {
        self.viewController = viewController
    }
}

//MARK: - Data Source
extension DownloadsTableViewHelper {
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "DownloadCell", for: indexPath)
    }
}

//MARK: - Delegate
extension DownloadsTableViewHelper {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alert = UIAlertController(title: "Delegate", message: "You selected a cell at \(indexPath)", preferredStyle: .alert)
        let buttonOk = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(buttonOk)
        viewController?.present(alert, animated: true)
    }
}
