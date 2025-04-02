//
//  ContentView.swift
//  Drummer
//
//  Created by Mekhak Ghapantsyan on 3/11/25.
//

import RealityKit
import RealityKitContent
import SwiftUI

struct ContentView: View {
  
  @Environment(AppModel.self) private var appModel
  @State private var selectedInstrument: [String] = []
  
  let instruments: [InstrumentType] = [.piano, .drum, .xylo, .beatPad]
  
  var body: some View {
    if appModel.immersiveSpaceState == .open {
      VStack {
        Button {
          appModel.isAdjstingDrum.toggle()
        } label: {
          HStack(spacing: 10) {
            Spacer()
            Image(appModel.isAdjstingDrum ? .stopAdjust : .adjust)
              .padding(.leading, 16)
            Text(appModel.isAdjstingDrum ? "Stop Adjusting" : "Adjust Instruments")
              .bold()
              .padding(.trailing, 16)
            Spacer()
          }
          .frame(width: 300, height: 60)

        }
        ToggleImmersiveSpaceButton()
      }
      .padding(.horizontal, 80)
      .padding(.vertical, 20)
    } else {
      selectionView
    }
  }
  
}

extension ContentView {
  
  private var selectionView: some View {
    VStack(spacing: 20) {
      HStack(spacing: 20) {
        ForEach(instruments, id: \.name) { instrument in
          InstrumentView(
            name: instrument.name, image: instrument.imageName,
            isSelected: selectedInstrument.contains(instrument.name),
            imageColors: instrument.imageColors,
            backgroundColor: instrument.backColor
          )
          .onTapGesture {
            withAnimation {
              if selectedInstrument.contains(instrument.name) {
                selectedInstrument.removeAll(where: { $0 == instrument.name })
              } else {
                selectedInstrument.append(instrument.name)
              }
              appModel.selctedItems = selectedInstrument
            }
          }
          .glassBackgroundEffect()
          .hoverEffect(ScaleHoverEffect())

        }
      }
      .padding(.top, 100)
      .overlay {
        VStack {
          HStack {
            Text("Library")
              .font(.extraLargeTitle)
            Spacer()
            Image(.musicBig)
          }
          Spacer()
        }
      }
      ToggleImmersiveSpaceButton()
        .padding(.bottom, 160)
        .padding(.top, 80)
    }
    .padding(40)
  }
  
}

#Preview(windowStyle: .automatic) {
  ContentView()
    .environment(AppModel())
}
