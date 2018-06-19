//
//  DropboxManager.swift
//  FSNotes iOS
//
//  Created by Oleksandr Glushchenko on 6/14/18.
//  Copyright © 2018 Oleksandr Glushchenko. All rights reserved.
//

import Foundation
import SwiftyDropbox

class DropboxManager {
    private var dropbox: URL
    
    private static var instance: DropboxManager? = nil
    
    public static var shared: DropboxManager {
        get {
            guard let manager = self.instance else {
                self.instance = DropboxManager()
                return self.instance!
            }
            
            return manager
        }
    }
    
    init() {
        let document = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
        
        self.dropbox = document.appendingPathComponent("Dropbox")
        
        if !FileManager.default.fileExists(atPath: self.dropbox.absoluteString) {
            try? FileManager.default.createDirectory(at: self.dropbox, withIntermediateDirectories: false, attributes: nil)
        }
    }
    
    public func initialSync() {
        guard let client = DropboxClientsManager.authorizedClient else { return }
        
        if let cursor = UserDefaultsManagement.dropboxCursor {
            client.files.listFolderLo
            print(cursor)
        } else {
            pull()
        }
    }
    
    public func pull() {
        guard let client = DropboxClientsManager.authorizedClient else { return }
        client.files.listFolder(path: "", recursive: true).response { response, error in
            if let result = response {
                for entry in result.entries {
                    if let folder = entry as? Files.FolderMetadata {
                        if let path = folder.pathDisplay {
                            let folderURL = self.dropbox.appendingPathComponent(path)
                            try? FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
                        }
                    }
                    
                    if let file = entry as? Files.FileMetadata, let path = file.pathDisplay {
                        self.downloadFile(file: path) {_ in
                            
                        }
                    }
                }
                
                if let cursor = response?.cursor {
                    UserDefaultsManagement.dropboxCursor = cursor
                }
            }
        }
    }
    
    public func downloadFile(file: String, onCompletion: @escaping (URL?) -> Void) {
        guard let client = DropboxClientsManager.authorizedClient else { return }
        
        let destURL = self.dropbox.appendingPathComponent(file)
        let destination : (URL, HTTPURLResponse) -> URL = { temporaryURL, response in
            return destURL
        }
        
        print("Download: \(file)")
        client.files.download(path: file, overwrite: true, destination: destination)
            .response { response, error in
                if let response = response {
                    print(response)
                } else if let error = error {
                    print(error)
                }
            }
            .progress { progressData in
                print(progressData)
        }
    }
}
