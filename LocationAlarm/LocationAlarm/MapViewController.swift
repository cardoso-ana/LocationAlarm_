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
import WatchConnectivity

protocol HandleMapSearch
{
    func dropPinZoomIn(placemark:MKPlacemark)
}

//Coordenadas PUC -22.97976, -43.23282

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, MPMediaPickerControllerDelegate, WCSessionDelegate
{
    
    @IBOutlet weak var viewS: UIView!
    @IBOutlet weak var userLocationButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var measureUnitButton: UIButton!
    @IBOutlet weak var soundChooserButton: UIButton!
    @IBOutlet weak var helpButton: UIButton!
    
    
    @IBOutlet weak var tutorialLabel: UILabel!
    
    @IBOutlet weak var fundoDim: UIView!
    @IBOutlet weak var activeButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var labelDistancia: UILabel!
    @IBOutlet weak var radiusLabel: UILabel!
    @IBOutlet weak var sliderRaio: UISlider!
    @IBOutlet weak var navBar: UIView!
    
    
    var viewSlider: UIVisualEffectView? = nil
    var step: Float = 50
    var distanciaRaio:CLLocationDistance = 500
    var alarmSound = "Default"
    var quickActionCheck = false
    var selectedPin:MKPlacemark? = nil
    var currentAlarmQA: Alarm!
    
    var firstTime = true
    var raioAlarme: MKCircle?
    var pinAlarm = false
    var alarme: [Alarm] = []
    var resultSearchController:UISearchController? = nil
    let map = Map()
    var alarmeAtivado = false
    var distanceInMeters = false
    var locationManager = CLLocationManager()
    var locationCoord: CLLocationCoordinate2D?
    
    let tapGestureRecognizer = UITapGestureRecognizer()
    let statusBarHeight = UIApplication.sharedApplication().statusBarFrame.size.height
    
    
    
    
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
        
        // checa se é ou nao primeira vez de abertura do app
        
        
        print(":: is First Launch testou")
        
        print(defaults.stringForKey("isFirstLaunch"))

        if defaults.stringForKey("isFirstLaunch") != "NO" {

            print(":::::: entrou no teste do isFirstLaunch")
            defaults.setValue("NO", forKey: "isFirstLaunch")
            print(defaults.stringForKey("isFirstLaunch"))
            performSegueWithIdentifier("goToIntro", sender: self)

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
        
        self.navigationController?.navigationBarHidden = false
        self.navigationItem.setHidesBackButton(true, animated: false)
        
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
        setSlider()
        
        //Esconde botoes de som e conversao de unidade de medidas
        soundChooserButton.hidden = true
        measureUnitButton.hidden = true
        
        // Mini tutorial escrito
        self.radiusLabel.hidden = true
        self.sliderRaio.hidden = true
        
        //Faz o fundo com blur de quando alarme tá ativado
        let blur2 = UIBlurEffect(style: .Light)
        let fundoBlur = UIVisualEffectView(effect: blur2)
        fundoBlur.frame = fundoDim.bounds
        self.fundoDim.insertSubview(fundoBlur, atIndex: 0)
        fundoDim.hidden = true
        
        UIDevice.currentDevice().setValue(UIInterfaceOrientation.Portrait.rawValue, forKey: "orientation")
        
        if WCSession.isSupported() {
            
            let wcsession = WCSession.defaultSession()
            wcsession.delegate = self
            wcsession.activateSession()
            
        }
    }
    
    
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation)
    {
        if firstTime == true
        {
            self.mapView.setRegion(map.userLocation(locationManager, location: locationManager.location!),    animated: true)
            firstTime = false
        }
        
        if didEnterFromQA == true{
            
            activateByQuickAction(tipoCoisado)
            didEnterFromQA = false
            
        }
        
        if alarmeAtivado == true
        {
            
            let lugarDois = CLLocation(latitude: (raioAlarme?.coordinate.latitude)!, longitude: (raioAlarme?.coordinate.longitude)!)
            let distanciaParaCentro = locationManager.location?.distanceFromLocation(lugarDois)
            let distanciaParaRegiao = distanciaParaCentro! - raioAlarme!.radius
            
            labelDistancia.text = formataDistânciaParaRegião(distanciaParaRegiao)
            
            //MARK: aqui deve atualizar label do watch
            
            if WCSession.isSupported() {
                
                let wcsession = WCSession.defaultSession()
                wcsession.sendMessage(["distancia":labelDistancia.text!], replyHandler: nil, errorHandler: nil)
                
                
                
            }
        }
    }
    
    @IBAction func setRegionToUserLocation(sender: AnyObject)
    {
        if locationManager.location != nil{
            
            self.mapView.setRegion(map.userLocation(locationManager, location: locationManager.location!),    animated: true)
            
        }
        
    }
    
    func setaDisplaySemTutorial() {
        
        self.tutorialLabel.hidden = true
        self.sliderRaio.hidden = false
        self.radiusLabel.hidden = false
    }
    
    
    //adiciona e remove anotacoes
    @IBAction func addPin(sender: AnyObject)
    {
        if alarmeAtivado == false
        {
            setaDisplaySemTutorial()
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
            
            if !alarmeAtivado
            {
                
                let lugarDois = CLLocation(latitude: (raioAlarme?.coordinate.latitude)!, longitude: (raioAlarme?.coordinate.longitude)!)
                let distanciaParaCentro = locationManager.location?.distanceFromLocation(lugarDois)
                let distanciaParaRegiao = distanciaParaCentro! - raioAlarme!.radius
                
                
                if distanciaParaRegiao > 0
                {
                    
                    let uniqueIdentifier = NSUUID().UUIDString
                    
                    print(":::::::::UNIQUE IDENTIFIER::::::: \(uniqueIdentifier)")
                    
                    //MARK: Texto desatualizado do alarme fica aqui.
                    let alarmeAtual = Alarm(coordinate: raioAlarme!.coordinate, radius: raioAlarme!.radius, identifier:  uniqueIdentifier, note: "You are \(MeterToMile(raioAlarme!.radius)) mi from your destination!")
                    
                    alarme.insert(alarmeAtual, atIndex: 0)
                    
                    //MARK: Adiciona alarme atual ao NSUserDefaults
                    
                    let savedData = NSKeyedArchiver.archivedDataWithRootObject(alarme)
                    let defaults = NSUserDefaults.standardUserDefaults()
                    defaults.setObject(savedData, forKey: "alarmes")
                    
                    print(":::Identifier desse alarme: \(alarme.first?.identifier)")
                    
                    startMonitoringGeotification(alarmeAtual)
                    alarmeAtivado = true
                    
                    labelDistancia.text = formataDistânciaParaRegião(distanciaParaRegiao)
                    
                    self.navigationController?.setNavigationBarHidden(true, animated: true)
                    
                    changeDisplayActivated()
                }
                else
                {
                    showSimpleAlertWithTitle("", message: "You are already \(MeterToMile(raioAlarme!.radius)) mi away from your destination!", viewController: self)
                }
                
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
                changeDisplayDeactivated()
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
        
        let lugarDois = CLLocation(latitude: (currentAlarmQA!.coordinate.latitude), longitude: (currentAlarmQA!.coordinate.longitude))
        
        let distanciaParaCentro = locationManager.location?.distanceFromLocation(lugarDois)
        let distanciaParaRegiao = distanciaParaCentro! - currentAlarmQA!.radius
        
        
        if distanciaParaRegiao > 0
        {
            
            currentAlarmQA?.alarmeRegion = CLCircularRegion(center: currentAlarmQA!.coordinate, radius: currentAlarmQA!.radius, identifier: currentAlarmQA!.note)
            
            //print("_____TESTE__ currentAlarmQA?.alarmeRegion = \(currentAlarmQA?.alarmeRegion)")
            
            startMonitoringGeotification(currentAlarmQA!)
            alarmeAtivado = true
            changeDisplayActivated()
 
            labelDistancia.text = formataDistânciaParaRegião(distanciaParaRegiao)
            
            let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            let region = MKCoordinateRegionMake(annotation.coordinate, span)
            self.mapView.setRegion(region, animated: true)
        }
        else
        {
            showSimpleAlertWithTitle("", message: "You are already \(MeterToMile(currentAlarmQA.radius)) mi away from your destination!", viewController: self)
        }
    
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
    
    func setSlider()
    {
        if distanceInMeters
        {
            sliderRaio.minimumValue = 50
            sliderRaio.maximumValue = 3000
            sliderRaio.value = 500
            radiusLabel.text = "500 m"
        }
        else
        {
            sliderRaio.minimumValue = 528 //0.1 mi
            sliderRaio.maximumValue = 10560 //2 mi
            sliderRaio.value = 1584
            radiusLabel.text = "0.3 mi"


        }
    }
    
    @IBAction func sliderRaioChanged(sender: UISlider)
    {
        if distanceInMeters
        {
            if sender.value < 1000
            {
                step = 50
                let roundedValue = round(sender.value / step) * step
                sender.value = roundedValue
                radiusLabel.text = "\(Int(sender.value)) m"
            }
            else
            {
                step = 100
                let roundedValue = round(sender.value / step) * step
                sender.value = roundedValue
                radiusLabel.text = "\((sender.value) / 1000) km"
            
            }
        }
        else
        {
            if sender.value > 5280
            {
                step = 1056
                let roundedValue = round(sender.value / step) * step
                sender.value = roundedValue
                radiusLabel.text = "\(Int(sender.value / 5280)) mi"
            }
            if sender.value > 528
            {
                step = 528
                let roundedValue = round(sender.value / step) * step
                sender.value = roundedValue
                radiusLabel.text = "\(sender.value / 5280) mi"
            }
        }
        
        distanciaRaio = Double(sender.value * 0.3048)
        if pinAlarm
        {
            self.mapView.removeOverlays(self.mapView.overlays)
            raioAlarme = MKCircle(centerCoordinate: locationCoord!, radius: distanciaRaio)
            self.mapView.addOverlay(raioAlarme!)
            
        }
    }
    
    func changeDisplayActivated()
    {
        
        fundoDim.hidden = false
        sliderRaio.hidden = true
        viewSlider!.hidden = false
        settingsButton.hidden = true
        measureUnitButton.hidden = true
        soundChooserButton.hidden = true
        helpButton.hidden = true
        
        
        radiusLabel.hidden = true
        tutorialLabel.text = "radius of \(radiusLabel.text!)"
        tutorialLabel.hidden = false
        
        activeButton.setTitle("DEACTIVATE", forState: UIControlState.Normal)
        activeButton.backgroundColor = UIColor(red: 209 / 255, green: 55 / 255, blue: 53 / 255, alpha: 1)
    }
    
    func changeDisplayDeactivated()
    {
        fundoDim.hidden = true
        sliderRaio.hidden = false
        viewSlider!.hidden = false
        settingsButton.hidden = false
        tutorialLabel.hidden = true
        radiusLabel.hidden = false
        
        labelDistancia.text = ""
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        
        activeButton.setTitle("ACTIVATE", forState: UIControlState.Normal)
        activeButton.backgroundColor = UIColor(red: 48 / 255, green: 68 / 255, blue: 91 / 255, alpha: 1)
    }
    
    func formataDistânciaParaRegião(distancia: Double) -> String
    {
        var dist = distancia
        if distanceInMeters
        {
            if dist < 1000
            {
                return "\(Int(dist)) m"
            }
            else
            {
                dist /= 1000
                return "\(dist.roundToPlaces(2)) km"
            }
        }
        else
        {
            dist = dist / 1609.344
            if dist < 0.1
            {
                dist = dist * 5280
                return "\(Int(dist)) ft"
            }
            else
            {
                return "\(dist.roundToPlaces(1)) mi"
            }
        }
    }
    
    @IBAction func settingsAction(sender: AnyObject) //tem que mudar o nome dessa action
    {
        soundChooserButton.hidden = false
        measureUnitButton.hidden = false
        helpButton.hidden = false
        
        UIView.animateWithDuration(0.4, delay: 0.0, options: .CurveEaseInOut, animations: {
            
            if self.soundChooserButton.center.x == self.measureUnitButton.center.x{
                
                self.soundChooserButton.center.x += 50
                self.measureUnitButton.center.x += 100
                self.helpButton.center.x += 150
                
            } else{
                
                self.soundChooserButton.center.x -= 50
                self.measureUnitButton.center.x -= 100
                self.helpButton.center.x -= 150
                
            }
            
            }, completion: { _ in
            
                if self.soundChooserButton.center.x == self.measureUnitButton.center.x {
                    self.soundChooserButton.hidden = true
                    self.measureUnitButton.hidden = true
                    self.helpButton.hidden = true
                }
            })
    }
    
    
    @IBAction func chooseSound(sender: AnyObject)
    {
        
        performSegueWithIdentifier("goToChooseSong", sender: self)
        
    }
    
    
    @IBAction func tappedHelpButton(sender: AnyObject) {
        
        performSegueWithIdentifier("goToIntro", sender: self)
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "goToIntro" {
            
            // pra solucionar bug do search bar se tornando irresponsivo depois do tutorial
            self.definesPresentationContext = false
            
        }
        
    }
    
    
    @IBAction func chooseDistanceUnit(sender: AnyObject)
    {
        if distanceInMeters
        {

            distanceInMeters = false
            setSlider()
            
            self.measureUnitButton.setImage(UIImage(named: "botaoKmNew"), forState: .Normal)

            
        }
        else
        {
            distanceInMeters = true
            setSlider()
            
            self.measureUnitButton.setImage(UIImage(named: "botaoMiNew"), forState: .Normal)

        }
        
    }
    
    func MeterToMile (distance: Double) -> Double
    {
        return (distance / 1609.344).roundToPlaces(1)
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
        setaDisplaySemTutorial()
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


