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

    @State var currentNumber: Int = 1

    var body: some Scene {
        MenuBarExtra(String(currentNumber), systemImage: "\(currentNumber).circle") {
            Button("Normal") {
                switchScene(from: currentNumber, to: 1)
                currentNumber = 1
            }
            .keyboardShortcut("1")



            Button("Uni") {
                switchScene(from: currentNumber, to: 2)
                currentNumber = 2
            }
                    .keyboardShortcut("2")

            Button("COV-IT") {
                switchScene(from: currentNumber, to: 3)
                currentNumber = 3
            }
                    .keyboardShortcut("3")
            Divider()

            Button("Quit") {
                switchScene(from: currentNumber, to: 1)
                NSApplication.shared.terminate(nil)

            }
                    .keyboardShortcut("q")
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
