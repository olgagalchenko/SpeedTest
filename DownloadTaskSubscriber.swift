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
    typealias Input = (url: URL, response: URLResponse)
    typealias Failure = URLError

    var subscription: Subscription?

    func receive(subscription: Subscription) {
        self.subscription = subscription
        self.subscription?.request(.unlimited)
    }

    func receive(_ input: Input) -> Subscribers.Demand {
        print("Subscriber value \(input.url)")
        return .unlimited
    }

    func receive(completion: Subscribers.Completion<Failure>) {
        print("Subscriber completion \(completion)")
        self.subscription?.cancel()
        self.subscription = nil
    }
}
