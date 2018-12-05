//
//  PokePin.swift
//  PokemonGo
//
//  Created by Fernanda  on 21/11/18.
//  Copyright © 2018 Fernanda Alvarado. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class PokePin: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var pokemon: Pokemon
    init(coord: CLLocationCoordinate2D, pokemon:Pokemon){
        self.coordinate = coord
        self.pokemon = pokemon
    }
}
