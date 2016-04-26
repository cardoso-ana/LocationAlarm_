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

//OIOIOI
// Coordenadas uteis
// -22.97976, -43.23282 PUC

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, MPMediaPickerControllerDelegate
{
    
    @IBOutlet weak var viewS: UIView!
    var viewSlider: UIVisualEffectView? = nil
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
    var step: Float = 10
    var mediaItem: MPMediaItem?
    var musicPlayer = MPMusicPlayerController.applicationMusicPlayer()
    
    var selectedPin:MKPlacemark? = nil
    
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
    //let regionRadius: CLLocationDistance = 1000
    var locationCoord: CLLocationCoordinate2D?
    
    let movimentoDrag = UIPanGestureRecognizer()
    let tapGestureRecognizer = UITapGestureRecognizer()
    let statusBarHeight = UIApplication.sharedApplication().statusBarFrame.size.height
    
    
    //  struct recentAlarm{
    //    var alarme:Alarm
    //
    //    //fazer nome de cada ultimo alarme
    //
    //    //var nome:String
    //
    //  }
    
    var recentAlarmList:[Alarm] = []
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(true)
        map.locationManagerInit()
    }
    
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //        let barView = UIView(frame: CGRectMake(-20, 0, self.mapView.frame.size.width, statusBarHeight))
        //        barView.backgroundColor = UIColor(red: 48 / 255, green: 68 / 255, blue: 91 / 255, alpha: 1)
        //        self.navigationController?.view.addSubview(barView)
        
        mapView.delegate = self
        locationManager.delegate = self
        mapView.showsUserLocation = true
        
        let locationSearchTable = storyboard!.instantiateViewControllerWithIdentifier("LocationSearchTable") as! LocationSearchTable
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        resultSearchController?.searchBar.tintColor = UIColor(red: 48 / 255, green: 68 / 255, blue: 91 / 255, alpha: 1)
        
        
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Pesquise seu destino"
        searchBar.setValue("Cancelar", forKey: "_cancelButtonText")
        navigationItem.titleView = resultSearchController?.searchBar
        
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        
        locationSearchTable.mapView = mapView
        activeButton.setTitle("ATIVAR", forState: UIControlState.Normal)
        
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
    
    
//    func setsNameToAlarm(alarme:Alarm)
//    {
//        
//        let location = CLLocation(latitude: alarme.coordinate.latitude, longitude: alarme.coordinate.longitude)
//        //pega o endereço
//        
//        CLGeocoder().reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
//            
//            var endereco = "Recent Alarm"
//            if placemarks!.count > 0 {
//                
//                let pm = placemarks![0]
//                
//                if let rua = pm.thoroughfare{
//                    endereco = ("\(rua)")
//                    if let numero = pm.subThoroughfare{
//                        endereco = ("\(rua), \(numero)")
//                    }
//                    print("endereco = \(endereco)")
//                    
//                    
//                }
//            }
//                
//            else {
//                print("Problem with the data received from geocoder")
//            }
//            
//            //QUICK ACTIONSSSS
//            
//            let allQAIcons = UIApplicationShortcutIcon(type: UIApplicationShortcutIconType.Time)
//            let QAItem = UIApplicationShortcutItem(type: "alarmeRecenteQA", localizedTitle: endereco, localizedSubtitle: self.radiusLabel.text, icon: allQAIcons, userInfo: nil)
//            
//            UIApplication.sharedApplication().shortcutItems?.insert(QAItem, atIndex: 0)
//            
//            if UIApplication.sharedApplication().shortcutItems?.count == 5 {
//                UIApplication.sharedApplication().shortcutItems?.removeAtIndex(4)
//            }
//            
//            
//        })
//        
//    }
    
    /*
     
     
     
     */
    
    //MARK: Ativando alarme por quick action
    
    func activateByQuickAction(quickActionType: String){
        
        pinAlarm = true
        
        //TODO: puxar infos da plist.
        alarme.insert(Alarm(coordinate: raioAlarme!.coordinate, radius: raioAlarme!.radius, identifier:  "Alarme", note: "Você está a \(Int(raioAlarme!.radius))m do seu destino!"), atIndex: 0)
        print(alarme)
        
        if alarme.count == 5
        {
            alarme.removeAtIndex(4)
        }

        
        if self.activeButton.titleLabel?.text == "ATIVAR"
        {
            if musicLabel.text == "Selecione uma música"{
                musicLabel.text = "Nenhuma música selecionada"
            }
            
            startMonitoringGeotification(alarme.first!)
            alarmeAtivado = true
            self.navigationController?.setNavigationBarHidden(true, animated: true)
            
            imageDim.image = UIImage(named: "fundoDim")
            self.mapView.bringSubviewToFront(imageDim)
            imageDim.bringSubviewToFront(labelDistancia)
            
            //TODO: mudar aqui tambem, pra info do plist
            //TODO: verificar se ja tem location do usuario
            
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
            
            sliderRaio.hidden = true
            viewSlider!.hidden = true
            musicLabel.userInteractionEnabled = false
            activeButton.setTitle("DESATIVAR", forState: UIControlState.Normal)
            activeButton.backgroundColor = UIColor(red: 160 / 255, green: 60 / 255, blue: 55 / 255, alpha: 1)
            
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
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation)
    {
        navigationController
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
    
    
    //MARK: Função de ativar/desativar alarme
    
    @IBAction func ativarAction(sender: UIButton)
    {
        if pinAlarm
        {
            alarme.insert(Alarm(coordinate: raioAlarme!.coordinate, radius: raioAlarme!.radius, identifier:  "Alarme", note: "Você está a \(Int(raioAlarme!.radius))m do seu destino!"), atIndex: 0)
            print(alarme)
            
            if alarme.count == 5
            {
                alarme.removeAtIndex(4)
            }
            
            if sender.titleLabel?.text == "ATIVAR"
            {
                if musicLabel.text == "Selecione uma música"{
                    musicLabel.text = "Nenhuma música selecionada"
                }
                
                startMonitoringGeotification(alarme.first!)
                alarmeAtivado = true
                self.navigationController?.setNavigationBarHidden(true, animated: true)
                
                imageDim.image = UIImage(named: "fundoDim")
                self.mapView.bringSubviewToFront(imageDim)
                imageDim.bringSubviewToFront(labelDistancia)
                
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
                
                sliderRaio.hidden = true
                viewSlider!.hidden = true
                musicLabel.userInteractionEnabled = false
                activeButton.setTitle("DESATIVAR", forState: UIControlState.Normal)
                activeButton.backgroundColor = UIColor(red: 160 / 255, green: 60 / 255, blue: 55 / 255, alpha: 1)
                //navBar.hidden = true
                
                //MARK: Lida com alarmes recentes
                //Preenche lista de alarmes recentes e limpa o quinto elemento
                
                //recentAlarmList.insert(alarme!, atIndex: 0)
                
                //itens do quick action
                
                
                //setsNameToAlarm(self.alarme!)
                
                
//                if recentAlarmList.count == 5{
//                    recentAlarmList.removeAtIndex(4)
//                }
                
            }
            else
            {
                sliderRaio.hidden = false
                viewSlider!.hidden = false
                musicLabel.text = "Selecione uma música"
                musicLabel.userInteractionEnabled = true
                stopMonitoringGeotification(alarme.first!)
                alarmeAtivado = false
                labelDistancia.text = ""
                self.navigationController?.setNavigationBarHidden(false, animated: true)
                imageDim.image = nil
                //navBar.hidden = false
                
                activeButton.setTitle("ATIVAR", forState: UIControlState.Normal)
                activeButton.backgroundColor = UIColor(red: 48 / 255, green: 68 / 255, blue: 91 / 255, alpha: 1)
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
            showSimpleAlertWithTitle("Error", message: "Geofencing is not supported on this device!",     viewController: self)
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
        print("parou")
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
        print(mediaItem!.title)
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


