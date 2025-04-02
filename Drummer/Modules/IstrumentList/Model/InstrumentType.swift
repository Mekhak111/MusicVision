//
//  InstrumentType.swift
//  Drummer
//
//  Created by Mekhak Ghapantsyan on 4/1/25.
//

import Foundation
import SwiftUI

enum InstrumentType {
  
  case piano, xylo, beatPad, drum
  
  var name: String {
    switch self {
    case .piano:
      return "Piano"
    case .xylo:
      return "Xylophone"
    case .beatPad:
      return "Beat Pad"
    case .drum:
      return "Drum"
    }
  }
  
  var imageName: String {
    switch self {
    case .piano:
      return "piano_image"
    case .xylo:
      return "xylophone_image"
    case .beatPad:
      return "pad_image"
    case .drum:
      return "drum_image"
    }
  }
  
  var imageColors: [Color] {
    switch self {
    case .piano:
      return [Color.pianoGrad1, Color.pianoGrad2]
    case .xylo:
      return [Color.xylGrad1, Color.xylGrad2]
    case .beatPad:
      return [Color.beatGrad1, Color.beatGrad2]
    case .drum:
      return [Color.drumGrad1, Color.drumGrad2]
    }
  }
  
  var backColor: Color {
    switch self {
    case .piano:
      return Color.pianoBack
    case .xylo:
      return Color.xylBack
    case .beatPad:
      return Color.beatBack
    case .drum:
      return Color.drumBack
    }
  }
  
}
