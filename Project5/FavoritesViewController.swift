//
//  FavoritesViewController.swift
//  Project5
//
//  Created by Hangyi Wang on 2020/2/13.
//  Copyright © 2020 Hangyi Wang. All rights reserved.
//
// Attribution: https://stackoverflow.com/questions/24668818/how-to-dismiss-viewcontroller-in-swift
// Attribution: https://www.andrewcbancroft.com/2015/04/08/how-delegation-works-a-swift-developer-guide/

import UIKit

class FavoritesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    weak var delegate: PlacesFavoritesDelegate?
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var dismissButton: UIButton!
    
    var favoritePlaces = [String]()
    
    // MARK: - Init DataManager Singleton
    let dataManager = DataManager.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        dismissButton.addTarget(self, action: #selector(dismissButtonTapped), for: .touchUpInside)
        
        // Get all user's favorite places from UserDefaults
        favoritePlaces = dataManager.listFavorites()
    }
    
    // Dismiss favorite places view controller
    @objc func dismissButtonTapped(_ button: UIButton) {
        dismissViewController()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoritePlaces.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "favoritePlaceName", for: indexPath)
        cell.textLabel?.text = self.favoritePlaces[indexPath.row]
        return cell
    }
    
    // Behavior when select a favorite place on list
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.favoritePlace(name: self.favoritePlaces[indexPath.row])
        dismissViewController()
    }
    
    // Dismiss favorite places view controller
    func dismissViewController() {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
}
