//
//  ImmersiveView.swift
//  Drummer
//
//  Created by Mekhak Ghapantsyan on 3/11/25.
//

import SwiftUI
import RealityKit
import RealityKitContent
import AVFoundation

struct ImmersiveView: View {
  
  @Environment(AppModel.self) private var appModel
  
  @State var drum: ModelEntity?
  @State var drumModel: ModelEntity?
  @State var xylophone: ModelEntity?
  @State var piano: ModelEntity?
  @State var beatPad: ModelEntity?
  @State var padModel: ModelEntity?
  @State var handModel: ModelEntity = ModelEntity()
  @State private var subs: [EventSubscription] = []
  @State var playerss: [AVAudioPlayerNode] = []
  @State var content: RealityViewContent?
  @State private var players: [String: AVAudioPlayer] = [:]
  
  var audioEngine = AVAudioEngine()
  let beatNames = ["pad1","pad2","pad3","pad4", "pad5", "pad6"]
  
  var body: some View {
    RealityView { content in
      self.content = content
      setUpHands()
      let subscription =  content.subscribe(to: CollisionEvents.Began.self, on: nil) { collision in
        print("\(collision.entityA.name)  and \(collision.entityB.name)")
        if collision.entityA.name == "rightIndex" || collision.entityA.name == "leftIndex" {
          if beatNames.contains(collision.entityB.name) {
            players.values.forEach { $0.stop() }
            guard let player = players[collision.entityB.name] else { return }
            player.play()
          } else {
            playSound(named: collision.entityB.name)
          }
        }
        
        if collision.entityB.name == "rightIndex" || collision.entityB.name == "leftIndex" {
          if beatNames.contains(collision.entityA.name) {
            guard let player = players[collision.entityA.name] else { return }
            player.play()
          } else {
            playSound(named: collision.entityA.name)
          }
        }
      }
      DispatchQueue.main.async {
        subs.append(subscription)
      }
      
      var component = GestureComponent()
      component.canRotate = false
      component.canDrag = false
      component.canRotate = false
      getPlayers()
      
      if appModel.selctedItems.contains("Drum") {
        drumModel = await getDrumModel()
        guard let drumModel else { return }
        drumModel.position = [0,1,-0.5]
        drumModel.components.set(component)
        drumModel.components.set(InputTargetComponent())
        content.add(drumModel)
        prepareCollidersForDrum()
      }
      
      if appModel.selctedItems.contains("Piano") {
        piano = createPianoModel()
        guard let piano else { return }
        piano.position = [0.8,1,-0.5]
        piano.components.set(component)
        piano.components.set(InputTargetComponent())
        content.add(piano)
      }
      
      if appModel.selctedItems.contains("Xylophone") {
        xylophone = createXylophone()
        guard let xylophone else { return }
        xylophone.position = [-0.5,1,-0.5]
        xylophone.components.set(component)
        xylophone.components.set(InputTargetComponent())
        content.add(xylophone)
      }
      
      if appModel.selctedItems.contains("Beat Pad") {
        self.beatPad = await getBeatPadModel()
        guard let beatPad else { return }
        beatPad.components.set(component)
        beatPad.components.set(InputTargetComponent())
        beatPad.setPosition([0,0.5,-0.5], relativeTo: nil)
        createCollidersForPad()
        content.add(beatPad)
      }
      
    }
    .installGestures()
    .onChange(of: appModel.isAdjstingDrum) { _, newValue in
      drumModel?.generateCollisionShapes(recursive: true)
      drumModel?.gestureComponent?.canDrag = newValue
      drumModel?.gestureComponent?.canRotate = false
      drumModel?.gestureComponent?.canScale = newValue
      xylophone?.generateCollisionShapes(recursive: true)
      xylophone?.gestureComponent?.canDrag = newValue
      xylophone?.gestureComponent?.canScale = newValue
      xylophone?.gestureComponent?.canRotate = newValue
      piano?.generateCollisionShapes(recursive: true)
      piano?.gestureComponent?.canDrag = newValue
      piano?.gestureComponent?.canRotate = newValue
      piano?.gestureComponent?.canScale = newValue
      beatPad?.generateCollisionShapes(recursive: true)
      beatPad?.gestureComponent?.canDrag = newValue
      beatPad?.gestureComponent?.canRotate = newValue
      beatPad?.gestureComponent?.canScale = newValue
    }
  }
  
}

