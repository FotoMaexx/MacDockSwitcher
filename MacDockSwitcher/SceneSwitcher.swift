//
// Created by Maximilian Hauser on 25.10.22.
//

import Foundation


// File Parameters
let filePathBeginning = "file://"
let fileEnding = "com.apple.dock.plist"

// Document Folder Parameters
let documentPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
let documentsDirectory = documentPaths[0]
let documentsURL = URL(string: filePathBeginning + documentsDirectory)!
let dataPath = documentsURL.appendingPathComponent("HauserMedia/DockSwitcher/Docks")

// Dock Parameters
let libraryPaths = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)
let libraryDirectory = libraryPaths[0]
let libraryURL = URL(string: filePathBeginning + libraryDirectory)!
let dockPath = libraryURL.appendingPathComponent("Preferences")
let fileDockPath = dockPath.appendingPathComponent(fileEnding)

extension FileManager {

    public func secureCopyItem(at srcURL: URL, to dstURL: URL) -> Bool {
        do {
            if FileManager.default.fileExists(atPath: dstURL.path) {
                try FileManager.default.removeItem(at: dstURL)
            }
            try FileManager.default.copyItem(at: srcURL, to: dstURL)
        } catch (let error) {
            print("Cannot copy item at \(srcURL) to \(dstURL): \(error)")
            return false
        }
        return true
    }

}


func killDock() {
    let pipe = Pipe()

    let task = Process()
    task.launchPath = "/usr/bin/killall"
    task.arguments = ["Dock"]
    task.standardOutput = pipe
    task.standardError = pipe
    task.launch()
    task.waitUntilExit()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    if let output = String(data: data, encoding: .utf8) {
        print(output)
    }
}

func switchScene(from: Int, to: Int) {
    let fm = FileManager()

    // Path to copy old Dock to
    let toPath = dataPath.appendingPathComponent("\(from)")
    let fileToPath = toPath.appendingPathComponent("com.apple.dock.plist")
    // Path for new Dock
    let newPath = dataPath.appendingPathComponent("\(to)")
    let fileNewPath = newPath.appendingPathComponent("com.apple.dock.plist")

    print(toPath)
    print(newPath)

    // copy old Dock to old path
    fm.secureCopyItem(at: fileDockPath, to: fileToPath)
    fm.secureCopyItem(at: fileNewPath, to: fileDockPath)

    killDock()

}

