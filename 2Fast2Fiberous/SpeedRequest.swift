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
  var cancellables: [AnyCancellable] = []

  func sendRequest() {
    let publisher = SpeedTestAPI.getTargets(token: "YXNkZmFzZGxmbnNkYWZoYXNkZmhrYWxm")

    publisher
      .flatMap({ targetList in
        SpeedyMcSpeedface(targetList: targetList).subject
      })
      .receive(on: DispatchQueue.main)
      .sink(receiveCompletion: { (completion) in
        switch completion {
        case .failure(let error):
          print("error: \(error)")
        case .finished:
          print("finished!")
        }
      }) { currentSpeed in
        print(currentSpeed)
        self.speed = Float(currentSpeed)
    }
  .store(in: &cancellables)
  }
}
