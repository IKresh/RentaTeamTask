//
//  ApiManager.swift
//  LifeHackTask
//
//  Created by Ivan on 11/06/2019.
//  Copyright © 2019 Ivan. All rights reserved.
//

import Foundation



class ApiManager {
    
    static let shared = ApiManager()
    
    private struct Constants {
        struct APIDetails {
            // https://picsum.photos/v2/list
            static let APIScheme = "https"
            static let APIHost = "picsum.photos"
            static let APIPath = "/v2/list"
        }
    }
    
    private init() {}
    
    private func createURLFromParameters(parameters: [String:Any], pathparam: String?) -> URL {
        var components = URLComponents()
        components.scheme = Constants.APIDetails.APIScheme
        components.host   = Constants.APIDetails.APIHost
        components.path   = Constants.APIDetails.APIPath
        if let paramPath = pathparam {
            components.path = Constants.APIDetails.APIPath + "\(paramPath)"
        }
        if !parameters.isEmpty {
            components.queryItems = [URLQueryItem]()
            for (key, value) in parameters {
                let queryItem = URLQueryItem(name: key, value: "\(value)")
                components.queryItems!.append(queryItem)
            }
        }
        return components.url!
    }
    
    func getPhotos(page: Int?, completion: @escaping (_ photos:[PhotoDTO], _ error: String?) -> ()) {
        
        var parameters: [String:Any] = [:]
        if let page = page {
           parameters = ["page": page]
        }

        let url = createURLFromParameters(parameters: parameters, pathparam: nil)
        URLSession.shared.dataTask(with: url) { (data, reponse, error) in
            guard let data = data else {return}
            guard  error == nil else {return}
            do{
                let result = try JSONDecoder().decode([PhotoDTO].self, from: data)
                completion(result, nil)
            } catch let error {
                
                completion([], error.localizedDescription)
                
            }
            }.resume()
    }
    
    func getPhotos( completion: @escaping (_ photos:[PhotoDTO], _ error: String?) -> ()) {
        getPhotos(page: nil, completion: completion)
    }
}

