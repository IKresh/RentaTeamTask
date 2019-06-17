//
//  ApiManager.swift
//  Picsum
//
//  Created by Ivan on 16/06/2019.
//  Copyright © 2019 Ivan. All rights reserved.
//

import Foundation
import UIKit

class ApiManager {
    
    static let shared = ApiManager()
    
    enum Path: String {
        case list = "/v2/list"
        case id = "id"
    }
    
    private init() {
        URLSessionConfiguration.default.httpMaximumConnectionsPerHost = 3
        
        let memoryCapacity = 100 * 1024 * 1024 // 100 MB memory cache
        let diskCapacity = 500 * 1024 * 1024 // 500 GB disk cache
        let cache = URLCache(memoryCapacity: memoryCapacity, diskCapacity: diskCapacity, diskPath: "cache")
        URLCache.shared = cache
    }
    
    private func createURLFromParameters(parameters: [String:Any], path: String?) -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "picsum.photos"
        components.path = path ?? ""
        
        if !parameters.isEmpty {
            components.queryItems = [URLQueryItem]()
            for (key, value) in parameters {
                let queryItem = URLQueryItem(name: key, value: "\(value)")
                components.queryItems!.append(queryItem)
            }
        }
        
        return components.url
    }
    
    func getPhotos(page: Int, completion: @escaping (_ photos:[PhotoDTO], _ error: Error?) -> ()) {
        let parameters: [String:Any] = ["page": page + 1]

        guard let url = createURLFromParameters(parameters: parameters, path: Path.list.rawValue) else {
            completion([], nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, reponse, error) in
            guard error == nil, let data = data else {
                completion([], error)
                return
            }
            
            do{
                let result = try JSONDecoder().decode([PhotoDTO].self, from: data)
                completion(result, nil)
            } catch let error {
                completion([], error)
            }
        }.resume()
    }
    
    func loadImage(for id: String, width: Int, height: Int, completion: @escaping (_ image: UIImage?, _ isCached: Bool)->()) {
        guard let url = createURLFromParameters(parameters: [:], path: "/\(Path.id.rawValue)/\(id)/\(width)/\(height)") else {
            completion(nil, false)
            return
        }
        
        loadImage(for: id, url: url, completion: completion)
    }
    
    func loadImage(for id: String, url: URL, completion: @escaping (_ image: UIImage?,_ isCached: Bool)->()) {
        guard let cachedResponse = URLCache.shared.cachedResponse(for: URLRequest(url: url)) else {
            let dataTask = URLSession.shared.dataTask(with: url){ (data, response, error) in
                guard error == nil, let data = data, let image = UIImage(data: data), let response = response else {
                    DispatchQueue.main.async {
                        completion(nil, false)
                    }
                    return
                }
                
                let cachedResponse = CachedURLResponse(response: response, data: data)
                URLCache.shared.storeCachedResponse(cachedResponse, for: URLRequest(url: url))
                
                DispatchQueue.main.async {
                    completion(image, false)
                }
            }
            dataTask.resume()
            return
        }
        
        completion(UIImage(data: cachedResponse.data), true)
    }
}

