//
//  LikedMomentsViewController.swift
//  Podcasts
//
//  Created by mac on 08.11.2021.
//

import UIKit

class LikedMomentsViewController: UIViewController {

    @IBOutlet private var likedMomentsTableView: UITableView!
    private var currentPodcast: LikedMoment?
    
    private var cellHeight: CGFloat = 75.0
    
    weak var delegate: LikedMomentsViewControllerDelegate?
    
    lazy private var likedMoments: [LikedMoment] = {
        if let data = UserDefaults.standard.data(forKey: "LikedMoments") {
            do {
                let decode = JSONDecoder()
                let moments = try decode.decode([LikedMoment].self, from: data)
                return moments
            } catch {
                print("Error of decoding")
            }
        }
        let moments: [LikedMoment] = []
        return moments
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        likedMomentsTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        subscribeOnDataSourceAndDelegate()
        likedMomentsTableView.register(PodcastCell.self)
    }
    
    private func subscribeOnDataSourceAndDelegate() {
        likedMomentsTableView.delegate = self
        likedMomentsTableView.dataSource = self
    }

}

extension LikedMomentsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let data = UserDefaults.standard.data(forKey: "LikedMoments") {
            do {
                let decode = JSONDecoder()
                let moments = try decode.decode([LikedMoment].self, from: data)
                let moment = moments[indexPath.row]
                delegate?.likedMomentsViewController(self, moment)
            } catch {
                print("Error of decoding")
            }
        }

    }
    
}

extension LikedMomentsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return likedMoments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let podcast = likedMoments[indexPath.row].podcast
        let cell = likedMomentsTableView.dequeueReusableCell(withIdentifier: PodcastCell.identifier, for: indexPath) as! PodcastCell
        cell.configureCell(with: podcast, indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
}
