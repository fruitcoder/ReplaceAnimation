//
//  JokeService.swift
//  ReplaceAnimation
//
//  Created by Alexander Hüllmandel on 11/03/16.
//  Copyright © 2016 Alexander Hüllmandel. All rights reserved.
//

import Foundation

protocol JokeService {
    func getJoke(completion : ( @escaping (Joke?)->Void))
}

class JokeWebService : JokeService {
    
    private var dataTask : URLSessionTask?
    
    func getJoke(completion: @escaping ((Joke?) -> Void)) {
        guard dataTask == nil else { return }
        
        let url = URL(string: "https://icanhazdadjoke.com/") //Removed Due to url not working http://tambal.azurewebsites.net/joke/random")
        var urlRequest = URLRequest(url: url!)
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        
        self.dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) -> Void in
            guard let data = data else { completion(nil); return }
            
            var json: [String:AnyObject]?
            do {
                json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as? [String:AnyObject]
            } catch {
                completion(nil)
            }
            
            completion(Joke(json: json!))
            self.dataTask = nil
        }
        self.dataTask?.resume()
    }
    
    func cancelFetch() {
        dataTask?.cancel()
        dataTask = nil
    }
}
