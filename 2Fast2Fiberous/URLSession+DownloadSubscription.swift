//
//  URLSession+DownloadSubscription.swift
//  2Fast2Fiberous
//
//  Created by Olga Galchenko on 4/19/20.
//  Copyright © 2020 Olga Galchenko. All rights reserved.
//

import Foundation
import Combine

extension URLSession {

  final class DownloadTaskSubscription<SubscriberType: Subscriber>: Subscription where
    SubscriberType.Input == (completedCount: Int64, totalCount: Int64, requestedURL: URL),
    SubscriberType.Failure == URLError
  {
    init(subscriber: SubscriberType, session: URLSession, request: URLRequest) {
      self.subscriber = subscriber
      self.session = session
      self.request = request
    }


    /// Request method
    ///
    /// - Parameter demand: A number that tells us how many values can we send back to the subscriber at maximum.
    func request(_ demand: Subscribers.Demand) {
      guard demand > 0 else {
        return
      }
      self.task = self.session.downloadTask(with: request) { [weak self] url, response, error in
        self?.observation?.invalidate()
        if let error = error as? URLError {
          self?.subscriber?.receive(completion: .failure(error))
          return
        }
        guard let _ = response else {
          self?.subscriber?.receive(completion: .failure(URLError(.badServerResponse)))
          return
        }
        guard let _ = url else {
          self?.subscriber?.receive(completion: .failure(URLError(.badURL)))
          return
        }
        self?.subscriber?.receive(completion: .finished)
      }
      self.task.resume()

      observation = self.task.progress.observe(\.fractionCompleted) { [weak self] (progress, _) in
        guard let requestURL = self?.request.url else {
          self?.subscriber?.receive(completion: .failure(URLError(.badURL)))
          return
        }
        let _ = self?.subscriber?.receive((
          completedCount: self?.task.countOfBytesReceived ?? 0,
          totalCount: self?.task.countOfBytesExpectedToReceive ?? 0,
          requestedURL: requestURL))
      }
    }

    /// Cancel method
    func cancel() {
      self.task.cancel()
    }

    // MARK: Private

    private var subscriber: SubscriberType?
    private weak var session: URLSession!
    private var request: URLRequest!
    private var task: URLSessionDownloadTask!
    private var observation: NSKeyValueObservation?
  }
}
