//
//  ListViewController.swift
//  LDOTiledView Example
//
//  Created by Sebastian Ludwig on 31.05.19.
//  Copyright © 2019 Julian Raschke und Sebastian Ludwig GbR. All rights reserved.
//

import UIKit

class ListViewController: UITableViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destination = segue.destination as? DetailViewController else { return }
        if segue.identifier == "showCheckerboard" {
            destination.imageName = "Checkerboard"
            destination.imageSize = CGSize(width: 512, height: 1024)
            destination.maximumZoomLevel = 3
            destination.fileExtension = "png"
        } else if segue.identifier == "showEarth" {
            destination.imageName = "Earth"
            destination.imageSize = CGSize(width: 450, height: 450)
            destination.maximumZoomLevel = 4
            destination.credit = "NASA Earth Observatory image by Robert Simmon"
        }
    }
}