extension ImmersiveView {
  
  private func createCircles(color: UIColor, size: Float) -> ModelEntity {
    let circle = ModelEntity(mesh: .generateBox(width: 100 * size, height: 0.000001, depth: 100 * size), materials: [SimpleMaterial(color: color, isMetallic: true)])
    circle.generateCollisionShapes(recursive: true)
    return circle
  }
  
  private func getPlayers() {
    for sound in beatNames {
      if let url = Bundle.main.url(forResource: sound, withExtension: "wav") {
        do {
          let player = try AVAudioPlayer(contentsOf: url)
          player.prepareToPlay()
          players[sound] = player
        } catch {
          print("Error loading sound: \(sound)")
        }
      }
    }
  }
  
  func playSound(named soundName: String) {
    guard let url = Bundle.main.url(forResource: soundName, withExtension: "wav") else { return }
    
    let player = AVAudioPlayerNode()
    let audioFile = try? AVAudioFile(forReading: url)
    
    audioEngine.attach(player)
    audioEngine.connect(player, to: audioEngine.mainMixerNode, format: audioFile?.processingFormat)
    
    player.scheduleFile(audioFile!, at: nil, completionHandler: nil)
    
    if !audioEngine.isRunning {
      try? audioEngine.start()
    }
    
    player.play()
    playerss.append(player)
  }
  
  private func prepareCollidersForDrum() {
    guard let drum else { return }
    let firstCircle = createCircles(color: .clear, size: 0.4)
    firstCircle.name = "circle1"
    firstCircle.position = [65,-25,-38]
    drum.addChild(firstCircle)
    
    let secondCircle = createCircles(color: .clear,size: 0.4)
    secondCircle.name = "circle2"
    secondCircle.position = [-75,-30,-33]
    drum.addChild(secondCircle)
    
    let thirdCircle = createCircles(color: .clear, size: 0.4)
    thirdCircle.name = "circle3"
    thirdCircle.position = [-30,2,-10]
    thirdCircle.transform.rotation = simd_quatf(angle: -.pi/9, axis: [1, 0, 0])
    drum.addChild(thirdCircle)
    
    let forthCircle = createCircles(color: .clear, size: 0.4)
    forthCircle.name = "circle4"
    forthCircle.position = [26,2,-10]
    forthCircle.transform.rotation = simd_quatf(angle: -.pi/9, axis: [1, 0, 0])
    drum.addChild(forthCircle)
    
    let fifthCircle = createCircles(color: .clear, size: 0.4)
    fifthCircle.name = "circle5"
    fifthCircle.position = [74,32,7]
    fifthCircle.transform.rotation = simd_quatf(angle: -.pi/8, axis: [1, 0, 0]) * simd_quatf(angle: .pi/10, axis: [0, 0, 1])
    drum.addChild(fifthCircle)
    
    let sixthCircle = createCircles(color: .clear, size: 0.55)
    sixthCircle.name = "circle6"
    sixthCircle.position = [-115,19,-8]
    sixthCircle.transform.rotation = simd_quatf(angle: -.pi/14, axis: [0, 0, 1])
    drum.addChild(sixthCircle)
    
    let seventhCircle = createCircles(color: .clear, size: 0.3)
    seventhCircle.name = "circle7"
    seventhCircle.position = [115,10,-20]
    drum.addChild(seventhCircle)
    
    let eightCircle = createCircles(color: .clear, size: 0.7)
    eightCircle.name = "circle8"
    eightCircle.position = [0,-80,-25]
    eightCircle.transform.rotation = simd_quatf(angle: -.pi/2, axis: [1, 0, 0])
    drum.addChild(eightCircle)
    
  }
  
