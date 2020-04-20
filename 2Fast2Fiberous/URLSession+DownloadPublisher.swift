//
//  URLSession+DownloadPublisher.swift
//  2Fast2Fiberous
//
//  Created by Olga Galchenko on 4/19/20.
//  Copyright © 2020 Olga Galchenko. All rights reserved.
//

import Foundation
import Combine

extension URLSession {

  /// Returns a publisher that wraps a URL session download task for a given URL.
  ///
  /// The publisher publishes file URL when the task completes, or terminates if the task fails with an error.
  /// - Parameter url: The URL for which to create a download task.
  /// - Returns: A publisher that wraps a download task for the URL.
  public func downloadTaskPublisher(for url: URL) -> URLSession.DownloadTaskPublisher {
    self.downloadTaskPublisher(for: .init(url: url))
  }

  /// Returns a publisher that wraps a URL session download task for a given URL request.
  ///
  /// The publisher publishes file URL when the task completes, or terminates if the task fails with an error.
  /// - Parameter request: The URL request for which to create a download task.
  /// - Returns: A publisher that wraps a download task for the URL request.
  public func downloadTaskPublisher(for request: URLRequest) -> URLSession.DownloadTaskPublisher {
    .init(request: request, session: self)
  }

  public struct DownloadTaskPublisher: Publisher {

    public typealias Output = (bytesReceived: Int?, requestedURL: URL)
    public typealias Failure = URLError

    public let request: URLRequest
    public let session: URLSession

    public init(request: URLRequest, session: URLSession) {
      self.request = request
      self.session = session
    }

    public func receive<S>(subscriber: S) where S: Subscriber,
      DownloadTaskPublisher.Failure == S.Failure,
      DownloadTaskPublisher.Output == S.Input
    {
      let subscription = DownloadTaskSubscription(subscriber: subscriber, session: self.session, request: self.request)
      subscriber.receive(subscription: subscription)
    }
  }
}
