//
//  SpeedPublisher.swift
//  2Fast2Fiberous
//
//  Created by Olga Galchenko on 5/3/20.
//  Copyright © 2020 Olga Galchenko. All rights reserved.
//

import Combine
import Foundation

public class SpeedyMcSpeedface {

  let subject = CurrentValueSubject<Double, Error>(0)
  let targetList: [Target]
  var sinkOperation: AnyCancellable?
  var cancellables: [AnyCancellable] = []
  var completed: Int64 = 0
  var time = Date()

  public init(targetList: [Target]) {
    self.targetList = targetList
    start()
  }

  deinit {

  }

  public func start() {
    guard let firstTarget = targetList.first else { return }

    time = Date()

    URLSession.shared
      .downloadTaskPublisher(for: firstTarget.url)
      .sink(receiveCompletion: { (completion) in
        switch completion {
        case .failure(_):
          break
        case .finished:
          break
        }
      }) { (completedCount: Int64, totalCount: Int64, requestedURL: URL) in
        self.completed = completedCount
        let elapsedTime = Date().timeIntervalSince(self.time)
        let currentSpeed = Double(self.completed * 8)/elapsedTime/1000000
        self.subject.send(currentSpeed)
    }
    .store(in: &cancellables)
  }
}

public class SpeedSubscription<SubscriberType: Subscriber>: Subscription where SubscriberType.Input == Double, SubscriberType.Failure == Error {

  init(subscriber: SubscriberType) {
    self.subscriber = subscriber
  }

  deinit {
    print("speed subscritpion is deinited")
  }

  public func request(_ demand: Subscribers.Demand) {
  }

  public func cancel() {
    subscriber = nil
  }

  private var subscriber: SubscriberType?
}
