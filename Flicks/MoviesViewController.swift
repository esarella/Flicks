//
//  MoviesViewController.swift
//  Flicks
//
//  Created by Emmanuel Sarella on 3/29/17.
//  Copyright © 2017 Emmanuel Sarella. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!

    var movies: [NSDictionary]?
    var endpoint: String?
    var filteredData: [NSDictionary]!
    var loadViewFirstTime = true


    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self

        self.navigationController?.navigationBar.barStyle = UIBarStyle.blackTranslucent
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0.95, green: 0.71, blue: 0.21, alpha: 1.0)
        self.navigationController?.navigationBar.tintColor = UIColor.black

        let refreshControl = UIRefreshControl()

        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: UIControlEvents.valueChanged)

        tableView.insertSubview(refreshControl, at: 0)

    }

    override func viewWillAppear(_ animated: Bool) {
        if (loadViewFirstTime == true) {
            loadMovies()
            loadViewFirstTime = false
        }

    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let movies = self.filteredData {
            return movies.count
        } else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        let movie = filteredData![indexPath.row]

        let title = movie["title"] as! String
        let overview = movie["overview"] as! String

        cell.titleLabel.text = "\(title)"
        cell.overviewLabel.text = "\(overview)"

        if let posterPath = movie["poster_path"] as? String {

            let posterBaseUrl = "https://image.tmdb.org/t/p/"
            let lowResPosterUrl = URL(string: posterBaseUrl + "w45" + posterPath)
            let highResPosterUrl = URL(string: posterBaseUrl + "original" + posterPath)

            let lowResImageRequest = NSURLRequest(url: lowResPosterUrl!)
            let highResImageRequest = NSURLRequest(url: highResPosterUrl!)

            cell.posterView.setImageWith(
                    lowResImageRequest as URLRequest,
                    placeholderImage: nil,
                    success: { (lowResImageRequest, lowResImageResponse, lowResImage) -> Void in

                        cell.posterView.alpha = 0.0
                        cell.posterView.image = lowResImage
                        UIView.animate(withDuration: 0.3, animations: { () -> Void in
                            cell.posterView.alpha = 1.0
                        }, completion: { (success) -> Void in

                            cell.posterView.setImageWith(
                                    highResImageRequest as URLRequest,
                                    placeholderImage: lowResImage,
                                    success: { (highResImageRequest, highResImageResponse, highResImage) -> Void in

                                        cell.posterView.image = highResImage;
                                    },
                                    failure: { (request, response, error) -> Void in
                                        self.errorView.isHidden = false

                                    })
                        })

                    },
                    failure: { (request, response, error) -> Void in
                        self.errorView.isHidden = false

                    })
        } else {
            cell.posterView.image = nil
        }
        return cell
    }

    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell

        let baseUrl = "http://image.tmdb.org/t/p/w500"
        let movie = filteredData![indexPath.row]

        if let title = movie["title"] as? String {
            cell.titleLabel.text = title
            cell.titleLabel.textColor = UIColor.black
        }

        if let overview = movie["overview"] as? String {
            cell.overviewLabel.text = overview
            cell.overviewLabel.textColor = UIColor.black
        }

        if let posterPath = movie["poster_path"] as? String {
            let posterImageUrl = URL(string: baseUrl + posterPath)
            cell.posterView.setImageWith(posterImageUrl!)
        }

        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.white
        cell.selectedBackgroundView = backgroundView

        tableView.deselectRow(at: indexPath, animated: true)
    }

    func refreshControlAction(_ refreshControl: UIRefreshControl) {

        loadMovies()
        refreshControl.endRefreshing()
    }

    func loadMovies() {
        let apiKey = "dd14cbf0944a25730ce1050bf471193b"
        let url = URL(string: "https://api.themoviedb.org/3/movie/\(endpoint!)?api_key=\(apiKey)")
        let request = URLRequest(url: url!)
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: OperationQueue.main)
        MBProgressHUD.showAdded(to: self.view, animated: true)

        let task: URLSessionDataTask = session.dataTask(with: request, completionHandler: { (dataOrNil, response, error) in

            MBProgressHUD.hide(for: self.view, animated: true)

            if let httpError = error {
                print("\(httpError)")
                self.errorView.isHidden = false
            } else {
                if let data = dataOrNil {
                    if let responseDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                        self.movies = responseDictionary["results"] as? [NSDictionary]
                        self.filteredData = self.movies
                        self.errorView.isHidden = true
                        self.tableView.reloadData()
                    }
                }
            }
        });

        task.resume()

    }

    //    MARK: - Search Bar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.filteredData = searchText.isEmpty ? movies : movies?.filter({ (dataDict: NSDictionary) -> Bool in
            // If dataItem matches the searchText, return true to include it
            let title = dataDict["title"] as! String

            // return true if searchText matches title
            return title.range(of: searchText, options: .caseInsensitive) != nil
        })

        tableView.reloadData()

    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        self.filteredData = self.movies
        searchBar.resignFirstResponder()
        self.tableView.reloadData()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()

    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPath(for: cell)
        let movie = filteredData![indexPath!.row]

        let detailViewController = segue.destination as! DetailViewController
        detailViewController.movie = movie

    }

}
