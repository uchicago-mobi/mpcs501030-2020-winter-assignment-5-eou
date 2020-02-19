//
//  DataManager.swift
//  Project5
//
//  Created by Hangyi Wang on 2020/2/13.
//  Copyright © 2020 Hangyi Wang. All rights reserved.
//

import Foundation

public class DataManager {
  
    // MARK: - Singleton Stuff
    public static let sharedInstance = DataManager()

    //This prevents others from using the default '()' initializer
    fileprivate init() {}

    func loadAnnotationFromPlist(plistName: String) -> Any? {
        var data: NSDictionary = NSDictionary()
        // Read place data as a dictionary from Data.plist
        if let path = Bundle.main.path(forResource: plistName, ofType: "plist") {
            // If plist contain root as Dictionary
            data = NSDictionary(contentsOfFile: path)!
        }
        return data
    }
    
    func saveFavorites(placeName: String) {
        if let data = UserDefaults.standard.value(forKey:"favoritePlaces") as? Data {
            var favoritePlaceSet = try! PropertyListDecoder().decode(Set<String>.self, from: data)
            if !favoritePlaceSet.contains(placeName) {
                // Have not stored before, store it !
                favoritePlaceSet.insert(placeName)
                UserDefaults.standard.set(try! PropertyListEncoder().encode(favoritePlaceSet), forKey:"favoritePlaces")
            }
        }
    }
    
    func removeFavorite(placeName: String) {
        if let data = UserDefaults.standard.value(forKey:"favoritePlaces") as? Data {
            var favoritePlaceSet = try! PropertyListDecoder().decode(Set<String>.self, from: data)
            if favoritePlaceSet.contains(placeName) {
                // Have stored before, remove it !
                favoritePlaceSet.remove(placeName)
                UserDefaults.standard.set(try! PropertyListEncoder().encode(favoritePlaceSet), forKey:"favoritePlaces")
            }
        }
    }
    
    func listFavorites() -> [String] {
        var favoritePlaces = [String]()
        
        if let data = UserDefaults.standard.value(forKey:"favoritePlaces") as? Data {
            let favoritePlaceSet = try! PropertyListDecoder().decode(Set<String>.self, from: data)
            for place in favoritePlaceSet {
                favoritePlaces.append(place)
            }
            // keep order
            favoritePlaces.sort()
        }
        
        return favoritePlaces
    }
}