  private func createCollidersForPad() {
    guard let padModel else { return }
    let firstCircle = createCircles(color: .green, size: 0.11)
    firstCircle.name = "pad1"
    firstCircle.position = [0,68,4.5]
    padModel.addChild(firstCircle)
    
    let secondCircle = createCircles(color: .red, size: 0.11)
    secondCircle.name = "pad2"
    secondCircle.position = [0,68,-6.5]
    padModel.addChild(secondCircle)
    
    let thirdCircle = createCircles(color: .blue, size: 0.11)
    thirdCircle.name = "pad3"
    thirdCircle.position = [12,68,-6.5]
    padModel.addChild(thirdCircle)
    
    let forthCircle = createCircles(color: .magenta, size: 0.11)
    forthCircle.name = "pad4"
    forthCircle.position = [12,68,4.5]
    padModel.addChild(forthCircle)
    
    let fifthCircle = createCircles(color: .black, size: 0.11)
    fifthCircle.name = "pad5"
    fifthCircle.position = [-12,68,4.5]
    padModel.addChild(fifthCircle)
    
    let sixthCircle = createCircles(color: .yellow, size: 0.11)
    sixthCircle.name = "pad6"
    sixthCircle.position = [-12,68,-6.5]
    padModel.addChild(sixthCircle)
  }
  
  func createXylophone() -> ModelEntity {
    let xylophone = ModelEntity(mesh: .generateBox(size: [0.6, 0.002, 0.3]), materials: [SimpleMaterial(color: .lightGray, isMetallic: true)])
    xylophone.name = "Xylophone Name"
    
    let colors: [UIColor] = [.red, .orange, .yellow, .green, .blue, .purple]
    let barWidth: Float = 0.05
    let barHeight: Float = 0.02
    let barDepth: Float = 0.06
    
    for (index, color) in colors.enumerated() {
      let bar = ModelEntity(mesh: .generateBox(size: [barWidth, barHeight, barDepth + Float(index) * 0.05]),
                            materials: [SimpleMaterial(color: color, isMetallic: false)])
      
      bar.position = [Float(index) * (barWidth + 0.02) - 0.2, 0.03, 0]
      bar.name = "Bar\(index + 1)"
      bar.generateCollisionShapes(recursive: true)
      bar.components[CollisionComponent.self] = CollisionComponent(shapes: [.generateBox(size: [barWidth, barHeight, barDepth])])
      
      xylophone.addChild(bar)
    }
    
    return xylophone
  }
  
  
  func createPianoModel() -> ModelEntity {
    let pianoEntity = ModelEntity(mesh: .generateBox(size: [1, 0.002, 0.5]), materials: [SimpleMaterial(color: .lightGray, isMetallic: true)])
    pianoEntity.name = "PianoStand"
    
    let whiteKeySize = SIMD3<Float>(0.1, 0.02, 0.3)
    let blackKeySize = SIMD3<Float>(0.06, 0.02, 0.18)
    
    let whiteKeyMaterial = SimpleMaterial(color: .white, isMetallic: false)
    let blackKeyMaterial = SimpleMaterial(color: .black, isMetallic: false)
    
    let whiteNotes = ["c_C", "d_D", "e_E", "f_F", "g_G", "a_A"]
    let blackNotes = ["c_C#", "eb_D#", "f_F#", "g_G#", "bb_A#"]
    
    for (i, note) in whiteNotes.enumerated() {
      let key = ModelEntity(mesh: .generateBox(size: whiteKeySize), materials: [whiteKeyMaterial])
      key.position = SIMD3<Float>(Float(i) * 0.12 - 0.35, 0.03, 0)
      key.name = note
      key.generateCollisionShapes(recursive: true)
      pianoEntity.addChild(key)
    }
    
    for (i, note) in blackNotes.enumerated() {
      if note.isEmpty { continue }
      let key = ModelEntity(mesh: .generateBox(size: blackKeySize), materials: [blackKeyMaterial])
      key.position = SIMD3<Float>((Float(i) * 0.12) + 0.06 - 0.35, 0.045, -0.05)
      key.name = note
      key.generateCollisionShapes(recursive: true)
      pianoEntity.addChild(key)
    }
    
    return pianoEntity
  }
  
