//
//  PhotoTableViewCell.swift
//  Picsum
//
//  Created by Ivan on 16/06/2019.
//  Copyright © 2019 Ivan. All rights reserved.

import UIKit

class PhotoTableViewCell: UITableViewCell {

    @IBOutlet weak var containerView: UILabel!
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var AuthorLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.layer.cornerRadius = 4
        iconView.layer.cornerRadius = 4
        activityIndicatorView.hidesWhenStopped = true
    }
    
    func setData(photo: PhotoCD) {
        
        AuthorLabel.text = "\(photo.author ?? "")"
        sizeLabel.text = "size: \(photo.width)x\(photo.height)"
        iconView.image = UIImage(named: "")
        
        activityIndicatorView.startAnimating()
        photo.getIcon(width: 180, height: 120) { [weak self] (icon) in
            guard let icon = icon else {
                return
            }
            
            self?.iconView.image = icon
            self?.activityIndicatorView.stopAnimating()
        }
    }
}

