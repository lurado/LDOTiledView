//
//  DetailViewController.swift
//  LDOTiledView Example
//
//  Created by Sebastian Ludwig on 29.05.19.
//  Copyright © 2019 Julian Raschke und Sebastian Ludwig GbR. All rights reserved.
//

import UIKit
import LDOTiledView

class DetailViewController: UIViewController {
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var tiledView: LDOTiledView!
    @IBOutlet private weak var zoomLevelLabel: UILabel!
    @IBOutlet private weak var zoomScaleLabel: UILabel!
    @IBOutlet private weak var contentSizeLabel: UILabel!
    @IBOutlet private weak var debugSwitch: UISwitch!
    @IBOutlet private weak var creditLabel: UILabel!
    
    var imageName: String?
    var imageSize: CGSize?
    var maximumZoomLevel: Int?
    var fileExtension = "jpeg"
    var credit: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        creditLabel.text = credit != nil ? "Credit: \(credit!)" : nil
        navigationItem.title = imageName!
        
        tiledView.imageSize = imageSize!
        tiledView.maximumZoomLevel = maximumZoomLevel!
        scrollView.maximumZoomScale = tiledView.maximumZoomScale
        // if you want to allow zooming to a non-retina resolution, set
        // scrollView.maximumZoomScale = LDOTiledView.zoomScale(forZoomLevel: CGFloat(tiledView.maximumZoomLevel + 2))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setToolbarHidden(false, animated: animated)
        updateUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setToolbarHidden(true, animated: animated)
    }
    
    private func updateUI() {
        let level = min(CGFloat(tiledView.maximumZoomLevel), LDOTiledView.zoomLevel(forZoomScale: scrollView.zoomScale))
        zoomLevelLabel.text = String(format: "level: %.02f", level)
        zoomScaleLabel.text = String(format: "scale: %.02f", scrollView.zoomScale)
        contentSizeLabel.text = String(format: "size: %.fx%.f", scrollView.contentSize.width, scrollView.contentSize.height)
        debugSwitch.isOn = tiledView.debugAnnotateTiles
    }
    
    @IBAction func toggleDebugAnnotateTiles() {
        tiledView.debugAnnotateTiles = debugSwitch.isOn
    }
}

extension DetailViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return tiledView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateUI()
    }
}

extension DetailViewController: LDOTiledViewDataSource {
    func tiledView(_ tiledView: LDOTiledView, tileForRow row: Int, column: Int, zoomLevel: Int) -> UIImage? {
        let relativePath = "tiles/\(imageName!)/\(Int(UIScreen.main.scale))x/\(zoomLevel)/\(column)_\(row).\(fileExtension)"
        let url = Bundle.main.bundleURL.appendingPathComponent(relativePath)
        
        guard let data = try? Data(contentsOf: url, options: .mappedIfSafe) else { return nil }
        
        return UIImage(data: data)
    }
}
