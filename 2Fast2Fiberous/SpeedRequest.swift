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
          print(error)
        case .finished:
          print("Finished")
        }
        print("printing error: \(completion)")
      }) { (viewModel) in
        print("viewModel: \(viewModel)")
        self.speed = 500
    }
    //(with: url) { [weak self] (data, response, error) in
//      guard let data = data else { return }
//      print(data)
//      print(response)
//      print(error)
//      self?.speed = 500
//    }.resume()
  }
}
