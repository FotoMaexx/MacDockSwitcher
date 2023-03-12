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
    
    var dockPresets: [Int : String] = [1 : "Normal", 2 : "Study", 3 : "Work", 4 : "Rest"]
    
    @AppStorage("currentNumber") var currentNumber: Int = 1
    @AppStorage("quitToRevert") var applyNormalDockOnQuit: Bool = false
    @AppStorage("safetyWait") var applyWithWaitingPeriod: Bool = true
    
    @State var numberToApply: Int?
    @State var waitingToChange = false
    @State var startDate = Date.now
    @State var timeElapsed: Double = 0.0
    @State var timer = Timer.publish(every: 0.25, on: .main, in: .common).autoconnect()
    
    var body: some Scene {
        MenuBarExtra(isInserted: .constant(true)) {
            ForEach(dockPresets.sorted(by: <),  id: \.key) { key, value in
                Button {
                    setDock(key)
                } label: {
                    HStack {
                        Image(systemName: "\(key).circle\(key == currentNumber && !waitingToChange ? ".fill" : "")")
                        Text(value)
                    }
                }
                .keyboardShortcut(.init(.init("\(key)")))
                .disabled(waitingToChange)
            }
            if waitingToChange, let key = numberToApply, let value = dockPresets[key] {
                Text("Applying '\(value)'…")
            }
            
            Divider()
            
            Toggle("Apply Slow and Stable", isOn: $applyWithWaitingPeriod)
            Toggle("Apply 'Normal' on Quit", isOn: $applyNormalDockOnQuit)
            
            Divider()
            
            Button("Quit") {
                if applyNormalDockOnQuit  {
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
                .onAppear {
                    stopChangeTimer()
                }
                .onReceive(timer) { firedDate in
                    timeElapsed = firedDate.timeIntervalSince(startDate)
                }
        }
    }
    
    func setDock(_ dockNumber: Int, completion:  ((Bool) -> Void)? = nil)  {
        guard dockPresets.keys.contains(dockNumber) && currentNumber != dockNumber else {
            return
        }
        numberToApply = dockNumber
        startChangeTimer()
        DispatchQueue.main.asyncAfter(deadline: .now() + (applyWithWaitingPeriod ? 5.0 : 0.1)) {
            if let numberToApply = numberToApply {
                switchScene(from: currentNumber, to: numberToApply)
                currentNumber = numberToApply
            }
            stopChangeTimer()
            completion?(true)
        }
    }
    
    func startChangeTimer() {
        startDate = Date.now
        timeElapsed = 0.0
        waitingToChange = true
        timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    }
    
    func stopChangeTimer() {
        waitingToChange = false
        timer.upstream.connect().cancel()
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
