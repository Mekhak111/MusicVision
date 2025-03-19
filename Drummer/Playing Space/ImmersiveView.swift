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
  @State var xylophone: ModelEntity?
  @State var piano: ModelEntity?
  @State var rightStick: ModelEntity?
  @State var leftStick: ModelEntity?
  @State var handModel: ModelEntity = ModelEntity()
  @State private var subs: [EventSubscription] = []
  @State var playerss: [AVAudioPlayerNode] = []
  @State var content: RealityViewContent?
  @State private var players: [String: AVAudioPlayer] = [:]

  var audioEngine = AVAudioEngine()

  
  let soundNames = ["circle1","circle2","circle3","circle4","circle5","circle6","circle7","circle8", "Do", "Re", "Mi", "Fa", "Sol", "La", "Si", "Bar1","Bar2", "Bar3", "Bar4", "Bar5", "Bar6"]
  
  
  var body: some View {
    RealityView { content in
      self.content = content
   
      setUpHands()
      let subscription =  content.subscribe(to: CollisionEvents.Began.self, on: nil) { collision in
        print("\(collision.entityA.name)  and \(collision.entityB.name)")
        if collision.entityA.name == "rightIndex" || collision.entityA.name == "leftIndex" {
          recognizeSound(part: collision.entityB.name)
        }
        
        if collision.entityB.name == "rightIndex" || collision.entityB.name == "leftIndex" {
          recognizeSound(part: collision.entityA.name)
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
        do {
          drum = try await ModelEntity(named: "Drum")
          guard let drum else { return }
          drum.position = [0,1,-0.5]
          drum.components.set(component)
          drum.components.set(InputTargetComponent())
          drum.transform.rotation = simd_quatf(angle: .pi, axis: [0, 1, 0])
          drum.scale = [0.001,0.001,0.001]
          content.add(drum)
        } catch {
          print("Error loading Drum file: \(error)")
        }
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
      
    }
    .installGestures()
    .onChange(of: appModel.isAdjstingDrum) { _, newValue in
      drum?.generateCollisionShapes(recursive: true)
      drum?.gestureComponent?.canDrag = newValue
      drum?.gestureComponent?.canRotate = false
      drum?.gestureComponent?.canScale = newValue
      xylophone?.generateCollisionShapes(recursive: true)
      xylophone?.gestureComponent?.canDrag = newValue
      xylophone?.gestureComponent?.canScale = newValue
      xylophone?.gestureComponent?.canRotate = newValue
      piano?.generateCollisionShapes(recursive: true)
      piano?.gestureComponent?.canDrag = newValue
      piano?.gestureComponent?.canRotate = newValue
      piano?.gestureComponent?.canScale = newValue
    }
  }
  
}

extension ImmersiveView {
  private func createCireles(color: UIColor, size: Float) -> ModelEntity {
    let circle = ModelEntity(mesh: .generateBox(width: 100 * size, height: 0.000001, depth: 100 * size), materials: [SimpleMaterial(color: .clear, isMetallic: true)])
    circle.generateCollisionShapes(recursive: true)
    return circle
  }
  
  private func getPlayers() {
    for sound in soundNames {
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
  
  private func recognizeSound(part: String) {
    playSound(named: part)
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
    let firstCircle = createCireles(color: .green, size: 0.5)
    firstCircle.name = "circle1"
    firstCircle.position = [65,-20,-45]
    drum.addChild(firstCircle)
    
    let secondCircle = createCireles(color: .blue,size: 0.5)
    secondCircle.name = "circle2"
    secondCircle.position = [-75,-25,-40]
    drum.addChild(secondCircle)
    
    let thirdCircle = createCireles(color: .red, size: 0.4)
    thirdCircle.name = "circle3"
    thirdCircle.position = [-30,4,-10]
    thirdCircle.transform.rotation = simd_quatf(angle: -.pi/9, axis: [1, 0, 0])
    drum.addChild(thirdCircle)
    
    let forthCircle = createCireles(color: .yellow, size: 0.4)
    forthCircle.name = "circle4"
    forthCircle.position = [26,4,-10]
    forthCircle.transform.rotation = simd_quatf(angle: -.pi/9, axis: [1, 0, 0])
    drum.addChild(forthCircle)
    
    let fifthCircle = createCireles(color: .brown, size: 0.5)
    fifthCircle.name = "circle5"
    fifthCircle.position = [65,35,-7]
    fifthCircle.transform.rotation = simd_quatf(angle: .pi/10, axis: [0, 0, 1])
    drum.addChild(fifthCircle)
    
    let sixthCircle = createCireles(color: .systemPink, size: 0.6)
    sixthCircle.name = "circle6"
    sixthCircle.position = [-95,25,-16]
    sixthCircle.transform.rotation = simd_quatf(angle: -.pi/10, axis: [0, 0, 1])
    drum.addChild(sixthCircle)
    
    let seventhCircle = createCireles(color: .magenta, size: 0.5)
    seventhCircle.name = "circle7"
    seventhCircle.position = [115,10,-20]
    drum.addChild(seventhCircle)
    
    let eightCircle = createCireles(color: .black, size: 0.8)
    eightCircle.name = "circle8"
    eightCircle.position = [0,-80,-25]
    eightCircle.transform.rotation = simd_quatf(angle: -.pi/2, axis: [1, 0, 0])
    drum.addChild(eightCircle)
    
  }
  
  func createXylophone() -> ModelEntity {
    let xylophone = ModelEntity(mesh: .generateBox(size: [0.6, 0.002, 0.3]), materials: [SimpleMaterial(color: .lightGray, isMetallic: true)])
    
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
    
    let whiteKeySize = SIMD3<Float>(0.1, 0.02, 0.3)
    let blackKeySize = SIMD3<Float>(0.06, 0.02, 0.18)
    
    let whiteKeyMaterial = SimpleMaterial(color: .white, isMetallic: false)
    let blackKeyMaterial = SimpleMaterial(color: .black, isMetallic: false)
    
    let whiteNotes = ["Do", "Re", "Mi", "Fa", "Sol", "La", "Si"]
    let blackNotes = ["do#", "re#", "", "fa#", "sol#", "la#"]
    
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
      key.position = SIMD3<Float>((Float(i) * 0.12) + 0.06 - 0.35, 0.04, -0.05)
      key.name = note
      key.generateCollisionShapes(recursive: true)
      pianoEntity.addChild(key)
    }
    
    return pianoEntity
  }
  
  
  func setUpHands() {
    Task {
      guard let content else { return }
      let configuration = SpatialTrackingSession.Configuration(tracking: [.hand])
      let session = SpatialTrackingSession()
      await session.run(configuration)
      
      let righthandAnchor = AnchorEntity(.hand(.right, location: .joint(for: .indexFingerTip)))
      let rightIndexTipCollisionEntity = ModelEntity(mesh: .generateSphere(radius: 0.01), materials: [SimpleMaterial()])
      rightIndexTipCollisionEntity.generateCollisionShapes(recursive: false)
      righthandAnchor.addChild(rightIndexTipCollisionEntity)
      rightIndexTipCollisionEntity.name = "rightIndex"
      righthandAnchor.anchoring.physicsSimulation = .none
      content.add(righthandAnchor)
      
      
      let rightHandAnchor2 = AnchorEntity(.hand(.right, location: .joint(for: .middleFingerTip)))
      let rightMiddleTipCollisionEntity = ModelEntity(mesh: .generateSphere(radius: 0.01), materials: [SimpleMaterial()])
      rightMiddleTipCollisionEntity.generateCollisionShapes(recursive: false)
      rightHandAnchor2.addChild(rightMiddleTipCollisionEntity)
      rightMiddleTipCollisionEntity.name = "rightIndex"
      rightHandAnchor2.anchoring.physicsSimulation = .none
      content.add(rightHandAnchor2)

      
      let leftHandAnchor = AnchorEntity(.hand(.left, location: .joint(for: .indexFingerTip)))
      let leftIndexTipCollisionEntity = ModelEntity(mesh: .generateSphere(radius: 0.01), materials: [SimpleMaterial()])
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
