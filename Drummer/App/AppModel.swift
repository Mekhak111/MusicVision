//
//  AppModel.swift
//  Drummer
//
//  Created by Mekhak Ghapantsyan on 3/11/25.
//

import SwiftUI

/// Maintains app-wide state
@MainActor
@Observable
class AppModel {
    let immersiveSpaceID = "ImmersiveSpace"
    enum ImmersiveSpaceState {
        case closed
        case inTransition
        case open
    }
  var immersiveSpaceState = ImmersiveSpaceState.closed
  var isAdjstingDrum: Bool = false
  var selctedItems: [String] = []
}
