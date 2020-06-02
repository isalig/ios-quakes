//
//  MapViewController.swift
//  Quakes
//
//  Created by Ischuk Alexander on 03.06.2020.
//  Copyright © 2020 Ischuk Alexander. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var progress: UIActivityIndicatorView!
    
    var apiClient : ApiClient  {
        return provideAppDelegate().apiClient
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadLocations()
    }
    
    func loadLocations() {
        togglePreloader(isVisible: true)
        
        let dateFormatter = DateFormatter()
        dateFormatter.setLocalizedDateFormatFromTemplate("yyyy-MM-dd")
        let today = Date()
        
        let dateFrom = dateFormatter.string(from: Calendar.current.date(byAdding: .day, value: -1, to: today)!)
        let dateTo = dateFormatter.string(from: today)
        
        apiClient.loadEarthquakes(dateFrom: dateFrom, dateTo: dateTo,result: { (earthquakes, error) in
            if error != nil {
                self.showAlert(alertMessage: self.getAlertDataFromError(error: error!), buttonTitle: "Ok", presenter: self)
                self.togglePreloader(isVisible: false)
                return
            }
            
            var annotations = [MKPointAnnotation]()
            
            for earthquake in earthquakes! {
                let lat = CLLocationDegrees(earthquake.latitude)
                let long = CLLocationDegrees(earthquake.longitude)
                
                let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotation.title = earthquake.id
                annotation.subtitle = earthquake.title
                annotations.append(annotation)
            }
            
            DispatchQueue.main.async {
                self.mapView.removeAnnotations(self.mapView.annotations)
                self.mapView.addAnnotations(annotations)
                self.togglePreloader(isVisible: false)
            }
            
            
        })
    }
    
    func togglePreloader(isVisible: Bool) {
        progress.isHidden = !isVisible
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let detailController = storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
            detailController.earthquakeId = view.annotation?.title!
            navigationController?.showDetailViewController(detailController, sender: self)
        }
    }
}
