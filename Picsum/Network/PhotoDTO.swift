//
//  Photo.swift
//  Picsum
//
//  Created by Ivan on 14/06/2019.
//  Copyright © 2019 Ivan. All rights reserved.

import Foundation

struct PhotoDTO: Codable {
    
    var id: String
    var author: String?
    var width: Int?
    var height: Int?
    var url: String?
    var downloadUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case author = "author"
        case width = "width"
        case height = "height"
        case url = "url"
        case downloadUrl = "download_url"
    }
}

