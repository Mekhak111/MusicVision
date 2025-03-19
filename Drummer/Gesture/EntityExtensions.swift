/*
 See the LICENSE.txt file for this sample’s licensing information.
 
 Abstract:
 App-specific extension on Entity.
 */

import Foundation
import RealityKit

public extension Entity {
  
  var gestureComponent: GestureComponent? {
    get { components[GestureComponent.self] }
    set { components[GestureComponent.self] = newValue }
  }
  
  var scenePosition: SIMD3<Float> {
    get { position(relativeTo: nil) }
    set { setPosition(newValue, relativeTo: nil) }
  }
  
  var sceneOrientation: simd_quatf {
    get { orientation(relativeTo: nil) }
    set { setOrientation(newValue, relativeTo: nil) }
  }
  
}