  func getBeatPadModel() async -> ModelEntity? {
    do {
      let beatModel = ModelEntity(mesh: .generateBox(size: [0.6, 0.002, 0.4]), materials: [SimpleMaterial(color: .lightGray, isMetallic: true)])
      beatModel.name = "Beat stand"
      padModel = try await ModelEntity(named: "Pad")
      guard let padModel else { return nil }
      padModel.position = [0, -0.6, 0]
      beatModel.addChild(padModel)
      return beatModel
    } catch {
      print("Error while Loading Pad Model: \(error)")
      return nil
    }
  }
  
  func getDrumModel() async -> ModelEntity? {
    do {
      let drumModel = ModelEntity(mesh: .generateBox(size: [0.4, 0.002, 0.3]), materials: [SimpleMaterial(color: .lightGray, isMetallic: true)])
      drumModel.name = "Drum Stand"
      drum = try await ModelEntity(named: "Drum")
      guard let drum else { return nil }
      drum.transform.rotation = simd_quatf(angle: .pi, axis: [0, 1, 0])
      drum.scale = [0.001,0.001,0.001]
      drumModel.addChild(drum)
      drum.position = [0,0.15,0]
      return drumModel
    } catch {
      print("Error while Loading drum: \(error)")
      return nil
    }
  }
  
  
  func setUpHands() {
    Task {
      guard let content else { return }
      let configuration = SpatialTrackingSession.Configuration(tracking: [.hand])
      let session = SpatialTrackingSession()
      await session.run(configuration)
      
      let righthandAnchor = AnchorEntity(.hand(.right, location: .joint(for: .indexFingerTip)))
      let rightIndexTipCollisionEntity = ModelEntity(mesh: .generateSphere(radius: 0.005), materials: [SimpleMaterial()])
      rightIndexTipCollisionEntity.generateCollisionShapes(recursive: false)
      righthandAnchor.addChild(rightIndexTipCollisionEntity)
      rightIndexTipCollisionEntity.name = "rightIndex"
      righthandAnchor.anchoring.physicsSimulation = .none
      content.add(righthandAnchor)
      
      let rightHandAnchor2 = AnchorEntity(.hand(.right, location: .joint(for: .middleFingerTip)))
      let rightMiddleTipCollisionEntity = ModelEntity(mesh: .generateSphere(radius: 0.005), materials: [SimpleMaterial()])
      rightMiddleTipCollisionEntity.generateCollisionShapes(recursive: false)
      rightHandAnchor2.addChild(rightMiddleTipCollisionEntity)
      rightMiddleTipCollisionEntity.name = "rightIndex"
      rightHandAnchor2.anchoring.physicsSimulation = .none
      content.add(rightHandAnchor2)
      
      let leftHandAnchor = AnchorEntity(.hand(.left, location: .joint(for: .indexFingerTip)))
      let leftIndexTipCollisionEntity = ModelEntity(mesh: .generateSphere(radius: 0.005), materials: [SimpleMaterial()])
      leftIndexTipCollisionEntity.generateCollisionShapes(recursive: false)
      leftHandAnchor.addChild(leftIndexTipCollisionEntity)
      leftIndexTipCollisionEntity.name = "leftIndex"
      leftHandAnchor.anchoring.physicsSimulation = .none
      content.add(leftHandAnchor)
    }
  }
  
}

#Preview(immersionStyle: .full) {
  ImmersiveView()
    .environment(AppModel())
}
