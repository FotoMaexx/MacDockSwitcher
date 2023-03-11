//
//  MacDockSwitcherApp.swift
//  MacDockSwitcher
//
//  Created by Maximilian Hauser on 20.10.22.
//

import SwiftUI

// MenuBarWidget

@main
struct MacDockSwitcherApp: App {

    init() {
        initialize()
    }

    @AppStorage("currentNumber") var currentNumber: Int = 1
    @AppStorage("quitToRevert") var quitToRevert: Bool = false
    @AppStorage("safetyWait") var safetyWait: Bool = true
    
    @State var waitingToChange = false
    
    @State var startDate = Date.now
    @State var timeElapsed: Double = 0.0
    
    @State var timer = Timer.publish(every: 0.25, on: .main, in: .common).autoconnect()

    var body: some Scene {
        MenuBarExtra(isInserted: .constant(true)) {
            ForEach([1 : "Normal", 2 : "Study", 3 : "Work", 4 : "Rest"].sorted(by: <),  id: \.key) { key, value in
                Button {
                    if currentNumber != key {
                        setDock(key)
                    }
                } label: {
                    HStack {
                        Image(systemName: key == currentNumber ? "\(key).circle.fill" : "\(key).circle")
                            .symbolRenderingMode(.hierarchical)
                        Text(value)
                    }
//                    Label(value, image: key == currentNumber ? "checkmark" : "\(key).circle")
                }
                .keyboardShortcut(.init(.init("\(key)")))
                .disabled(waitingToChange)
            }
            
            Divider()
            
            Toggle("Apply Slow and Stable", isOn: $safetyWait)
            Toggle("Apply 'Normal' on Quit", isOn: $quitToRevert)
            
            Divider()

            Button("Quit") {
                if quitToRevert && currentNumber != 1  {
                    setDock(1) {result in
                        NSApplication.shared.terminate(nil)
                    }
                } else {
                    NSApplication.shared.terminate(nil)
                }
            }
                    .keyboardShortcut("q")
                    .disabled(waitingToChange)
        } label: {
            Image(systemName: waitingToChange ? "rays" : "\(currentNumber).circle", variableValue: timeElapsed/5.0)
                .onReceive(timer) { firedDate in
                    print("timer fired")
                    timeElapsed = firedDate.timeIntervalSince(startDate)
                }
        }
    }
        
    func setDock(_ dockNumber: Int, completion:  ((Bool) -> Void)? = nil)  {
        
        startDate = Date.now
        timeElapsed = 0.0
        waitingToChange = true
        timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
        DispatchQueue.main.asyncAfter(deadline: .now() + (safetyWait ? 5.0 : 0.1)) {
            switchScene(from: currentNumber, to: dockNumber)
            currentNumber = dockNumber
            waitingToChange = false
            timer.upstream.connect().cancel()
            completion?(true)
        }
    }
}

func initialize() {
    // Check if Folder exists, otherwise create it
    let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
    let documentsDirectory = paths[0]
    let docURL = URL(string: documentsDirectory)!
    let dataPath = docURL.appendingPathComponent("HauserMedia/DockSwitcher/Docks")
    if !FileManager.default.fileExists(atPath: dataPath.path) {
        do {
            try FileManager.default.createDirectory(atPath: dataPath.path, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print(error.localizedDescription)
        }
        for index in 1...3 {
            do {
                let dockPath = dataPath.appendingPathComponent("\(index)")
                try FileManager.default.createDirectory(atPath: dockPath.path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
