//
//  LocationSearchTable.swift
//  LocationAlarm
//
//  Created by Gabriella Lopes on 3/29/16.
//  Copyright © 2016 Ana Carolina Nascimento. All rights reserved.
//



import UIKit
import MapKit

class LocationSearchTable : UITableViewController
{
  
    var matchingItems:[MKMapItem] = []
    var mapView: MKMapView? = nil
    var handleMapSearchDelegate:HandleMapSearch? = nil
  
    //TODO: Ajeitar para estrutura de endereços brasileira
    func parseAddress(selectedItem:MKPlacemark) -> String
    {
        // put a space between "4" and "Melrose Place"
        let firstSpace = (selectedItem.subThoroughfare != nil && selectedItem.thoroughfare != nil) ? " " : ""
        // put a comma between street and city/state
        let comma = (selectedItem.subThoroughfare != nil || selectedItem.thoroughfare != nil) && (selectedItem.subAdministrativeArea != nil || selectedItem.administrativeArea != nil) ? ", " : ""
        // put a space between "Washington" and "DC"
        let secondSpace = (selectedItem.subAdministrativeArea != nil && selectedItem.administrativeArea != nil) ? " " : ""
        let addressLine = String(
            format:"%@%@%@%@%@%@%@",
            // street number
            selectedItem.thoroughfare ?? "",
            firstSpace,
            // street name
            selectedItem.subThoroughfare ?? "",
            comma,
            // city
            selectedItem.locality ?? "",
            secondSpace,
            // state
            selectedItem.administrativeArea ?? "")
    
        return addressLine
    }
  
}

extension LocationSearchTable : UISearchResultsUpdating
{
 
    func updateSearchResultsForSearchController(searchController: UISearchController)
    {
        guard let mapView = mapView,
        let searchBarText = searchController.searchBar.text else { return }
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchBarText
        //request.region = mapView.region
        request.region = MKCoordinateRegionMakeWithDistance(mapView.userLocation.location!.coordinate,
                                                            120701, 120701);
        let search = MKLocalSearch(request: request)
        search.startWithCompletionHandler
            { response, _ in
                guard let response = response else
                {return}
      
                self.matchingItems = response.mapItems
                self.tableView.reloadData()
            }
        
    }
  
}

extension LocationSearchTable
{
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
    return matchingItems.count
    }
  
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
    let cell = tableView.dequeueReusableCellWithIdentifier("cell")!
    let selectedItem = matchingItems[indexPath.row].placemark
    cell.textLabel?.text = selectedItem.name
    cell.detailTextLabel?.text = parseAddress(selectedItem)
    return cell
    }
}

extension LocationSearchTable
{
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let selectedItem = matchingItems[indexPath.row].placemark
        handleMapSearchDelegate?.dropPinZoomIn(selectedItem)
        dismissViewControllerAnimated(true, completion: nil)
    }
}
