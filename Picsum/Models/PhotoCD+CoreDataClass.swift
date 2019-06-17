//
//  PhotoCD+CoreDataClass.swift
//  Picsum
//
//  Created by Ivan on 16/06/2019.
//  Copyright © 2019 Ivan. All rights reserved.
//
//

import Foundation
import CoreData
import UIKit

@objc(PhotoCD)
public class PhotoCD: NSManagedObject {
    func getDefaultIcon(completion: @escaping (_ image: UIImage?)->()) {
        getIcon(width: 180, height: 120, completion: completion)
    }
    
    func getIcon(width: Int, height: Int, completion: @escaping (_ image: UIImage?)->()) {
        guard let id = id else {
            completion(nil)
            return
        }
        
        ApiManager.shared.loadImage(for: id, width: width, height: height) { (image, isCached) in
            guard let image = image else {
                completion(nil)
                return
            }
            
            completion(image)
        }
    }
    
    func getFullImage(completion: @escaping (_ image: UIImage?, _ date: Date?)->()) {
        guard let id = id, let urlString = downloadUrl, let url = URL(string: urlString) else {
            completion(nil, nil)
            return
        }
        
        ApiManager.shared.loadImage(for: id, url: url) { [weak self](image, isCached) in
            guard let image = image else {
                completion(nil, nil)
                return
            }
            
            guard isCached else {
                let newDate = Date()
                self?.updateDate(date: newDate)
                completion(image, newDate)
                return
            }
            
            completion(image, self?.date as Date?)
        }
    }
    
    private func updateDate(date: Date) {
        let persistentContainer = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
        
        persistentContainer?.viewContext.automaticallyMergesChangesFromParent = true
        
        persistentContainer?.performBackgroundTask({ [weak self] (backgroundContext) in
            self?.date = date as NSDate
            
            try? backgroundContext.save()
        })
    }
}
