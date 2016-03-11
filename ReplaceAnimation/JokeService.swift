//
//  JokeService.swift
//  ReplaceAnimation
//
//  Created by Alexander Hüllmandel on 11/03/16.
//  Copyright © 2016 Alexander Hüllmandel. All rights reserved.
//

import Foundation

protocol JokeService {
  func getJoke(completion : ((Joke?)->Void))
}

class JokeWebService : JokeService {
  private var dataTask : NSURLSessionTask?
  
  func getJoke(completion: ((Joke?) -> Void)) {
    guard dataTask == nil else { return }
    
    let url = NSURL(string: "http://tambal.azurewebsites.net/joke/random")
      self.dataTask = NSURLSession.sharedSession().dataTaskWithURL(url!) { (data, response, error) -> Void in
        guard let data = data else { completion(nil); return }
        
        var json: [String:AnyObject]?
        do {
          json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()) as? [String:AnyObject]
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
