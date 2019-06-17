//
//  DetailViewController.swift
//  Picsum
//
//  Created by Ivan on 16/06/2019.
//  Copyright © 2019 Ivan. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    var photo: PhotoCD?
    
    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupView()
    }
    
    private func setupView() {
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.startAnimating()
        photo?.getDefaultIcon(completion: { [weak self] (image) in
            self?.photoImageView.image = image
            self?.loadFullImage()
        })
        setupDate(photo?.date as Date?)
    }
    
    private func loadFullImage() {
        photo?.getFullImage(completion: { [weak self] (image, date)  in
            guard let image = image else {
                return
            }
            
            self?.setupDate(date)
            self?.activityIndicatorView?.stopAnimating()
            self?.photoImageView?.image = image
        })
    }
    
    private func setupDate(_ date: Date?) {
        if let date = date {
            authorLabel.text = "загруженно: " + dateFormatter.string(from: date as Date)
        } else {
            authorLabel.text = "..."
        }
    }
}
