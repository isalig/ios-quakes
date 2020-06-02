//
//  NetworkResultMapper.swift
//  Quakes
//
//  Created by Ischuk Alexander on 03.06.2020.
//  Copyright © 2020 Ischuk Alexander. All rights reserved.
//

import Foundation

class NetworkResultMapper {
    
    var dataController: DataController!
    
    init(dataController: DataController) {
        self.dataController = dataController
    }
    
    func map(network: EarthquakeResult) -> [Earthquake] {
        var items = [Earthquake]()
        let today = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.setLocalizedDateFormatFromTemplate("yyyy-MM-dd")
        let dateTo = dateFormatter.string(from: today)
        
        network.features.forEach { (feature) in
            let earthquake = Earthquake(context: dataController.viewContext)
            earthquake.id = feature.id
            earthquake.title = feature.properties.title
            earthquake.latitude = feature.geometry.coordinates[1]
            earthquake.longitude = feature.geometry.coordinates[0]
            earthquake.hasDetails = false
            earthquake.time = dateTo
            items.append(earthquake)
        }
        
        try? dataController.viewContext.save()
        return items
    }
    
    func map(network: EarthquakeNetworkDetail) -> Earthquake {
        let earthquake = Earthquake(context: dataController.viewContext)
        earthquake.title = network.properties.title
        earthquake.id = network.id
        earthquake.latitude = network.geometry.coordinates[1]
        earthquake.longitude = network.geometry.coordinates[0]
        earthquake.gap = network.properties.products?.origin[0].properties.azimuthalGap
        earthquake.depth = network.properties.products?.origin[0].properties.depth
        earthquake.magnitude = network.properties.products?.origin[0].properties.magnitude
        earthquake.magnitudeError = network.properties.products?.origin[0].properties.magnitudeError
        earthquake.numberOfPhases = network.properties.products?.origin[0].properties.numPhasesUsed
        earthquake.place = network.properties.place
        
        try? dataController.viewContext.save()
        return earthquake
    }
}
