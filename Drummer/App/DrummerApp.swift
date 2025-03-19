//
//  DrummerApp.swift
//  Drummer
//
//  Created by Mekhak Ghapantsyan on 3/11/25.
//

import SwiftUI

@main
struct DrummerApp: App {
  
  @State private var appModel = AppModel()
  
  init() {
    GestureComponent.registerComponent()
  }
  
  var body: some Scene {
    WindowGroup {
      ContentView()
        .environment(appModel)
    }
    .windowResizability(.contentSize)
    
    ImmersiveSpace(id: appModel.immersiveSpaceID) {
      ImmersiveView()
        .environment(appModel)
        .onAppear {
          appModel.immersiveSpaceState = .open
        }
        .onDisappear {
          appModel.immersiveSpaceState = .closed
        }
    }
    .immersionStyle(selection: .constant(.mixed), in: .mixed)
  }
}
