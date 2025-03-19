//
//  InstrumentCard.swift
//  Drummer
//
//  Created by Mekhak Ghapantsyan on 3/17/25.
//

import SwiftUI

struct InstrumentCard: View {
  
  let instrument: String
  let imageName: String
  let isSelected: Bool
  
  var body: some View {
    VStack {
      Image(imageName)
        .resizable()
        .scaledToFit()
        .frame(height: 120)
      
      Text(instrument)
        .font(.title2)
        .fontWeight(.bold)
        .foregroundColor(.black)
      
      Spacer()
      
      Circle()
        .stroke(Color.gray, lineWidth: 2)
        .frame(width: 30, height: 30)
        .overlay(
          isSelected ? Circle().fill(Color.blue) : nil
        )
        .animation(.easeInOut, value: isSelected)
    }
    .padding()
    .frame(width: 150, height: 250)
    .background(RoundedRectangle(cornerRadius: 16).fill(Color(.background)).shadow(radius: 4))
    
  }
}
