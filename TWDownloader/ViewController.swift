//
//  ViewController.swift
//  TWDownloader
//
//  Created by David Ozmanyan on 31.08.2020.
//  Copyright © 2020 David Ozmanyan. All rights reserved.
//

import UIKit
import PromiseKit

let kAppGroupsName = "group.davidozmanyan.TWDownloader"
let kUrlArray = "kUrlArray"

class ViewController: UIViewController {

    let tweetProvider = TweetProvider()
    var datasource = [Tweet]()

    let tableView: UITableView = {
        let tw = UITableView()
        tw.register(TableViewCell.self, forCellReuseIdentifier: "TableViewCell")
        tw.tableFooterView = UIView()
        return tw
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (m) in
            m.edges.equalToSuperview()
        }
        tableView.delegate = self
        tableView.dataSource = self
        fetch()
    }

    func fetch() {
        let defaults = UserDefaults(suiteName: kAppGroupsName)

        let urls = (defaults?.array(forKey: kUrlArray) as? [String]) ?? []
        var tweets = [Tweet]()

        DispatchQueue.global().async { [weak self] in
            guard let self = self else {return}
            let promises = urls.map {self.tweetProvider.getTweet(by: $0)}
            when(resolved: promises).done { (result) in
                let tweetArr = result
                    .filter {$0.isFulfilled}
                    .compactMap { r -> Tweet? in
                    switch r {
                    case .fulfilled(let t): return t
                    default: return nil
                    }
                }.filter {$0.videoUrl != ""}
                DispatchQueue.main.async { [weak self] in
                    self?.datasource = tweetArr
                    self?.tableView.reloadData()
                }
            }
        }

    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! TableViewCell
        cell.configure(with: datasource[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datasource.count
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = DetailVC()
        vc.url = URL(string: datasource[indexPath.row].videoUrl)
        self.navigationController?.pushViewController(vc, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
