//
//  SpeedRequest.swift
//  2Fast2Fiberous
//
//  Created by Olga Galchenko on 4/19/20.
//  Copyright © 2020 Olga Galchenko. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

class SpeedRequest: ObservableObject {
  @Published var speed: Float?
  var sub: AnyCancellable?

  func sendRequest() {
    let publisher = SpeedTestAPI.getTargets(token: "YXNkZmFzZGxmbnNkYWZoYXNkZmhrYWxm")

    sub = publisher
      .sink(receiveCompletion: { (completion) in
        switch completion {
        case .failure(let error):
          print("error: \(error)")
        case .finished:
          print("finished!")
        }
      }) { targets in
        let subscribers = targets.map { target -> () in
          URLSession.shared
//            .dataTaskPublisher(for: target.url)
            .downloadTaskPublisher(for: target.url)
            .subscribe(DownloadTaskSubscriber())
        }
        print(subscribers)
        self.speed = 500
    }
  }
}
