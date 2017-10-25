//
//  ViewController.swift
//  testCluster
//
//  Created by 佐藤和希 on 2017/10/25.
//  Copyright © 2017 Kaz. All rights reserved.
//

import UIKit
import GoogleMaps

class MarkerItem: NSObject, GMUClusterItem {
    var position: CLLocationCoordinate2D //必須
    
    init(position: CLLocationCoordinate2D) {
        self.position = position
    }
}

// 新宿フロントタワー
let cameraLatitude = 35.695978
let cameraLongitude = 139.689340

class MapViewController: UIViewController, GMUClusterManagerDelegate, GMSMapViewDelegate {
    private let camera = GMSCameraPosition.camera(withLatitude: cameraLatitude,
                                                  longitude: cameraLongitude, zoom: 15)
    private let mapView = GMSMapView.init(frame: CGRect.zero)
    
    private lazy var clusterManager: GMUClusterManager = {
        let iconGenerator = GMUDefaultClusterIconGenerator()
        let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
        let renderer = GMUDefaultClusterRenderer(mapView: self.mapView, clusterIconGenerator: iconGenerator)
        return GMUClusterManager(map: self.mapView, algorithm: algorithm, renderer: renderer)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapView.camera = camera
        self.view = self.mapView
        
        // Marker × 1000 ランダム座標を生成し、ClusterManagerにadd
        for _ in 0...1000 {
            let extent = 0.1
            let latitude = cameraLatitude + extent * randomScale()
            let longitude = cameraLongitude + extent * randomScale()
            clusterManager.add(MarkerItem.init(position: CLLocationCoordinate2DMake(latitude, longitude)))
        }
        
        // MarkerItemをClusteringし、地図にプロット
        clusterManager.cluster()
        
        // GMUClusterManagerDelegate + GMSMapViewDelegateを設定
        clusterManager.setDelegate(self, mapDelegate: self)
    }
    
    // MARK: - GMUMapViewDelegate
    
    // Marker or Cluster Markerがタップされた
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if marker.userData is MarkerItem {
            debugPrint("ClusterのMarkerItemがタップされた")
        } else {
            debugPrint("通常のMarkerがタップされた")
        }
        return false
    }
    
    // MARK: - GMUClusterManagerDelegate
    
    // Clusterがタップされたたら、Camera Positionを移動
    func clusterManager(_ clusterManager: GMUClusterManager, didTap cluster: GMUCluster) {
        let newCamera = GMSCameraPosition.camera(withTarget: cluster.position,
                                                 zoom: mapView.camera.zoom + 1)
        let update = GMSCameraUpdate.setCamera(newCamera)
        mapView.moveCamera(update)
    }
    
    
    private func randomScale() -> Double {
        return Double(arc4random()) / Double(UINT32_MAX) * 2.0 - 1.0
    }
    
}
