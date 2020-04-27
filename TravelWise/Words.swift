//
//  Words.swift
//  TravelWise
//
//  Created by Kathleen Garrity.
//  Copyright © 2020 Kathleen Garrity. All rights reserved.
//

import Foundation

class Word: Codable {
    
    var word = ""
//    struct Results: Codable {
//        var definition = ""
//    }
    
    
//    var results: [Results] = []
    var definition = ""
    
    
    func getData(wordToDefine: String, completed: @escaping ()->()) {
        
        let wordEntered = wordToDefine.replacingOccurrences(of: " ", with: "%20")
        //let word = wordToDefine
        
        let url = URL(string: "https://wordsapiv1.p.mashape.com/")
        
        guard url != nil else {
            print("🚫 ERROR creating URL object")
            return
        }
        
        
        let request = NSMutableURLRequest(url: NSURL(string: "https://wordsapiv1.p.rapidapi.com/\(word)")! as URL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
        
        let headers = ["x-rapidapi-host": "wordsapiv1.p.rapidapi.com",
                       "x-rapidapi-key": "\(APIKeys.wordKey)"
        ]
        
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest) { (data, response, error) in
            if let error = error {
                print("😡 ERROR: \(error.localizedDescription)")
            }
            if data == nil {
                print("Data is still nil")
            }
            
            
            do {
                let result = try JSONDecoder().decode(Word.self, from: data!)
                self.definition = result.definition
                
            } catch {
                print("😡 JSON ERROR: \(error.localizedDescription)")
            }
            completed()
            
        }
        dataTask.resume()
    }
    
}

