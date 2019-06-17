//
//  PhotoRepository.swift
//  Picsum
//
//  Created by Denis Kreshikhin on 17/06/2019.
//  Copyright © 2019 Ivan. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class PhotoRepository {
    static let shared = PhotoRepository()
    
    private let persistentContainer = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    private let operationQueue = OperationQueue()
    
    private init() {}
    
    private class LoadPageOperation: Operation {
        var page: Int = 0
        var block: () -> () = {}
        
        override func main() {
            block()
        }
        
        override func start() {
            super.start()
        }
    }
    
    func createFetchedResultsController() -> NSFetchedResultsController<PhotoCD> {
        let fetchRequest: NSFetchRequest<PhotoCD> = PhotoCD.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managerContext = appDelegate.persistentContainer.viewContext
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managerContext, sectionNameKeyPath: nil, cacheName: nil)
        return fetchedResultsController
    }
    
    var countOfLoadedPhotos: Int {
        guard let viewContext = persistentContainer?.viewContext else {
            return 0
        }
        
        let fetchRequest: NSFetchRequest<PhotoCD> = PhotoCD.fetchRequest()
        
        guard let count = try? viewContext.count(for: fetchRequest) else {
            return 0
        }
        
        return count
    }
    
    func loadPhotos(_ page: Int = 0) {
        guard let persistentContainer = persistentContainer, !operationQueue.operations.contains(where: { ($0 as? LoadPageOperation)?.page == page }) else {
            return
        }
        
        let operation = LoadPageOperation()
        operation.page = page
        operation.block = {
            ApiManager.shared.getPhotos(page: page){ photosDTO, error in
                guard error == nil else {
                    return
                }
                
                persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
                
                persistentContainer.performBackgroundTask({ (backgroundContext) in
                    let entity = NSEntityDescription.entity(forEntityName: "PhotoCD", in: backgroundContext)!
                    
                    for photoDTO in photosDTO {
                        let fetchRequest: NSFetchRequest<PhotoCD> = PhotoCD.fetchRequest()
                        fetchRequest.predicate = NSPredicate(format: "id == %@", photoDTO.id)
                        
                        let fetchedPhoto = try? backgroundContext.fetch(fetchRequest).first
                        
                        guard let photo = fetchedPhoto ?? NSManagedObject(entity: entity, insertInto: backgroundContext) as? PhotoCD else {
                            continue
                        }
                        
                        photo.update(with: photoDTO)
                    }
                    
                    try? backgroundContext.save()
                    persistentContainer.viewContext.performAndWait {
                        try? persistentContainer.viewContext.save()
                    }
                })
            }
        }
        operationQueue.addOperation(operation)
    }
    
}
