//
//  DetailViewController.swift
//  Quakes
//
//  Created by Ischuk Alexander on 03.06.2020.
//  Copyright © 2020 Ischuk Alexander. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class DetailViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var magnitudeValueLabel: UILabel!
    @IBOutlet weak var magnitudeUncertValueLabel: UILabel!
    @IBOutlet weak var locationValueLabel: UILabel!
    @IBOutlet weak var placeValueLabel: UILabel!
    @IBOutlet weak var azimutGapValueLabel: UILabel!
    @IBOutlet weak var phasesValueLabel: UILabel!
    @IBOutlet weak var prelaoder: UIActivityIndicatorView!
    
    var apiClient : ApiClient  {
        return provideAppDelegate().apiClient
    }
    
    var dataController: DataController {
        return provideAppDelegate().dataController
    }
    
    var earthquakeId: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadDetailedData()
    }
    
    func loadDetailedData() {
        
        let fetchRequest: NSFetchRequest<Earthquake> = Earthquake.fetchRequest()
        let predicate1 = NSPredicate(format: "id = %@", earthquakeId)
        let predicate2 = NSPredicate(format: "hasDetails = true", earthquakeId)
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2])
        
        if let result = try? dataController.viewContext.fetch(fetchRequest) {
            if (result.count > 0) {
                DispatchQueue.main.async {
                    self.setData(earthquake: result[0])
                    self.togglePreloader(isVisible: false)
                }
            } else {
                self.loadDataFromNetwork()
            }
            
        } else {
            loadDataFromNetwork()
        }
    }
    
    func loadDataFromNetwork() {
        apiClient.loadDetails(id: earthquakeId) { (earthquake, error) in
            guard error == nil else {
                self.showAlert(alertMessage: self.getAlertDataFromError(error: error!), buttonTitle: "Ok", presenter: self);
                return
                
            }
            
            DispatchQueue.main.async {
                self.setData(earthquake: earthquake!)
                self.togglePreloader(isVisible: false)
            }
        }
    }
    
    func setData(earthquake: Earthquake) {
        self.titleLabel.text = earthquake.title
        self.magnitudeValueLabel.text = earthquake.magnitude
        self.magnitudeUncertValueLabel.text = earthquake.magnitudeError!
        self.locationValueLabel.text = "\(String(format:"%f", earthquake.latitude)), \(String(format:"%f", earthquake.longitude))"
        self.placeValueLabel.text =  earthquake.place
        self.azimutGapValueLabel.text = earthquake.gap
        self.phasesValueLabel.text = earthquake.numberOfPhases
        
        let lat = CLLocationDegrees(earthquake.latitude)
        let long = CLLocationDegrees(earthquake.longitude)
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        mapView.setCenter(coordinate, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        togglePreloader(isVisible: true)
    }
    
    func togglePreloader(isVisible: Bool) {
        prelaoder.isHidden = !isVisible
    }
}
