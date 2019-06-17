//
//  Photo+PhotoDTO.swift
//  Picsum
//
//  Created by Denis Kreshikhin on 17/06/2019.
//  Copyright © 2019 Ivan. All rights reserved.
//

import Foundation

extension PhotoCD {
    func update(with photoDTO: PhotoDTO) {
        self.id = photoDTO.id
        self.author = photoDTO.author ?? ""
        self.width = Int32(photoDTO.width ?? 0)
        self.height = Int32(photoDTO.height ?? 0)
        self.url = photoDTO.url ?? ""
        self.downloadUrl = photoDTO.downloadUrl ?? ""
    }
}
