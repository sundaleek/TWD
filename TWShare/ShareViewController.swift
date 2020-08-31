//
//  ShareViewController.swift
//  TWShare
//
//  Created by David Ozmanyan on 01.09.2020.
//  Copyright © 2020 David Ozmanyan. All rights reserved.
//

import UIKit
import MobileCoreServices


let kAppGroupsName = "group.davidozmanyan.TWDownloader"
let kUrlArray = "kUrlArray"

class ShareViewController: UIViewController {

    @IBOutlet weak var button: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        let defaults = UserDefaults(suiteName: kAppGroupsName)

        var urls = (defaults?.array(forKey: kUrlArray) as? [String]) ?? []

        dump(urls)
    }

    @IBAction func onTap(_ sender: UIButton) {
        let defaults = UserDefaults(suiteName: kAppGroupsName)
        let extensionItem = extensionContext?.inputItems[0] as! NSExtensionItem
        let contentTypeURL = kUTTypeURL as String
        guard let attachments = extensionItem.attachments else {return}
        for attachment in attachments {
            if attachment.hasItemConformingToTypeIdentifier(kUTTypeURL as String) {
                attachment.loadItem(forTypeIdentifier: contentTypeURL, options: nil, completionHandler: { (results, error) in
                    let url = results as! NSURL
                    var urls = (defaults?.array(forKey: kUrlArray) as? [String]) ?? []
                    if let u = url.absoluteString, u != "" {
                        urls.append(u)
                        defaults?.set(urls, forKey: kUrlArray)
                        defaults?.synchronize()
                    }
                })
            }
        }
        extensionContext?.completeRequest(returningItems: [], completionHandler: { (success) in
            print(success)
            if let url = URL(string: "TWDownloader://") {
                self.openURL(url)
            }
        })
    }

    @discardableResult @objc
    func openURL(_ url: URL) -> Bool {
        var responder: UIResponder? = self
        while responder != nil {
            if let application = responder as? UIApplication {
                return application.perform(#selector(openURL(_:)), with: url) != nil
            }
            responder = responder?.next
        }
        return false
    }
}
