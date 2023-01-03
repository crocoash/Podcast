//
//  String + comform.swift
//  Podcasts
//
//  Created by Tsvetkov Anton on 01.11.2021.
//

import Foundation

extension String {
  
  var conform: String {
    return String(self.map { $0 == " " ? "-" : $0 })
  }
}

extension String {
  
  var encodeUrl : String {
    return self.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
  }
  
  var decodeUrl : String {
    return self.removingPercentEncoding!
  }
}

extension Optional where Wrapped == String  {
  
  var url: URL? {
    guard let stringUrl = self,
          let url = URL(string: stringUrl) else { return nil }
    return url
  }
}

extension Optional where Wrapped == String {
  
  var localPath: URL? {
    return self.url?.localPath
  }
}



