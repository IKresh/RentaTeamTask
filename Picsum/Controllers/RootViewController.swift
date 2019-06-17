//
//  ViewController.swift
//  Picsum
//
//  Created by Ivan on 16/06/2019.
//  Copyright © 2019 Ivan. All rights reserved.
//

import UIKit
import CoreData

class RootViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var lastActualPages: [Int] = [0]
    
    let photosPerPage = 30
    
    let fetchedResultsController = PhotoRepository.shared.createFetchedResultsController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Все фото"
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "PhotoTableViewCell", bundle: nil), forCellReuseIdentifier: "PhotoTableViewCell")
        tableView.separatorStyle = .none
        tableView.prefetchDataSource = self
        
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
        
        PhotoRepository.shared.loadPhotos()
    }
    
    private func preloadPages(for currentPage: Int) {
        [max(currentPage - 1, 0), currentPage, currentPage + 1].forEach { (prefetchPage) in
            guard !lastActualPages.contains(prefetchPage) else {
                return
            }
            
            lastActualPages.append(prefetchPage)
            PhotoRepository.shared.loadPhotos(prefetchPage)
            
            if lastActualPages.count > 4 {
                lastActualPages.removeFirst()
            }
        }
    }
}

extension RootViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let currentPage = indexPath.row / photosPerPage
        preloadPages(for: currentPage)
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PhotoTableViewCell", for: indexPath)
        
        guard let photoTableViewCell = cell as? PhotoTableViewCell else {
            return cell
        }
        
        photoTableViewCell.setData(photo: fetchedResultsController.object(at: indexPath))
        
        return photoTableViewCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        vc.photo = fetchedResultsController.object(at: indexPath)
        
        tableView.deselectRow(at: indexPath, animated: true)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let numberOfSections = fetchedResultsController.sections?.count else {
            return 0
        }
        
        return numberOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let numberOfRowsInSection = fetchedResultsController.sections?[section].numberOfObjects else {
            return 0
        }
        
        return numberOfRowsInSection
    }
}

extension RootViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
    }
}

extension RootViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { (indexPath) in
            let photo = fetchedResultsController.object(at: indexPath)
            photo.getIcon(width: 180, height: 120) {_ in }
        }
    }
}

