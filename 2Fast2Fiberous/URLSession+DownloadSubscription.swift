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
    SubscriberType.Input == (url: URL, response: URLResponse),
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
        if let error = error as? URLError {
          self?.subscriber?.receive(completion: .failure(error))
          return
        }
        guard let response = response else {
          self?.subscriber?.receive(completion: .failure(URLError(.badServerResponse)))
          return
        }
        guard let url = url else {
          self?.subscriber?.receive(completion: .failure(URLError(.badURL)))
          return
        }
        do {
          let cacheDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
          let fileUrl = cacheDir.appendingPathComponent((UUID().uuidString))
          try FileManager.default.moveItem(atPath: url.path, toPath: fileUrl.path)
          _ = self?.subscriber?.receive((url: fileUrl, response: response))
          self?.subscriber?.receive(completion: .finished)
        }
        catch {
          self?.subscriber?.receive(completion: .failure(URLError(.cannotCreateFile)))
        }
      }
      self.task.resume()
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
  }
}
