//
//  DetailViewController.swift
//  Flicks
//
//  Created by Emmanuel Sarella on 3/29/17.
//  Copyright © 2017 Emmanuel Sarella. All rights reserved.
//

import UIKit
import AFNetworking

class DetailViewController: UIViewController {

    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var infoView: UIView!

    var movie: NSDictionary!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.barStyle = UIBarStyle.blackTranslucent
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0.95, green: 0.71, blue: 0.21, alpha: 1.0)

        scrollView.contentSize = CGSize(width: scrollView.frame.size.width
                , height: infoView.frame.origin.y + infoView.frame.size.height)

        let title = movie["title"] as? String
        titleLabel.text = title

        let overview = movie["overview"] as? String
        overviewLabel.text = overview

        overviewLabel.sizeToFit()

        if let posterPath = movie["poster_path"] as? String {
            let posterBaseUrl = "https://image.tmdb.org/t/p/w500"
            let posterUrl = URL(string: posterBaseUrl + posterPath)
            posterImageView.setImageWith(posterUrl!)
        } else {
            posterImageView = nil
        }

    }

}
