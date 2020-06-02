//
//  NetworkStruct.swift
//  Quakes
//
//  Created by Ischuk Alexander on 03.06.2020.
//  Copyright © 2020 Ischuk Alexander. All rights reserved.
//

import Foundation

struct EarthquakeResult: Codable {
    let features: [Feature]
}

struct Feature: Codable {
    let properties: Properties
    let geometry: Geometry
    let id: String
}

struct Properties: Codable {
    let title: String
    let place: String
    let products: Products?
    let time: Date
}


struct Geometry: Codable {
    let coordinates: [Double]
}

struct EarthquakeItem: Codable {
    let id: String
    let title: String
    let latitude: Double
    let longitude: Double
}


struct EarthquakeNetworkDetail: Codable{
    let properties: Properties
    let geometry: Geometry
    let id: String
}

struct Products: Codable {
    let origin: [Origin]
}

struct Origin: Codable {
    let properties: OriginProperties
}

struct OriginProperties: Codable {

    let azimuthalGap: String
    let depth: String
    let magnitude: String
    let magnitudeError: String
    let magnitudeType: String
    let numPhasesUsed: String
    
    enum OriginPropertiessCodingKeys: String, CodingKey {
        case azimuthalGap = "azimuthal-gap"
        case depth = "depth"
        case magnitude = "magnitude"
        case magnitudeError = "magnitude-error"
        case magnitudeType = "magnitude-type"
        case numPhasesUsed = "num-phases-used"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: OriginPropertiessCodingKeys.self)
        
        azimuthalGap = (try? container.decode(String.self, forKey: .azimuthalGap) as String?) ?? ""
        depth = try container.decode(String.self, forKey: .depth)
        magnitude = try container.decode(String.self, forKey: .magnitude)
        magnitudeError = (try? container.decode(String.self, forKey: .magnitudeError) as String?) ?? ""
        magnitudeType = try container.decode(String.self, forKey: .magnitudeType)
        numPhasesUsed = try container.decode(String.self, forKey: .numPhasesUsed)
    }
}
