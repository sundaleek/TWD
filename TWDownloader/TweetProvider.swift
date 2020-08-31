import UIKit
import PromiseKit

struct TweetProvider {

    func getTweet(by url: String) -> Promise<Tweet> {
        return Promise<Tweet>.init { (resolver) in
            let split = url.split(separator: "/")
            dump(split)
            let split5 = String(split[safe: 4] ?? "")
            let video_id: String = url.contains("?=") ? String(split5.split(separator: "?")[safe:0] ?? "") : split5

            let sources = [
                "video_url" : "https://twitter.com/i/videos/tweet/"+video_id,
                "activation_ep" :"https://api.twitter.com/1.1/guest/activate.json",
                "api_ep" : "https://api.twitter.com/1.1/statuses/show.json?id="+video_id
            ]

            var headers = [
                "User-agent" : "Mozilla/5.0 (Windows NT 6.3; Win64; x64; rv:76.0) Gecko/20100101 Firefox/76.0",
                "accept" : "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9",
                "accept-language" : "es-419,es;q=0.9,es-ES;q=0.8,en;q=0.7,en-GB;q=0.6,en-US;q=0.5"
            ]


            guard let token_request = (try? makeRequest(url: sources["video_url"] ?? "", method: "GET", headers: headers).wait()) else {
                resolver.reject(TWDError.noTokenRequest)
                return
            }

            guard let d = try? NSRegularExpression(pattern: "src=\"(.*js)") else {
                resolver.reject(TWDError.regexPatternFailure)
                return
            }

            let range = NSRange(location: 0, length: token_request.utf16.count)
            let ns = token_request as NSString

            guard let fm = d.firstMatch(in: token_request, range: range) else {
                resolver.reject(TWDError.noBearerToken)
                return
            }

            let bearer_file = ns.substring(with: fm.range)
                .replacingOccurrences(of: "src=\"", with: "")
                .replacingOccurrences(of: "\"", with: "")

            guard let file_content = try? makeRequest(url: bearer_file, method: "GET", headers: headers).wait()  else {
                resolver.reject(TWDError.noFileContent)
                return
            }

            guard let bearer_token_pattern = try? NSRegularExpression(pattern: "Bearer ([a-zA-Z0-9%-])+") else {
                resolver.reject(TWDError.regexPatternFailure)
                return
            }

            let r = NSRange(location: 0, length: file_content.utf16.count)

            guard let fm2 = bearer_token_pattern.firstMatch(in: file_content, range: r) else {
                resolver.reject(TWDError.noBearerToken)
                return
            }
            let bearer_token = (file_content as NSString).substring(with: fm2.range)
            headers["authorization"] = bearer_token
            guard let req2 = try? makeRequest(url: sources["activation_ep"] ?? "", method: "POST", headers: headers).wait() else {
                resolver.reject(TWDError.req2)
                return
            }
            guard let json = try? convertStringToJSON(req2).wait() else {
                resolver.reject(TWDError.unknown)
                return
            }
            headers["x-guest-token"] = (json["guest_token"] as? String) ?? ""
            guard let tweet  = try? getTweet(url: sources["api_ep"] ?? "", method: "GET", headers: headers).wait() else {
                resolver.reject(TWDError.noApiRequest)
                return
            }
            resolver.fulfill(tweet)
        }
    }

    private func makeRequest(url: String, method: String, headers: [String: String]) -> Promise<String> {
        return Promise<String> { (resolver) in
            if let url = URL(string: url) {
                var request = URLRequest(url: url)
                for (key, value) in headers {
                    request.setValue(value, forHTTPHeaderField: key)
                }
                request.httpMethod = method
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    guard let data = data,
                        let response = response as? HTTPURLResponse,
                        error == nil else {                                              // check for fundamental networking error
                            resolver.reject(error ?? TWDError.unknown)
                            return
                    }

                    if let jsonString = String(data: data, encoding: .utf8) {
                        resolver.fulfill(jsonString)
                    }else {
                        resolver.reject(TWDError.unknown)
                    }
                }
                task.resume()
            }else {
                resolver.reject(TWDError.unknown)
            }
        }
    }

    private func getTweet(url: String, method: String, headers: [String: String]) -> Promise<Tweet> {
        return Promise<Tweet> { (resolver) in
            if let url = URL(string: url) {
                var request = URLRequest(url: url)
                for (key, value) in headers {
                    request.setValue(value, forHTTPHeaderField: key)
                }
                request.httpMethod = method
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    guard let data = data,
                        error == nil else {
                            resolver.reject(error ?? TWDError.unknown)
                            return
                    }

                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("$$$", jsonString)
                    }
                    guard let tweet = try? JSONDecoder().decode(Tweet.self,
                                                                from: data) else {
                        resolver.reject(TWDError.parsingError)
                        return
                    }
                    resolver.fulfill(tweet)
                }
                task.resume()
            }else {
                resolver.reject(TWDError.unknown)
            }
        }

    }

    private func convertStringToJSON(_ str: String) -> Promise<[String:Any]> {
        return Promise<[String:Any]>.init { (resolver) in
            guard let data = str.data(using: .utf8) else {
                resolver.reject(TWDError.noData)
                return
            }
            do {
                if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [String:Any]
                {
                    resolver.fulfill(jsonArray)
                } else {
                    resolver.reject(TWDError.unknown)
                }
            } catch let error as NSError {
                resolver.reject(error)
            }
        }
    }

}
enum TWDError: Error {
    case unknown
    case noBearerToken, regexPatternFailure, noFileContent, noTokenRequest
    case req2
    case noData
    case noApiRequest
    case parsingError
}

extension Collection {

    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
