//
//  EditViewController.swift
//  Parrot
//
//  Created by tenda_dev on 2017/9/14.
//  Copyright © 2017年 tomjoy1947. All rights reserved.
//

import Cocoa

class EditViewController: NSViewController {

    @IBOutlet weak var collectionView: NSScrollView!
    public var path : URL = URL.init(string: "/")!
    var fileDic : Dictionary<String, URL> = [:]
    var stringDic : Dictionary<String, [URL]> = [:] // <语言:[路径]>
    var translateDic : Dictionary<String, [[String : (String, URL)]]> = [:]  // <key:<语言:(value, 文件路径)>>
    
    let fileManager = FileManager.default
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        self.searchFile()
        
        for key in stringDic.keys {
            let urls = stringDic[key]
            for url in urls! {
                self.resolveStrings(language: key, fileURL: url)
            }
        }
        
    }
    
    
    func searchFile() {
        let fileEnumerator = self.fileManager.enumerator(at: path, includingPropertiesForKeys: nil, options: .skipsHiddenFiles, errorHandler: nil)
        while let element = fileEnumerator?.nextObject() as? URL {
            let fileSuffix = element.pathExtension.suffix(20)
            if fileSuffix == "m" {
                fileDic[element.lastPathComponent] = element
            } else if fileSuffix == "strings" {
                var language : String?
                for component in element.pathComponents {
                    if component.contains(".lproj") {
                        language = String(component.split(separator: ".")[0])
                        break
                    }
                }
                
                if var array = stringDic[language!] {
                    array.append(element)
                    stringDic[language!] = array
                } else {
                    stringDic[language!] = [element]
                }
                
            }
        }
    }
    
    func resolveStrings(language : String, fileURL : URL) {
        do {
            let readHandler = try FileHandle.init(forReadingFrom: fileURL)
            let data = readHandler.readDataToEndOfFile()
            let readString = String(data: data, encoding: String.Encoding.utf8)
            let strings = readString?.components(separatedBy: CharacterSet.newlines)
            
            for eachString in strings! {
                
                let splitStrings = eachString.split(separator: "=", maxSplits: 1, omittingEmptySubsequences: true)
                if splitStrings.count == 2 {
                    var stringone = String(splitStrings[0])
                    var stringtwo = String(splitStrings[1])
                    
                    for i in stringone {
                        stringone.removeFirst()
                        if i == "\""{
                            break;
                        }
                    }
                    
                    for i in stringone.reversed() {
                        stringone.removeLast()
                        if i == "\""{
                            break;
                        }
                    }
                    
                    for i in stringtwo {
                        stringtwo.removeFirst()
                        if i == "\""{
                            break;
                        }
                    }
                    
                    for i in stringtwo.reversed() {
                        stringtwo.removeLast()
                        if i == "\""{
                            break;
                        }
                    }
                    
                    if translateDic[stringone] != nil {
                        translateDic[stringone]?.append([language : (stringtwo, fileURL)])
                    } else {
                        translateDic[stringone] = [[language : (stringtwo, fileURL)]]
                    }
                }
            }
            
            readHandler.closeFile()
        } catch {
            
        }
        
    }
    
    
    
    
}
