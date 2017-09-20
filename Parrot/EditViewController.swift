//
//  EditViewController.swift
//  Parrot
//
//  Created by tenda_dev on 2017/9/14.
//  Copyright © 2017年 tomjoy1947. All rights reserved.
//

import Cocoa

fileprivate let reusedKey =  NSUserInterfaceItemIdentifier(rawValue: "Item")


class EditViewController: NSViewController {

    @IBOutlet weak var collectionView: NSCollectionView!
    public var path : URL = URL.init(string: "/")!
    var fileDic : Dictionary<String, URL> = [:]
    var stringDic : Dictionary<String, [URL]> = [:] // <语言:[路径]>
    var stringArray : Array<String> = [] // [语言]
    var translateDic : Dictionary<String, [[String : (String, URL)]]> = [:]  // <key:<语言:(value, 文件路径)>>
    var translateArray : Array<String> = [] // [key]
    
    let fileManager = FileManager.default
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        setCollectionView()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        self.searchFile()
        
        for key in stringDic.keys {
            self.stringArray.append(key)
            let urls = stringDic[key]
            for url in urls! {
                self.resolveStrings(language: key, fileURL: url)
            }
        }
        translateArray.sort()
        
        collectionView.reloadData()
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
                    
                    if !translateArray.contains(stringone) {
                        translateArray.append(stringone)
                    }
                }
            }
            
            readHandler.closeFile()
        } catch {
            
        }
        
    }
}


extension EditViewController{
    fileprivate func setCollectionView (){
        collectionView.register(CustomItem.self, forItemWithIdentifier: reusedKey)
        collectionView.dataSource = self
        let layout = collectionView.collectionViewLayout as! NSCollectionViewFlowLayout
        layout.itemSize = NSSize(width: 300, height: 44)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
    }
}

extension EditViewController : NSCollectionViewDataSource {
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return self.stringArray.count + 1
        } else {
            return self.translateDic.keys.count * 4
        }
    }
    
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 2
    }
    
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: reusedKey, for: indexPath) as! CustomItem
        if indexPath.section == 0 {
            item.inputField.isHidden = true
            item.titleLabel.isHidden = false
            
            if indexPath.item == 0 {
                item.titleLabel.stringValue = "KEY"
            } else {
                item.titleLabel.stringValue = self.stringArray[indexPath.item - 1]
            }
            
        } else {
            item.inputField.string = ""
            let lineNumber = indexPath.item / 4
            let langNumber = indexPath.item % 4
            
            let key = self.translateArray[lineNumber]
            
            if langNumber == 0 {
                item.inputField.isHidden = true
                item.titleLabel.isHidden = false
                
                item.titleLabel.stringValue = key
            } else {
                item.inputField.isHidden = false
                item.titleLabel.isHidden = true
                
                let lang = self.stringArray[langNumber - 1]
                
                for dic in self.translateDic[key]! {
                    if dic.keys.first == lang {
                        item.inputField.string = (dic[lang]?.0)!
                        break;
                    }
                }
            }
            
            if item.inputField.string == "" {
                item.scrollView.layer?.backgroundColor = NSColor.red.cgColor
            } else {
                item.scrollView.layer?.backgroundColor = NSColor.white.cgColor
            }
        }
        
        return item
    }
    
}






