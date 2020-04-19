//
//  SpeedTestAPI.swift
//  2Fast2Fiberous
//
//  Created by Olga Galchenko on 4/19/20.
//  Copyright © 2020 Olga Galchenko. All rights reserved.
//

import Foundation
import Combine

enum SpeedTestAPI {
  static func targetURL(with token: String) -> URL {
    var components = URLComponents()

    components.scheme = "https"
    components.host = "api.fast.com"
    components.path = "/netflix/speedtest/v2"

    let httpsItem = URLQueryItem(name: "https", value: String(true))
    let urlCountItem = URLQueryItem(name: "urlCount", value: String(5))
    let tokenItem = URLQueryItem(name: "token", value: token)
    components.queryItems = [httpsItem, urlCountItem, tokenItem]

    return components.url!
  }
}

extension SpeedTestAPI {
  static func getTargets(token: String) -> AnyPublisher<[Target], Error> {
    let request = targetURL(with: token)
    return URLSession.shared
      .dataTaskPublisher(for: request)
      .map(\.data)
      .decode(type: Response.self, decoder: JSONDecoder())
      .map(\.targets)
      .receive(on: DispatchQueue.main)
      .eraseToAnyPublisher()
  }
}

struct Response: Codable {
  let targets: [Target]
}

struct Target: Codable {
  let url: URL
}
