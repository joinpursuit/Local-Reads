//
//  Library.swift
//  LocalReads
//
//  Created by Tom Seymour on 2/18/17.
//  Copyright © 2017 C4Q-3.2. All rights reserved.
//

import Foundation



struct Address {
    let streetInfo: String
    let city: String
    let state: String
    let zip: String
}


class Library {
    let name: String
    let phone: String
    let address: Address
    let coodinates: (long: Double, lat: Double)
    
    init(name: String, phone: String, address: Address, coordinates: (Double, Double)) {
        self.name = name
        self.phone = phone
        self.address = address
        self.coodinates = coordinates
    }
    
    convenience init?(from dict: [String: Any]) {
        if let name = dict["name"] as? String,
            let phone = dict["phone"] as? String,
            let city = dict["location_1_city"] as? String,
            let street = dict["location_1_location"] as? String,
            let state = dict["location_1_state"] as? String,
            let zip = dict["location_1_zip"] as? String,
            let locationDict = dict["location_1"] as? [String: Any],
            let coordinates = locationDict["coordinates"] as? [Double] {
            
            let address = Address(streetInfo: street, city: city, state: state, zip: zip)
            
            
            self.init(name: name, phone: phone, address: address, coordinates: (coordinates[0], coordinates[1]))
        } else {
            return nil
        }
    }
    
    class func getLibraries(from data: Data) -> [Library]? {
        do {
            let json: Any = try JSONSerialization.jsonObject(with: data, options: [])
            guard let libraryDictArr = json as? [[String: Any]] else { return nil }
            
            var libraries: [Library] = []
            for libraryDict in libraryDictArr {
                if let library = Library(from: libraryDict) {
                    libraries.append(library)
                }
            }
            return libraries
        }
        catch {
            print("Error occurred while trying to accessing API \(error)")
        }
        return nil
    }
    
    
    //copy and paste this function to the view conroller that needs it
    func getLibraries() {
        APIRequestManager.manager.getData(endPoint: "https://data.cityofnewyork.us/resource/b67a-vkqb.json") { (data) in
            if let data = data {
                if let libraies = Library.getLibraries(from: data) {
                    dump(libraies)
                }
            }
        }
    }

    
    
    
}
