//
//  ContentView.swift
//  Drummer
//
//  Created by Mekhak Ghapantsyan on 3/11/25.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {
  @Environment(AppModel.self) private var appModel
  @State private var selectedInstrument: [String] = []
  
  let instruments: [(name: String, image: String)] = [
    ("Piano", "piano_image"),
    ("Xylophone", "xylophone_image"),
    ("Drum", "drum_image"),
    ("Beat Pad", "pad_image")
  ]
  
  var body: some View {
    if appModel.immersiveSpaceState == .open {
      VStack {
        Button {
          appModel.isAdjstingDrum.toggle()
        } label: {
          Text(appModel.isAdjstingDrum ? "Stop Adjusting" : "Adjust Instruments")
        }
        ToggleImmersiveSpaceButton()
      }
    } else {
      selectionView
    }
  }
  
}

extension ContentView {
  private var selectionView: some View {
    VStack {
      HStack(spacing: 20) {
        ForEach(instruments, id: \.name) { instrument in
          Button {
            if selectedInstrument.contains(instrument.name) {
              selectedInstrument.removeAll(where: {$0 == instrument.name})
            } else {
              selectedInstrument.append(instrument.name)
            }
            appModel.selctedItems = selectedInstrument
          } label: {
            InstrumentCard(
              instrument: instrument.name,
              imageName: instrument.image,
              isSelected: selectedInstrument.contains(instrument.name)
            )
          }
          .frame(width: 152, height: 252)
          .background(RoundedRectangle(cornerRadius: 16).fill(Color(.background)).shadow(radius: 4))
        }
      }
      .padding()
      ToggleImmersiveSpaceButton()
    }
    .padding(40)
  }
  
}

#Preview(windowStyle: .automatic) {
  ContentView()
    .environment(AppModel())
}
