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

//Coordenadas PUC -22.97976, -43.23282

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, MPMediaPickerControllerDelegate
{
    
    @IBOutlet weak var viewS: UIView!
    @IBOutlet weak var userLocationButton: UIButton!
    @IBOutlet weak var musicLabel: UILabel!
    @IBOutlet weak var musicView: UIView!
    @IBOutlet weak var activeButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var labelDistancia: UILabel!
    @IBOutlet weak var imageDim: UIImageView!
    @IBOutlet weak var radiusLabel: UILabel!
    @IBOutlet weak var sliderRaio: UISlider!
    @IBOutlet weak var navBar: UIView!
    var viewSlider: UIVisualEffectView? = nil
    var step: Float = 10
    var mediaItem: MPMediaItem?
    var musicPlayer = MPMusicPlayerController.applicationMusicPlayer()
    var quickActionCheck = false
    var selectedPin:MKPlacemark? = nil
    
    var currentAlarmQA: Alarm!
    
    var navigationBar: UINavigationBar!
    var firstTime = true
    var raioAlarme: MKCircle?
    var pinAlarm = false
    var alarme: [Alarm] = []
    var distanciaRaio:CLLocationDistance = 500
    var resultSearchController:UISearchController? = nil
    let map = Map()
    var alarmeAtivado = false
    var locationManager = CLLocationManager()
    var locationCoord: CLLocationCoordinate2D?
    
    let movimentoDrag = UIPanGestureRecognizer()
    let tapGestureRecognizer = UITapGestureRecognizer()
    let statusBarHeight = UIApplication.sharedApplication().statusBarFrame.size.height
    
    var recentAlarmList:[Alarm] = []
    
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(true)
        map.locationManagerInit()
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        /* PARA PARAR DE MONITORAR TODAS AS REGIOES:
         
        for coisinha in locationManager.monitoredRegions
        {
            locationManager.stopMonitoringForRegion(coisinha)
        }
        */
        
        //MARK: Pega alarmes salvos do User Defaults
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if let savedAlarms = defaults.objectForKey("alarmes") as? NSData
        {
            alarme = NSKeyedUnarchiver.unarchiveObjectWithData(savedAlarms) as! [Alarm]
        }
        
        mapView.delegate = self
        locationManager.delegate = self
        mapView.showsUserLocation = true
        
        let locationSearchTable = storyboard!.instantiateViewControllerWithIdentifier("LocationSearchTable") as! LocationSearchTable
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        resultSearchController?.searchBar.tintColor = UIColor(red: 48 / 255, green: 68 / 255, blue: 91 / 255, alpha: 1)
        
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for a location"
        searchBar.setValue("Cancel", forKey: "_cancelButtonText")
        navigationItem.titleView = resultSearchController?.searchBar
        
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        
        locationSearchTable.mapView = mapView
        activeButton.setTitle("ACTIVATE", forState: UIControlState.Normal)
        
        locationSearchTable.handleMapSearchDelegate = self
        
        let blur = UIBlurEffect(style: .Light)
        viewSlider = UIVisualEffectView(effect: blur)
        viewSlider!.frame = viewS.bounds
        self.viewS.insertSubview(viewSlider!, atIndex: 0)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(MapViewController.chooseMusicAction(_:)))
        musicLabel.addGestureRecognizer(tapGesture)
        
        UIDevice.currentDevice().setValue(UIInterfaceOrientation.Portrait.rawValue, forKey: "orientation")
    }
    
    
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation)
    {
        if firstTime == true
        {
            self.mapView.setRegion(map.userLocation(locationManager, location: locationManager.location!),    animated: true)
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
    
    @IBAction func setRegionToUserLocation(sender: AnyObject)
    {
        self.mapView.setRegion(map.userLocation(locationManager, location: locationManager.location!),    animated: true)
    }
    
    //adiciona e remove anotacoes
    @IBAction func addPin(sender: AnyObject)
    {
        if alarmeAtivado == false
        {
            quickActionCheck = false
            let location = sender.locationInView(self.mapView)
            locationCoord = self.mapView.convertPoint(location, toCoordinateFromView: self.mapView)
            let annotation = MKPointAnnotation()
            annotation.coordinate = locationCoord!
            
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
        
        // configura/adiciona overlay (circulo/raio ao redor do annotation)
        raioAlarme = MKCircle(centerCoordinate: annotation.coordinate, radius: distanciaRaio)
        self.mapView.addOverlay(raioAlarme!)
        
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
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation)
    {
        navigationController
    }
    
    //MARK: Função de ativar/desativar alarme
    @IBAction func ativarAction(sender: UIButton)
    {
        if pinAlarm
        {
            if alarme.count == 5
            {
                alarme.removeAtIndex(4)
            }
            
            if sender.titleLabel?.text == "ACTIVATE"
            {
                if musicLabel.text == "Choose a song"
                {
                    musicLabel.text = "No song chosen"
                }
                
                let uniqueIdentifier = NSUUID().UUIDString
                
                print(":::::::::UNIQUE IDENTIFIER::::::: \(uniqueIdentifier)")
                
                let alarmeAtual = Alarm(coordinate: raioAlarme!.coordinate, radius: raioAlarme!.radius, identifier:  uniqueIdentifier, note: "You are \(Int(raioAlarme!.radius))m from your destination!")
                
                alarme.insert(alarmeAtual, atIndex: 0)
                
                //MARK: Adiciona alarme atual ao NSUserDefaults
                
                let savedData = NSKeyedArchiver.archivedDataWithRootObject(alarme)
                let defaults = NSUserDefaults.standardUserDefaults()
                defaults.setObject(savedData, forKey: "alarmes")
                
                print(":::Identifier desse alarme: \(alarme.first?.identifier)")
                
                startMonitoringGeotification(alarmeAtual)
                alarmeAtivado = true
                
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
                
                self.navigationController?.setNavigationBarHidden(true, animated: true)
                
                imageDim.image = UIImage(named: "fundoDim")
                self.mapView.bringSubviewToFront(imageDim)
                imageDim.bringSubviewToFront(labelDistancia)
                sliderRaio.hidden = true
                viewSlider!.hidden = true
                musicLabel.userInteractionEnabled = false
                activeButton.setTitle("DEACTIVATE", forState: UIControlState.Normal)
                activeButton.backgroundColor = UIColor(red: 160 / 255, green: 60 / 255, blue: 55 / 255, alpha: 1)
                
            }
            else
            {
                if quickActionCheck == false
                {
                    stopMonitoringGeotification(alarme.first!)
                }
                else
                {
                    stopMonitoringGeotification(currentAlarmQA)
                }
                
                alarmeAtivado = false
                
                sliderRaio.hidden = false
                viewSlider!.hidden = false
                musicLabel.text = "Choose a song"
                musicLabel.userInteractionEnabled = true
                labelDistancia.text = ""
                self.navigationController?.setNavigationBarHidden(false, animated: true)
                imageDim.image = nil
                
                activeButton.setTitle("ACTIVATE", forState: UIControlState.Normal)
                activeButton.backgroundColor = UIColor(red: 48 / 255, green: 68 / 255, blue: 91 / 255, alpha: 1)
            }
        }
    }
    
    //MARK: Ativando alarme por quick action
    
    func activateByQuickAction(quickActionType: String)
    {
        quickActionCheck = true
        pinAlarm = true
        
        currentAlarmQA = alarme.first
        
        for item in alarme
        {
            if item.identifier == quickActionType
            {
                currentAlarmQA = item
                break
            }
        }
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = (currentAlarmQA?.coordinate)!
        distanciaRaio = (currentAlarmQA?.radius)!
        
        self.mapView.removeOverlays(self.mapView.overlays)
        self.mapView.removeAnnotations(self.mapView.annotations)
        self.mapView.addAnnotation(annotation)
        
        print("::: Identifier do alarme da Quick Action: \(currentAlarmQA?.identifier)")
        
        if musicLabel.text == "Choose a song"
        {
            musicLabel.text = "No song chosen"
        }
        
        currentAlarmQA?.alarmeRegion = CLCircularRegion(center: currentAlarmQA!.coordinate, radius: currentAlarmQA!.radius, identifier: currentAlarmQA!.note)
        
        //print("_____TESTE__ currentAlarmQA?.alarmeRegion = \(currentAlarmQA?.alarmeRegion)")
        
        startMonitoringGeotification(currentAlarmQA!)
        alarmeAtivado = true
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        imageDim.image = UIImage(named: "fundoDim")
        self.mapView.bringSubviewToFront(imageDim)
        imageDim.bringSubviewToFront(labelDistancia)
        
        
        let lugarDois = CLLocation(latitude: (currentAlarmQA!.coordinate.latitude), longitude: (currentAlarmQA!.coordinate.longitude))
        
        
        //TODO: Nessa linha de baixo, o bug da falta de localização do usuário quando o app tava fechado no background e abriu pela QA
        let distanciaParaCentro = locationManager.location?.distanceFromLocation(lugarDois)
        var distanciaParaRegiao = distanciaParaCentro! - currentAlarmQA!.radius
        
        if distanciaParaRegiao < 1000
        {
            labelDistancia.text = "\(Int(distanciaParaRegiao))m"
        }
        else
        {
            distanciaParaRegiao /= 1000
            labelDistancia.text = "\(distanciaParaRegiao.roundToPlaces(2))km"
        }
        
        sliderRaio.hidden = true
        viewSlider!.hidden = true
        musicLabel.userInteractionEnabled = false
        activeButton.setTitle("DEACTIVATE", forState: UIControlState.Normal)
        activeButton.backgroundColor = UIColor(red: 160 / 255, green: 60 / 255, blue: 55 / 255, alpha: 1)
        
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegionMake(annotation.coordinate, span)
        self.mapView.setRegion(region, animated: true)
    }
    
    
    //MARK: Monitoramento da região
    func startMonitoringGeotification(geotification: Alarm)
    {
        print("::: Começou a monitorar a região")
        // 1
        if !CLLocationManager.isMonitoringAvailableForClass(CLCircularRegion)
        {
            showSimpleAlertWithTitle("Error", message: "Geofencing is not supported on this device!",     viewController: self)
            return
        }
        // 2
        if CLLocationManager.authorizationStatus() != .AuthorizedAlways
        {
            showSimpleAlertWithTitle("Warning", message: "Your alarm is saved but will only be activated once you grant Geotify permission to access the device location.", viewController: self)
        }
        // 3
        print("\n::::::: QTD MONITORED REGIONS : \(locationManager.monitoredRegions.count)")
        if locationManager.monitoredRegions.count != 0
        {
            for monitoredRegion in locationManager.monitoredRegions
            {
                locationManager.stopMonitoringForRegion(monitoredRegion)
            }
        }
        //print("_____TESTE__ geotification.alarmeRegion = \(geotification.alarmeRegion)")
        geotification.alarmeRegion?.notifyOnEntry = true
        geotification.alarmeRegion?.notifyOnExit = false
        
        locationManager.startMonitoringForRegion(geotification.alarmeRegion!)
        print("\n\nRegiões que estão sendo monitoradas: \(locationManager.monitoredRegions)\n\n")
    }
    
    func stopMonitoringGeotification(geotification: Alarm)
    {
        print("::: Parou de monitorar a região")
        locationManager.stopMonitoringForRegion(geotification.alarmeRegion!)
    }
    
    @IBAction func sliderRaioChanged(sender: UISlider)
    {
        if sender.value < 1000
        {
            step = 50
            let roundedValue = round(sender.value / step) * step
            sender.value = roundedValue
            radiusLabel.text = "\(Int(sender.value))m"
        }
        else
        {
            step = 100
            let roundedValue = round(sender.value / step) * step
            sender.value = roundedValue
            radiusLabel.text = "\((sender.value) / 1000)km"
            
        }
        
        distanciaRaio = Double(sender.value)
        if pinAlarm
        {
            self.mapView.removeOverlays(self.mapView.overlays)
            raioAlarme = MKCircle(centerCoordinate: locationCoord!, radius: distanciaRaio)
            self.mapView.addOverlay(raioAlarme!)
            
        }
    }
    
    
    func chooseMusicAction(sender: UITapGestureRecognizer)
    {
        self.prefersStatusBarHidden()
        
        let mediaPicker = MPMediaPickerController(mediaTypes: .Music)
        mediaPicker.delegate = self
        mediaPicker.allowsPickingMultipleItems = false
        mediaPicker.prefersStatusBarHidden()
        
        presentViewController(mediaPicker, animated: true, completion: {UIApplication.sharedApplication().statusBarStyle = .Default})
    }
    
    func mediaPicker(mediaPicker: MPMediaPickerController, didPickMediaItems  mediaItems:MPMediaItemCollection) -> Void
    {
        let aMediaItem = mediaItems.items[0] as MPMediaItem
        self.mediaItem = aMediaItem;
        print("mediaItem.title = \(mediaItem!.title)")
        musicLabel.text = "\(mediaItem!.artist!) - \(mediaItem!.title!)"
        musicLabel.textColor = UIColor(red: 48 / 255, green: 68 / 255, blue: 91 / 255, alpha: 1)
        self.dismissViewControllerAnimated(true, completion: {UIApplication.sharedApplication().statusBarStyle = .LightContent});
    }
    
    func mediaPickerDidCancel(mediaPicker: MPMediaPickerController)
    {
        self.dismissViewControllerAnimated(true, completion: {UIApplication.sharedApplication().statusBarStyle = .LightContent});
    }
    
    func playMedia()
    {
        if (mediaItem != nil)
        {
            let array = [mediaItem!]
            let collection = MPMediaItemCollection(items: array)
            
            musicPlayer.setQueueWithItemCollection(collection)
            musicPlayer.play();
        }
    }
    
    
    func locationManager(manager: CLLocationManager, monitoringDidFailForRegion region: CLRegion?, withError error: NSError)
    {
        print("Monitoring failed for region with identifier: \(region!.identifier)")
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError)
    {
        print("Location Manager failed with the following error: \(error)")
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        
    }
}

extension MapViewController: HandleMapSearch
{
    func dropPinZoomIn(placemark:MKPlacemark)
    {
        selectedPin = placemark
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        locationCoord = annotation.coordinate
        self.mapView.removeOverlays(self.mapView.overlays)
        self.mapView.removeAnnotations(self.mapView.annotations)
        self.mapView.addAnnotation(annotation)
        
        pinAlarm = true
        
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegionMake(annotation.coordinate, span)
        self.mapView.setRegion(region, animated: true)
    }
}

extension Double
{
    /// Rounds the double to decimal places value
    func roundToPlaces(places:Int) -> Double
    {
        let divisor = pow(10.0, Double(places))
        return round(self * divisor) / divisor
    }
}


