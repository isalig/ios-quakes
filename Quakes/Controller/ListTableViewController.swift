//
//  ListTableViewController.swift
//  Quakes
//
//  Created by Ischuk Alexander on 03.06.2020.
//  Copyright © 2020 Ischuk Alexander. All rights reserved.
//

import UIKit
import CoreData

class ListTableViewController: UITableViewController {
    
    var earthquakes = [Earthquake]()
    
    var dataController: DataController {
        return provideAppDelegate().dataController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let fetchRequest: NSFetchRequest<Earthquake> = Earthquake.fetchRequest()
        let sortDescriptot = NSSortDescriptor(key: "time", ascending: false)
        
        let today = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.setLocalizedDateFormatFromTemplate("yyyy-MM-dd")
        let dateTo = dateFormatter.string(from: today)
        
        let predicate = NSPredicate(format: "time = %@", dateTo)
        
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [sortDescriptot]
        
        if let result = try? dataController.viewContext.fetch(fetchRequest) {
            earthquakes = result
            tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return earthquakes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "earthquakeCell")!
        let earthquake = earthquakes[indexPath.row]
        
        cell.textLabel?.text = earthquake.title
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let earthquake = earthquakes[indexPath.row]
        
        let detailController = storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        detailController.earthquakeId = earthquake.id
        navigationController?.showDetailViewController(detailController, sender: self)
    }
}
