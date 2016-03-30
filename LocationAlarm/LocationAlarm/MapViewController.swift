//
//  ViewController.swift
//  LocationAlarm
//
//  Created by Ana Carolina Nascimento on 3/29/16.
//  Copyright © 2016 Ana Carolina Nascimento. All rights reserved.
//

import UIKit
import Foundation
import UIKit
import MapKit
import CoreLocation


class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate
{
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var botaoDeBaixo: UIImageView!
    var navigationBar: UINavigationBar!
    var firstTime = true
    var resultSearchController:UISearchController? = nil
    let map = Map()
    
    var locationManager = CLLocationManager()
    let regionRadius: CLLocationDistance = 1000
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(true)
        map.locationManagerInit()
      
    }
  
  func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
    print("chegou no dois")
    if firstTime == true{
      self.mapView.setRegion(map.userLocation(locationManager, location: locationManager.location!), animated: true)
      firstTime = false
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
        
      botaoDeBaixo.image = UIImage(named: "botaoDeBaixoAzul")
        
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle
    {
        return UIStatusBarStyle.Default
    }
    
    
    //TODO: Fazer alerta para usuario mudar a permissao de localizacao no Settings
    
    //MARK: - vê autorizaçao de localizaçao e começa a atualizar o locationManager
    func checkCoreLocationPermission()
    {
        let authorization = CLLocationManager.authorizationStatus()
        if authorization == .AuthorizedAlways
        {
            locationManager.startUpdatingLocation()
        }
        else if authorization == .NotDetermined
        {
            locationManager.requestAlwaysAuthorization()
        }
        else
        {
            print(":::::: Access to user location not granted or unavailable.")
        }
    }
    
    
    func centerMapOnLocation(location: CLLocation)
    {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    //posiciona o mapa na localização do user
    //    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    //        let location = locations.last
    //
    //        let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
    //        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
    //
    //        self.mapView.setRegion(region, animated: true)
    //    }
    
    //posiciona o mapa no inicio
    func ajeitaZoom(manager: CLLocationManager, location: CLLocation) {
        
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        self.mapView.setRegion(region, animated: true)
    }
    
    //adiciona e remove anotacoes
    @IBAction func addPin(sender: AnyObject)
    {
        let location = sender.locationInView(self.mapView)
        let locationCoord = self.mapView.convertPoint(location, toCoordinateFromView: self.mapView)
        let annotation = MKPointAnnotation()
        annotation.coordinate = locationCoord
        
        self.mapView.removeOverlays(self.mapView.overlays)
        self.mapView.removeAnnotations(self.mapView.annotations)
        self.mapView.addAnnotation(annotation)
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
            annotView?.image = UIImage(named: "pinCustom")
            annotView?.canShowCallout = false
        }
        else
        {
            annotView?.annotation = annotation
        }
        
        annotView?.centerOffset = CGPointMake(0, -annotView!.frame.size.height / 2 + 10)
        
        
        // configura/adiciona overlay (circulo/raio ao redor do annotation)
        let distanciaRaio:CLLocationDistance = 100
        let raioDaOra = MKCircle(centerCoordinate: annotation.coordinate, radius: distanciaRaio)
        
        self.mapView.addOverlay(raioDaOra)
        
        
        //TODO: Dar uma olhada nesse draggable, em um dispositivo de fato
        // Acho que não tá funcionando bacana. Depois que dá drag, não da pra botar outro
        
        //        annotView?.draggable = true
        
        return annotView
    }
    
    // cada vez que tiver um overlay na area visivel do mapa essa funcao é chamada automaticamente
    // configura a cor do overlay
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer
    {
        
        let overlayRenderer : MKCircleRenderer = MKCircleRenderer(overlay: overlay)
        overlayRenderer.fillColor = UIColor.redColor()
        
        return overlayRenderer
    }
    
    // faz pesquisa de local
    //TODO: Resolver essa bagunça que está sendo a Local Search.
    // não esquecer de descer teclado pós-pesquisa
    
    //  func finishSearch () {
    //    let request = MKLocalSearchRequest()
    //    request.naturalLanguageQuery = caixaDePesquisa.text
    //    let theSearch = MKLocalSearch(request: request)
    //    let theResponse:MKLocalSearchResponse
    //    var error:NSError!
    //    theSearch.startWithCompletionHandler(<#T##completionHandler: MKLocalSearchCompletionHandler##MKLocalSearchCompletionHandler##(MKLocalSearchResponse?, NSError?) -> Void#>)
    //  }
    //
    //  func displayResults (MKLocalSearchResponse?, NSError?) -> MKMapSnapshotCompletionHandler {
    //    //implementar esse bagulhao aqui
    //    response
    //
    //  }
    //
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        
    }
    
}


