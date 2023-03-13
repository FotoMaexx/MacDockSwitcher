//
// Created by Maximilian Hauser on 25.10.22.
//

import Foundation
import os.log

extension FileManager {
    // Returns the URL of the application support directory for the main bundle, creating it if necessary
    static var applicationSupportDirectory: URL? {
        let fileManager = Self.default
        guard let appSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            return nil
        }

        let bundleID = Bundle.main.bundleIdentifier ?? "com.example"
        let appDirectory = appSupportURL.appendingPathComponent(bundleID)
        let subdirectoryNames = ["1", "2", "3"]

        do {
            try fileManager.createDirectory(at: appDirectory, withIntermediateDirectories: true, attributes: [:])

            for subdirectoryName in subdirectoryNames {
                try fileManager.createDirectory(at: appDirectory.appendingPathComponent(subdirectoryName), withIntermediateDirectories: true, attributes: [:])
            }
        } catch {
            os_log("Error creating directory: %@", log: .default, type: .error, "\(error.localizedDescription)")
            return nil
        }

        return appDirectory
    }

    // Returns the URL of com.apple.dock.plist
    static var appleDockPlistURL: URL? {
        let fileManager = Self.default
        let preferencesURL = fileManager.urls(for: .libraryDirectory, in: .userDomainMask).first?.appendingPathComponent("Preferences")
        let dockPlistURL = preferencesURL?.appendingPathComponent("com.apple.dock.plist")
        return dockPlistURL
    }
    
    // Safely copies an item at the specified source URL to the specified destination URL.
    func copyItemAtURL(safely sourceURL: URL, to destinationURL: URL) throws {
        if fileExists(atPath: destinationURL.path) {
            try removeItem(at: destinationURL)
        }
        
        try copyItem(at: sourceURL, to: destinationURL)
    }
}



// Kills the Dock process
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
        os_log("Dock killed: %@", log: .default, type: .debug, output)
    }
}

// Switches the Dock configuration from one numbered configuration to another.
func switchDockConfiguration(from oldConfiguration: Int, to newConfiguration: Int) {
    do {
        guard let appSupportDirectory = FileManager.applicationSupportDirectory, let dockPlistURL = FileManager.appleDockPlistURL else {
            os_log("Could not locate necessary directories.", log: .default, type: .error)
            return
        }
        
        let plist = "com.apple.dock.plist"
        
        let oldDockPlistURL = appSupportDirectory.appendingPathComponent("\(oldConfiguration)/\(plist)")
        let newDockPlistURL = appSupportDirectory.appendingPathComponent("\(newConfiguration)/\(plist)")
        
        let fileManager = FileManager.default
        try fileManager.copyItemAtURL(safely: dockPlistURL, to: oldDockPlistURL)
        try fileManager.copyItemAtURL(safely: newDockPlistURL, to: dockPlistURL)
        
        killDock()
    } catch {
        os_log("Error switching Dock configuration: %@", log: .default, type: .error, "\(error.localizedDescription)")
    }
}

