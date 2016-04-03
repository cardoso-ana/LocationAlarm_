//
//  ViewController.swift
//  LocationAlarm
//
//  Created by Ana Carolina Nascimento on 3/29/16.
//  Copyright © 2016 Ana Carolina Nascimento. All rights reserved.
//

import UIKit
import Foundation
import MapKit
import CoreLocation
import MediaPlayer

protocol HandleMapSearch
{
    func dropPinZoomIn(placemark:MKPlacemark)
}


// Coordenadas uteis
// -22.97976, -43.23282 PUC

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, MPMediaPickerControllerDelegate
{
    @IBOutlet weak var musicButton: UIButton!
    @IBOutlet weak var activeButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var labelDistancia: UILabel!
    @IBOutlet weak var imageDim: UIImageView!
    var mediaItem: MPMediaItem?
  
  
  
    var selectedPin:MKPlacemark? = nil
  
    var navigationBar: UINavigationBar!
    var firstTime = true
    var raioAlarme: MKCircle?
    var pinAlarm = false
    let distanciaRaio:CLLocationDistance = 100
    var resultSearchController:UISearchController? = nil
    let map = Map()
    var alarmeAtivado = false
    var locationManager = CLLocationManager()
    let regionRadius: CLLocationDistance = 1000
  
    let movimentoDrag = UIPanGestureRecognizer()
    let tapGestureRecognizer = UITapGestureRecognizer()
  
  
  
  override func viewDidAppear(animated: Bool)
  {
    super.viewDidAppear(true)
    map.locationManagerInit()
  }
  
  func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
    if firstTime == true
    {
      self.mapView.setRegion(map.userLocation(locationManager, location: locationManager.location!), animated: true)
      firstTime = false
    }
    
    if alarmeAtivado == true
    {
      
      let lugarDois = CLLocation(latitude: (raioAlarme?.coordinate.latitude)!, longitude: (raioAlarme?.coordinate.longitude)!)
      let distanciaParaCentro = locationManager.location?.distanceFromLocation(lugarDois)
      var distanciaParaRegiao = distanciaParaCentro! - raioAlarme!.radius
      
      if distanciaParaRegiao < 1000
      {
        labelDistancia.text = "\(Int(distanciaParaRegiao))m"
      }
      else
      {
        distanciaParaRegiao /= 1000
        labelDistancia.text = "\(distanciaParaRegiao.roundToPlaces(2))km"
      }
    }
  }
  
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    let statusBarHeight = UIApplication.sharedApplication().statusBarFrame.size.height
    let navigationBar = UINavigationBar(frame: CGRectMake(0, 0, self.view.frame.size.width, statusBarHeight))
    self.view.addSubview(navigationBar)
    
    
    mapView.delegate = self
    locationManager.delegate = self
    mapView.showsUserLocation = true
    
    let locationSearchTable = storyboard!.instantiateViewControllerWithIdentifier("LocationSearchTable") as! LocationSearchTable
    resultSearchController = UISearchController(searchResultsController: locationSearchTable)
    resultSearchController?.searchResultsUpdater = locationSearchTable
    
    let searchBar = resultSearchController!.searchBar
    searchBar.sizeToFit()
    searchBar.placeholder = "Procure seu ponto"
    navigationItem.titleView = resultSearchController?.searchBar
    
    resultSearchController?.hidesNavigationBarDuringPresentation = false
    resultSearchController?.dimsBackgroundDuringPresentation = true
    definesPresentationContext = true
    
    locationSearchTable.mapView = mapView
    activeButton.setTitle("ATIVAR", forState: UIControlState.Normal)
    
    locationSearchTable.handleMapSearchDelegate = self
    
    let image = UIImage(named: "music")! as UIImage
    musicButton.setImage(image, forState: .Normal)
    self.view.addSubview(musicButton)
    
  }
  
  override func preferredStatusBarStyle() -> UIStatusBarStyle
  {
    return UIStatusBarStyle.Default
  }
  
  //adiciona e remove anotacoes
  @IBAction func addPin(sender: AnyObject)
  {
    if alarmeAtivado == false{
      let location = sender.locationInView(self.mapView)
      let locationCoord = self.mapView.convertPoint(location, toCoordinateFromView: self.mapView)
      let annotation = MKPointAnnotation()
      annotation.coordinate = locationCoord
      
      self.mapView.removeOverlays(self.mapView.overlays)
      self.mapView.removeAnnotations(self.mapView.annotations)
      self.mapView.addAnnotation(annotation)
      pinAlarm = true
    }
  }
  
  // a cada anotacao adicionada, essa funcao é chamada automaticamente
  // customiza aparencia do annotation
  func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView?
  {
    
    if annotation is MKUserLocation
    {
      return nil
    }
    
    
    let reuseId = "teste1"
    var annotView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
    
    if annotView == nil
    {
      annotView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
      annotView?.image = UIImage(named: "pontoCentral")
      annotView?.canShowCallout = false
    }
    else
    {
      annotView?.annotation = annotation
    }
    
    //annotView?.centerOffset = CGPointMake(0, -annotView!.frame.size.height / 2 + 10)
    
    
    // configura/adiciona overlay (circulo/raio ao redor do annotation)
    raioAlarme = MKCircle(centerCoordinate: annotation.coordinate, radius: distanciaRaio)
    
    
    self.mapView.addOverlay(raioAlarme!)
    
    
    //TODO: Dar uma olhada nesse draggable, em um dispositivo de fato
    // Acho que não tá funcionando bacana. Depois que dá drag, não da pra botar outro
    
    annotView?.draggable = false
    
    return annotView
  }
  
  // cada vez que tiver um overlay na area visivel do mapa essa funcao é chamada automaticamente
  // configura a cor do overlay
  func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer
  {
    
    let overlayRenderer : MKCircleRenderer = MKCircleRenderer(overlay: overlay)
    overlayRenderer.fillColor = UIColor(red: 48/256, green: 68/256, blue: 91/256, alpha: 0.4)
    overlayRenderer.strokeColor = UIColor (red: 48/256, green: 68/256, blue: 91/256, alpha: 1)
    overlayRenderer.lineWidth = 3
    
    return overlayRenderer
  }
  
  //    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, didChangeDragState newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState)
  //    {
  //        if newState == MKAnnotationViewDragState.Starting
  //        {
  //            self.mapView.removeOverlays(mapView.overlays)
  //        }
  //
  //        if newState == MKAnnotationViewDragState.Ending
  //        {
  //            let ann = view.annotation
  //            //self.mapView.addAnnotation(ann!)
  //
  //            raioAlarme = MKCircle(centerCoordinate: ann!.coordinate, radius: distanciaRaio)
  //            self.mapView.addOverlay(raioAlarme!)
  //            print("annotation dropped at: \(ann!.coordinate.latitude),\(ann!.coordinate.longitude)")
  //        }
  //    }
  
  @IBAction func ativarAction(sender: UIButton)
  {
    if pinAlarm
    {
      let alarme = Alarm(coordinate: raioAlarme!.coordinate, radius: raioAlarme!.radius, identifier: "Alarme", note: "alarme")
      if sender.titleLabel?.text == "ATIVAR"
      {
        startMonitoringGeotification(alarme)
        alarmeAtivado = true
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        imageDim.image = UIImage(named: "fundoDim")
        
        let lugarDois = CLLocation(latitude: (raioAlarme?.coordinate.latitude)!, longitude: (raioAlarme?.coordinate.longitude)!)
        let distanciaParaCentro = locationManager.location?.distanceFromLocation(lugarDois)
        var distanciaParaRegiao = distanciaParaCentro! - raioAlarme!.radius
        
        if distanciaParaRegiao < 1000
        {
          labelDistancia.text = "\(Int(distanciaParaRegiao))m"
        }
        else
        {
          distanciaParaRegiao /= 1000
          labelDistancia.text = "\(distanciaParaRegiao.roundToPlaces(2))km"
        }
        
        
        activeButton.setTitle("DESATIVAR", forState: UIControlState.Normal)
      }
      else
      {
        print("desativa")
        stopMonitoringGeotification(alarme)
        alarmeAtivado = false
        labelDistancia.text = ""
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        imageDim.image = nil
        activeButton.setTitle("ATIVAR", forState: UIControlState.Normal)
      }
    }
  }
  
  //Monitoramento da região
  func startMonitoringGeotification(geotification: Alarm)
  {
    print("monitoring")
    // 1
    if !CLLocationManager.isMonitoringAvailableForClass(CLCircularRegion)
    {
      showSimpleAlertWithTitle("Error", message: "Geofencing is not supported on this device!", viewController: self)
      return
    }
    // 2
    if CLLocationManager.authorizationStatus() != .AuthorizedAlways
    {
      showSimpleAlertWithTitle("Warning", message: "Your alarm is saved but will only be activated once you grant Geotify permission to access the device location.", viewController: self)
    }
    // 3
    geotification.alarmeRegion?.notifyOnEntry = true
    geotification.alarmeRegion?.notifyOnExit = false
    locationManager.startMonitoringForRegion(geotification.alarmeRegion!)
    print(locationManager.monitoredRegions)
  }
  
  func stopMonitoringGeotification(geotification: Alarm)
  {
    for region in locationManager.monitoredRegions
    {
      if let circularRegion = region as? CLCircularRegion
      {
        if circularRegion.identifier == geotification.identifier
        {
          locationManager.stopMonitoringForRegion(circularRegion)
        }
      }
    }
  }
    
    @IBAction func chooseMusicAction(sender: AnyObject)
    {
        let mediaPicker = MPMediaPickerController(mediaTypes: .Music)
        mediaPicker.delegate = self
        mediaPicker.prompt = "Select any song!"
        mediaPicker.allowsPickingMultipleItems = false
        presentViewController(mediaPicker, animated: true, completion: {})
        
    }
    
    func mediaPicker(mediaPicker: MPMediaPickerController, didPickMediaItems  mediaItems:MPMediaItemCollection) -> Void
    {
        let aMediaItem = mediaItems.items[0] as MPMediaItem
        self.mediaItem = aMediaItem;
        print(mediaItem!.title)
        //fillData(aMediaItem);
        self.dismissViewControllerAnimated(true, completion: {});
    }
    
    func mediaPickerDidCancel(mediaPicker: MPMediaPickerController) {
        self.dismissViewControllerAnimated(true, completion: {});
    }
  
  
  
  func locationManager(manager: CLLocationManager, monitoringDidFailForRegion region: CLRegion?, withError error: NSError) {
    print("Monitoring failed for region with identifier: \(region!.identifier)")
  }
  
  func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
    print("Location Manager failed with the following error: \(error)")
  }
  
  override func didReceiveMemoryWarning()
  {
    super.didReceiveMemoryWarning()
    
  }
  
  
  
}

extension MapViewController: HandleMapSearch {
  func dropPinZoomIn(placemark:MKPlacemark){
    
    selectedPin = placemark
    
    let annotation = MKPointAnnotation()
    annotation.coordinate = placemark.coordinate
    self.mapView.removeOverlays(self.mapView.overlays)
    self.mapView.removeAnnotations(self.mapView.annotations)
    self.mapView.addAnnotation(annotation)
    
    pinAlarm = true
    
    let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    let region = MKCoordinateRegionMake(annotation.coordinate, span)
    self.mapView.setRegion(region, animated: true)
  }
}

extension Double {
  /// Rounds the double to decimal places value
  func roundToPlaces(places:Int) -> Double {
    let divisor = pow(10.0, Double(places))
    return round(self * divisor) / divisor
  }
}


