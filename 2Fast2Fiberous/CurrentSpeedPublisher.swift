//
//  CurrentSpeedPublisher.swift
//  2Fast2Fiberous
//
//  Created by Olga Galchenko on 5/3/20.
//  Copyright © 2020 Olga Galchenko. All rights reserved.
//

import Combine
import Foundation

public class CurrentSpeedPublisher {

  // MARK: Lifecycle

  public init(targetList: [Target]) {
    self.targetList = targetList
    start()
  }

  // MARK: Public

  let subject = CurrentValueSubject<Double, Error>(0)
  let targetList: [Target]

  public func start() {
    time = Date()
    targetList.forEach { (target) in
      URLSession.shared
        .downloadTaskPublisher(for: target.url)
        .sink(receiveCompletion: { (completion) in
          switch completion {
          case .failure(let error):
            self.subject.send(completion: .failure(error))
          case .finished:
            self.subject.send(completion: .finished)
          }
        }) { (completedCount: Int64, requestedURL: URL) in
          self.completed[requestedURL] = completedCount
          self.subject.send(self.currentSpeed)
      }
      .store(in: &cancellables)
    }
  }

  // MARK: Private

  private var cancellables: [AnyCancellable] = []
  private var completed: [URL: Int64] = [:]
  private var time = Date()

  private var totalDownloadedBytes: Int64 {
    completed.reduce(0) { (result, completedForURL) -> Int64 in
      return result + completedForURL.value
    }
  }

  private var currentSpeed: Double {
    let elapsedTime = Date().timeIntervalSince(self.time)
    return Double(totalDownloadedBytes * 8)/1000000/elapsedTime
  }
}
