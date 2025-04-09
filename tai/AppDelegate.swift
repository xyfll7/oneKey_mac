//
//  AppDelegate.swift
//  tai
//
//  Created by 小洋粉 on 2021/12/21.
//
import SwiftUI
import Cocoa
import HotKey
import LaunchAtLogin
import Foundation
import CryptoKit
@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    internal var hotKeys: [String: HotKey] = [:]
    internal var configs: [Config] = []

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let itemImage = NSImage(named: "S")
        itemImage?.isTemplate = true
        statusItem.button?.image = itemImage
        statusItem.button?.action = #selector(abc(_:))
        getConfigs()
    }
    
    @objc func abc(_:Any?) {
        getConfigs()
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
}

// 配置模型
struct AppConfig: Codable {
    var appName: String
    var version: String
    var settings: [String: Bool]
    var preferences: Preferences
    
    struct Preferences: Codable {
        var theme: String
        var fontSize: Int
        var autoSave: Bool
    }
    
    // 默认配置
    static let `default` = AppConfig(
        appName: "MyApp。。。。",
        version: "1.0",
        settings: ["darkMode": false, "notifications": true],
        preferences: Preferences(theme: "Light", fontSize: 14, autoSave: true)
    )
}


extension AppDelegate {
    func initMenus(configs:[Config]) {
        let menu = NSMenu()
        configs.forEach { item in
            menu.addItem(NSMenuItem(title:item.title, action: nil ,  keyEquivalent: ""))
        }
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title:LaunchAtLogin.isEnabled ? "✔" : "✗" + "  开机启动" , action: #selector(AppDelegate.startLogin(_:)), keyEquivalent: "s"))
        menu.addItem(NSMenuItem(title: "退出", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        menu.addItem(NSMenuItem(title: "测试", action: #selector(AppDelegate.test(_:)), keyEquivalent: "q"))
        statusItem.menu = menu
    }
    func initHotKeys(configs:[Config]) {
        configs.forEach { item in
            let arr = item.key.split(separator: "+")
            
            if let key = Key(string:String(arr[arr.count-1])), let command0 = commands[String(arr[0])] {
                self.hotKeys.updateValue(HotKey(key:key,modifiers:[command0]), forKey: item.key)
            }
            
            if let key = Key(string:String(arr[arr.count-1])), let command0 = commands[String(arr[0])], let command1 = commands[String(arr[1])]  {
                self.hotKeys.updateValue(HotKey(key:key,modifiers:[command0,command1]), forKey: item.key)
            }
         
            self.hotKeys[item.key]?.keyDownHandler = { [self] in
                commandCStr() { str in
                    

                    let str_ = self.replaceSpecialCharacters(with: " ",in:str)
                        .addingPercentEncoding(withAllowedCharacters:.urlQueryAllowed) ?? ""
                    print("PPP",str_ )
                    let appStoreURL =  "\(item.command)\(str_ )"
                    NSWorkspace.shared.open(URL(string: appStoreURL )!)
                }
            }
        }
    }
    @objc func startLogin(_ sender: Any?) {
        LaunchAtLogin.isEnabled = !LaunchAtLogin.isEnabled
        initMenus(configs: self.configs)
    }
    @objc func test(_ sender: Any?) {
        // 创建一个配置文件
        let configFileName = "taiConfig.json"
        
        let configFileURL = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )[0].appendingPathComponent(configFileName)
        
        if FileManager.default.fileExists(atPath: configFileURL.path) {
            print("配置文件已存在")
        } else {
            do {
                let encoder = JSONEncoder()
                encoder.outputFormatting = .prettyPrinted // 启用格式化
                let data = try encoder.encode(AppConfig.default)
                try data.write(to: configFileURL)
            } catch {
                print("Error saving config: \(error)")
            }
        }
        self.openFileWithTextEdit(filePath: configFileURL)
    }
    
    
    func openFileWithTextEdit(filePath: URL) {
        if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.TextEdit") {
            NSWorkspace.shared.open(
                [filePath],
                withApplicationAt: url,
                configuration: NSWorkspace.OpenConfiguration()
            )
        } else {
            NSWorkspace.shared.open(filePath)
        }
    }



    
    func replaceSpecialCharacters(with space: String, in input: String) -> String {
    
        // 定义正则表达式模式，匹配所有非字母数字字符
        let pattern = "[^a-zA-Z0-9\\u4e00-\\u9fa5]"
        
        // 使用 replacingOccurrences 方法替换特殊字符为空格
        var result = input.replacingOccurrences(of: pattern, with: space, options: .regularExpression, range: nil)
        
        
        // 合并多个连续空格为一个空格
        result = result.components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
        
        return result

    }
}



extension AppDelegate {
    // 模拟command+c 并获取剪切板内容
    internal func commandCStr(_ perform: @escaping (_ str: String) -> ())  {
        // 模拟command+c按键
        analogButton(flags: [.maskCommand],key: 0x08)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            perform(NSPasteboard.general.string(forType: NSPasteboard.PasteboardType.string) ?? "")
        }
    }
}



let commands:[String:NSEvent.ModifierFlags] = [
    "capsLock":.capsLock,
    "shift":.shift,
    "control":.control,
    "option":.option,
    "command":.command,
    "numericPad":.numericPad,
    "help":.help,
    "function":.function,
    "deviceIndependentFlagsMask":.deviceIndependentFlagsMask,
]


struct Config:Codable {
    var title:String
    var key:String
    var command:String
}

extension AppDelegate {
    func getConfigs() {
        loadJson(fromURLString: "https://raw.githubusercontent.com/xyfll7/xyfll7/refs/heads/main/config.json") {result in
            switch result {
            case .success(let data):
                self.configs = (try? JSONDecoder().decode([Config].self, from: data)) ?? []
                self.initMenus(configs:self.configs)
                self.initHotKeys(configs:self.configs)
            case .failure(let error):
                print(error)
            }
        }
    }
}

func loadJson(fromURLString urlString: String,
              completion: @escaping (Result<Data, Error>) -> Void) {
    if let url = URL(string: urlString) {
        let urlSession = URLSession(configuration: .default).dataTask(with: url) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
            }
            
            if let data = data {
                completion(.success(data))
            }
        }
        urlSession.resume()
    }
}




// 模拟按键
func analogButton(flags:CGEventFlags,key:CGKeyCode) {
    let src = CGEventSource(stateID: CGEventSourceStateID.hidSystemState)
    let spcd = CGEvent(keyboardEventSource: src, virtualKey: key, keyDown: true)
    spcd?.flags = flags
    spcd?.post(tap: CGEventTapLocation.cghidEventTap)
}
