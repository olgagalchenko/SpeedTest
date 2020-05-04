//
//  DownloadTaskSubscriber.swift
//  2Fast2Fiberous
//
//  Created by Olga Galchenko on 4/19/20.
//  Copyright © 2020 Olga Galchenko. All rights reserved.
//

import Foundation
import Combine

final class DownloadTaskSubscriber: Subscriber {
  typealias Input = (completedCount: Int64, totalCount: Int64, requestedURL: URL)
  typealias Failure = URLError

  var subscription: Subscription?

  func receive(subscription: Subscription) {
    self.subscription = subscription
    self.subscription?.request(.unlimited)
    startTime = Date()
  }

  func receive(_ input: Input) -> Subscribers.Demand {
    print("Subscriber value \(input)")
    let elapsedTime = Date().timeIntervalSince(startTime)
    print("Downloaded \(input.completedCount) in \(elapsedTime)")
    let currentSpeed = Double(input.completedCount * 8) / elapsedTime
    print("Current speed: \(currentSpeed)")
    return .unlimited
  }

  func receive(completion: Subscribers.Completion<Failure>) {
    print("Subscriber completion \(completion)")
    self.subscription?.cancel()
    self.subscription = nil
  }

  var startTime: Date = Date()
}
