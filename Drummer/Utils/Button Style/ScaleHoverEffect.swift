//
//  ScaleHoverEffect.swift
//  Drummer
//
//  Created by Mekhak Ghapantsyan on 3/17/25.
//


import SwiftUI

struct ScaleHoverEffect: CustomHoverEffect {

  func body(content: Content) -> some CustomHoverEffect {
    content.hoverEffect { effect, isActive, proxy in
      effect.animation(.easeOut) {
        $0.scaleEffect(isActive ? 1.1 : 1, anchor: .top)
      }
    }
  }

}

struct ScaleHoverButtonStyle: ButtonStyle {

  var isSelected: Bool = false

  func makeBody(configuration: Configuration) -> some View {
      configuration.label
        .padding()
        .background(.thinMaterial)
        .background(isSelected ? Color.white.opacity(0.7) : Color.gray.opacity(0.3))
        .font(.headline)
        .cornerRadius(12)
        .hoverEffect(ScaleHoverEffect())
  }

}
