//
//  InstrumentCard.swift
//  Drummer
//
//  Created by Mekhak Ghapantsyan on 3/17/25.
//

import SwiftUI

struct InstrumentView: View {
  
  let name: String
  let image: String
  let isSelected: Bool
  let imageColors: [Color]
  let backgroundColor: Color
  
  var body: some View {
    ZStack {
      if isSelected {
        backgroundColor
      }
      VStack {
        ZStack {
          if isSelected {
            LinearGradient(colors: imageColors, startPoint: .topTrailing, endPoint: .bottomLeading)
          } else {
            Color.transitionGrad
          }
          Image(image)
            .resizable()
            .padding(36)
            .overlay(alignment: .topTrailing) {
              Image(.musicSmall)
                .padding(.horizontal,10)
                .padding(.top, 8)
            }
        }
        .frame(width: 200,height: 180)
        .background(isSelected ? Color.red : Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding(20)
        Text(name)
          .font(.title2)
          .bold()
          .foregroundStyle(Color.white)
          .padding(.bottom, 18)
      }

    }

  }
  
}
