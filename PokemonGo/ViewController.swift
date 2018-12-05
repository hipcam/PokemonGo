//
//  ViewController.swift
//  PokemonGo
//
//  Created by Fernanda  on 21/11/18.
//  Copyright © 2018 Fernanda Alvarado. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    
    @IBOutlet weak var mapView: MKMapView!
    var ubicacion = CLLocationManager()
    var contActualizaciones = 0
    var pokemons:[Pokemon] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        ubicacion.delegate = self
        pokemons = obtenerPokemons()
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse{
           setup()
        }
        else{
            ubicacion.requestWhenInUseAuthorization()
        }
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse{
            setup()
        }
    }
    func setup(){
        mapView.delegate = self
        mapView.showsUserLocation = true
        ubicacion.startUpdatingLocation()
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true, block: { (timer) in
            if let coord = self.ubicacion.location?.coordinate{
                
                let pokemon = self.pokemons[Int(arc4random_uniform(UInt32(self.pokemons.count)))]
                let pin = PokePin(coord: coord, pokemon: pokemon)
                let randomLat = (Double(arc4random_uniform(200))-100.0)/5000.0
                let randomLon = (Double(arc4random_uniform(200))-100.0)/5000.0
                pin.coordinate.longitude += randomLon
                pin.coordinate.longitude += randomLat
                self.mapView.addAnnotation(pin)
            }
        })
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if (contActualizaciones < 1) {
            let region = MKCoordinateRegionMakeWithDistance(ubicacion.location!.coordinate, 1000, 1000)
            mapView.setRegion(region, animated: true)
            contActualizaciones += 1
        }
        else{
            ubicacion.stopUpdatingLocation()
        }
    }
        // Do any additional setup after loading the view, typically from a nib.
    @IBAction func centrarTapped(_ sender: Any) {
        if let coord = ubicacion.location?.coordinate{
            let region = MKCoordinateRegionMakeWithDistance(coord, 1000, 1000)
            mapView.setRegion(region, animated: true)
            contActualizaciones += 1
        }
    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
        let pinView = MKAnnotationView(annotation: annotation, reuseIdentifier: nil)
        pinView.image = UIImage(named:"player-1")
        var frame = pinView.frame
        frame.size.height = 50
        frame.size.width = 50
        pinView.frame = frame
        return pinView
        }
        let pinView = MKAnnotationView(annotation: annotation, reuseIdentifier: nil)
        let pokemon = (annotation as! PokePin).pokemon
        pinView.image = UIImage(named:pokemon.imagenNombre!)
        var frame = pinView.frame
        frame.size.height = 50
        frame.size.width = 50
        pinView.frame = frame
        return pinView
        
    }
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        mapView.deselectAnnotation(view.annotation, animated: true)
        if view.annotation is MKUserLocation{
            return
        }
        let region = MKCoordinateRegionMakeWithDistance(view.annotation!.coordinate, 200, 200)
        mapView.setRegion(region, animated: true)
        Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { (timer) in
            if let coord = self.ubicacion.location?.coordinate{
                let pokemon = (view.annotation as! PokePin).pokemon
                if MKMapRectContainsPoint(mapView.visibleMapRect, MKMapPointForCoordinate(coord)){
                    print("Puede atrapar al pokemon")
                    let nombre = pokemon.nombre
                    let pokemons = obtenerPokemonsAtrapados()
                    for pokemone in pokemons{
                        if (nombre == pokemone.nombre){
                            let alertaVC = UIAlertController(title: "Espera!", message: "Ya atrapaste al pokemon \(pokemon.nombre!) ", preferredStyle: .alert)
                            let pokedexAccion = UIAlertAction(title: "Capturar", style: .default, handler:{
                                (action) in
                                self.performSegue(withIdentifier: "pokedexSegue", sender: nil)
                            })
                            alertaVC.addAction(pokedexAccion)
                            let okAction = UIAlertAction(title : "Dejarlo", style: .default, handler: {(action) in
                                return
                            })
                            alertaVC.addAction(okAction)
                            self.present(alertaVC, animated: true, completion: nil)
                        }
                    }
                    pokemon.atrapado = true
                    (UIApplication.shared.delegate as! AppDelegate).saveContext()
                    mapView.removeAnnotation(view.annotation!)
                    
                    let alertaVC = UIAlertController(title: "Felicitaciones!", message: "Atrapaste a un \(pokemon.nombre!)", preferredStyle: .alert)
                    let pokedexAccion = UIAlertAction(title: "Pokedex", style: .default, handler:{
                        (action) in
                        self.performSegue(withIdentifier: "pokedexSegue", sender: nil)
                    })
                    alertaVC.addAction(pokedexAccion)
                    let okAccion = UIAlertAction(title : "OK", style: .default, handler: nil)
                    
                    
                    alertaVC.addAction(okAccion)
                    self.present(alertaVC, animated: true, completion: nil)
                    
                }else{
                    let alertaVC = UIAlertController(title: "Ups!", message: "Estàs muy lejos de ese \(pokemon.nombre!)", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler:nil)
                    alertaVC.addAction(okAction)
                    self.present(alertaVC, animated: true, completion: nil)
                }
            }
        })
        
    }
  

}

