//
//  ApiClient.swift
//  Quakes
//
//  Created by Ischuk Alexander on 03.06.2020.
//  Copyright © 2020 Ischuk Alexander. All rights reserved.
//

import Foundation

class ApiClient {
    
    let dataController: DataController!
    let mapper: NetworkResultMapper!
    
    init(dataController: DataController) {
        self.dataController = dataController
        self.mapper = NetworkResultMapper(dataController: dataController)
    }
    
    enum ApiEndpoint {
        static let baseUrl = "https://earthquake.usgs.gov/fdsnws/event/1/query"
        case list(dateFrom: String, dateTo: String)
        case detail(id: String)
    }
    
    enum ApiError: Error {
        case networkError
        case decodingError
    }
    
    func getUrl(for endpoint: ApiEndpoint) -> String {
        switch endpoint {
        case .list(let dateFrom, let dateTo):
            return "\(ApiEndpoint.baseUrl)?format=geojson&starttime=\(dateFrom)&endtime=\(dateTo)&eventtype=earthquake"
        case .detail(let id):
            return "\(ApiEndpoint.baseUrl)?eventid=\(id)&format=geojson"
        }
    }
    
    func loadEarthquakes(dateFrom: String, dateTo: String, result: @escaping ([Earthquake]?, ApiError?) -> Void) {
        doGetRequest(endpoint: .list(dateFrom: dateFrom, dateTo: dateTo), result: {(networkResult: EarthquakeResult?, error) in
            guard error == nil else {result(nil, error); return}
            let items = self.mapper.map(network: networkResult!)
            result(items, nil)
        })
    }
    
    func loadDetails(id: String, result: @escaping (Earthquake?, ApiError?) -> Void) {
        doGetRequest(endpoint: .detail(id: id)) { (earthquakeNetwork: EarthquakeNetworkDetail?, error) in
            guard error == nil else {result(nil, error); return}
            let earthquake = self.mapper.map(network: earthquakeNetwork!)
            result(earthquake, nil)
        }
    }
    
    func doGetRequest<ResponseType: Decodable>(endpoint: ApiEndpoint, result: @escaping (ResponseType?, ApiError?) -> Void) {
        let request = URLRequest(url: URL(string: getUrl(for: endpoint))!)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil {
                result(nil, .networkError)
                return
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            
            guard data != nil else {
                result(nil, .networkError)
                return
            }
            
            do {
                let decoded = try decoder.decode(ResponseType.self, from: data!)
                result(decoded, nil)
            } catch {
                print(error)
                result(nil, .decodingError)
            }
        }
        task.resume()
    }
}
