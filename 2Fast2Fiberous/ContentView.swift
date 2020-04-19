//
//  ContentView.swift
//  2Fast2Fiberous
//
//  Created by Olga Galchenko on 4/19/20.
//  Copyright © 2020 Olga Galchenko. All rights reserved.
//

import SwiftUI

struct ContentView: View {
  @ObservedObject var requestManager = SpeedRequest()

    var body: some View {
        guard let speed = requestManager.speed else {
          return AnyView(
          VStack {
            Text("Speed test")
            Button(action: {
              self.requestManager.sendRequest()
            }) {
              Text("Begin")
            }
          })
        }

        return AnyView(Text("SPEED: \(speed)"))
      }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
