//
//  ShowsViewController.swift
//  Swift Watch
//
//  Created by Victor Ragojos on 7/23/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import UIKit
import Promises
import SkeletonView

class ShowsViewController: UIViewController {
    var shows: [[Show]?] = []
    var sections: [ShowSectionCell] = [
        ShowSectionCell(section: ShowSection(title: "Airing Today"), type: .featured),
        ShowSectionCell(section: ShowSection(title: "Popular"), type: .regular),
        ShowSectionCell(section: ShowSection(title: "On The Air"), type: .regular),
        ShowSectionCell(section: ShowSection(title: "Top Rated"), type: .regular),
    ]
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.backgroundColor = .clear
        tableView.delaysContentTouches = false
        for (index, section) in sections.enumerated() {
            if section.type == .featured {
                let identifier = "ShowsFeaturedCollectionView+\(index)"
                tableView.register(ShowsFeaturedCollectionView.self, forCellReuseIdentifier: identifier)
            } else {
                let identifier = "ShowsCollectionView+\(index)"
                tableView.register(ShowsCollectionView.self, forCellReuseIdentifier: identifier)
            }
        }
        
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backBarButton = UIBarButtonItem(title: "", style: .done, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = backBarButton
        view.backgroundColor = UIColor(named: "backgroundColor")
        
        view.addSubview(tableView)
        tableView.fillSuperview()
        
        let promises = [
            sections[0].section.fetchSection(with: .onTheAirToday),
            sections[1].section.fetchSection(with: .popular),
            sections[2].section.fetchSection(with: .onTheAir),
            sections[3].section.fetchSection(with: .topRated)
        ]
        
        all(promises)
            .then { [weak self] (results) in
                // Loop through all the results
                // and append to shows array
                for data in results {
                    self?.shows.append(data)
                }
                
                // Reload TableView's Data
                // in the Main Thread
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
        }
    }
}

// MARK: - UITableViewDelegate
extension ShowsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = OverviewHeader()
        
        headerView.configure(with: sections[section].section.title ?? "")
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellType = sections[indexPath.section].type
        switch cellType {
        case .featured:
            let height: CGFloat = .getHeight(with: K.Overview.featuredCellWidth, using: K.Overview.featuredImageRatio)
            return height + 45
        default:
            let height: CGFloat = K.Poster.height
            return height + 45
        }
    }
}

// MARK: - UITableViewDataSource
extension ShowsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellType = sections[indexPath.section].type
        
        if cellType == .featured {
            let identifier = "ShowsFeaturedCollectionView+\(indexPath.section)"
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! ShowsFeaturedCollectionView
            
            if shows.count > indexPath.section, let data = shows[indexPath.section] {
                cell.delegate = self
                
                let section = indexPath.section
                cell.configure(shows: data, section: section)
            }
            return cell
        } else {
            let identifier = "ShowsCollectionView+\(indexPath.section)"
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! ShowsCollectionView
            
            if shows.count > indexPath.section, let data = shows[indexPath.section] {
                cell.delegate = self
                
                let section = indexPath.section
                cell.configure(shows: data, section: section)
            }
            return cell
        }
    }
}

// MARK: - MovieCollectionViewTableViewCellDelegate
// Passes up the Index Path of the selected Movie
extension ShowsViewController: ShowsCollectionViewDelegate {
    func select(show: IndexPath) {
//        guard let safeMovie = shows[movie.section]?[movie.row] else { return }
//        let detailVC = MovieDetailViewController(with: safeMovie)
//        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - TabBarAnimation
extension ShowsViewController {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard let tbc = self.tabBarController as? TabBarController else { return }
        if scrollView.panGestureRecognizer.translation(in: scrollView).y < 0 {
            tbc.hideTabBar(hide: true)
        } else {
            tbc.hideTabBar(hide: false)
        }
    }
}

