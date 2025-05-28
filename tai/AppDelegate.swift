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
import AVFoundation

@main
class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    internal let configFileURL = FileManager.default.urls(
        for: .documentDirectory,
        in: .userDomainMask
    )[0].appendingPathComponent("taiConfig.json")
    
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    internal var hotKeys: [String: HotKey] = [:]
    internal var configs: [Config] = []
    

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let itemImage = NSImage(named: "S")
        itemImage?.isTemplate = true
        statusItem.button?.image = itemImage
        create_a_configuration_file(configFileURL:configFileURL)
        getConfigs_local()
    }
    

    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    
    func menuWillOpen(_ menu: NSMenu) {
    
    }

    func menuDidClose(_ menu: NSMenu) {
        self.initMenus(configs:self.configs)
    }
}

extension AppDelegate {
    // 初始化菜单
    func initMenus(configs:[Config]) {
        let menu = NSMenu()
        menu.delegate = self // 设置代理
        configs.forEach { item in
            menu.addItem(NSMenuItem(title:item.title, action: nil ,  keyEquivalent: ""))
        }
        menu.addItem(NSMenuItem.separator())
        menu.addItem(
            NSMenuItem(title:"\(LaunchAtLogin.isEnabled ? "✔" : "✗") \(NSLocalizedString("button.launch_at_login", comment: "Launch at Login menu item"))",
                       action: #selector(AppDelegate.startLogin(_:)), keyEquivalent: "s"))
        let button_config = NSMenuItem(title: NSLocalizedString("button.config",comment: "Button to adjust settings"), action: nil, keyEquivalent: "c")
        menu.addItem(button_config)
        
        // 添加子菜单项
        let submenu = NSMenu()
        submenu.addItem(NSMenuItem(
            title: NSLocalizedString("button.open_configfile", comment: "Open Configfile"),
            action: #selector(AppDelegate.open_config_file(_:)),
            keyEquivalent: "o"
        ))
        submenu.addItem( NSMenuItem(
            title: NSLocalizedString("button.reload_configfile", comment: "Reload Configfile"),
            action: #selector(AppDelegate.load_config_file(_:)),
            keyEquivalent: "r"
        ))
        button_config.submenu = submenu
        
        menu.addItem(
            NSMenuItem(title: NSLocalizedString("button.quit",comment: "Button to exit the application completely"), action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        statusItem.menu = menu
    }
    // 初始化快捷键
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
                
                if(item.command == "pronunce") {
                    commandCStr() { str in
                        let str_ = self.replaceSpecialCharacters(with: " ",in:str)
                            .addingPercentEncoding(withAllowedCharacters:.urlQueryAllowed) ?? ""
                        self.speakWord(str_, language: "en-US");
                    }

                } else if(item.command == "deepseek") {
                    let menu = NSMenu()
                    menu.delegate = self // 设置代理
                    menu.addItem(NSMenuItem(
                        title: NSLocalizedString("button.open_configfile", comment: "Open Configfile"),
                        action: #selector(AppDelegate.open_config_file(_:)),
                        keyEquivalent: "o"
                    ))
                    statusItem.menu = menu
                  
                    if let button = statusItem.button {
                        button.performClick(nil) // 这会自动弹出关联的菜单
                    }
                } else {
                    commandCStr() { str in
                        let str_ = self.replaceSpecialCharacters(with: " ",in:str)
                            .addingPercentEncoding(withAllowedCharacters:.urlQueryAllowed) ?? ""
                        print("PPP",str_ )
                        self.speakWord(str_, language: "en-US");
                        let appStoreURL =  "\(item.command)\(str_ )"
                        NSWorkspace.shared.open(URL(string: appStoreURL )!)
                    }
                }
              
            }
        }
    }
    @objc func startLogin(_ sender: Any?) {
        LaunchAtLogin.isEnabled = !LaunchAtLogin.isEnabled
    }
    @objc func open_config_file(_ sender: Any?) {
        self.openFileWithTextEdit(filePath: configFileURL)
    }
    @objc func load_config_file(_ sender: Any?){
        let config = self.readConfig()
        print("我读取到的配置文件",config ?? "...")
    }
    // 朗读单词
    ///   - volume: 音量（0.0 ~ 1.0），默认是最大音量
    func speakWord(
        _ word: String,
        language: String = "en-US",
        rate: Float = AVSpeechUtteranceDefaultSpeechRate,
        pitch: Float = 1.0,
        volume: Float = 1.0
    ) {
        guard let voice = AVSpeechSynthesisVoice(language: language) else {
            print("⚠️ 不支持语言: \(language)，请检查语言代码")
            return
        }

        DispatchQueue.main.async {
            let utterance = AVSpeechUtterance(string: word)
            utterance.voice = voice
            utterance.rate = rate
            utterance.pitchMultiplier = pitch
            utterance.volume = volume

            let synthesizer = AVSpeechSynthesizer()
            synthesizer.speak(utterance)
        }
    }
    // 2. 读取并解析 JSON
    func readConfig() -> [Config]? {
        do {
            // 检查文件是否存在
            if FileManager.default.fileExists(atPath: configFileURL.path) {
                // 读取文件数据
                let data = try Data(contentsOf: configFileURL)
                
                // 解析 JSON
                let decoder = JSONDecoder()
                let config = try decoder.decode([Config].self, from: data)
                return config
            } else {
                print("配置文件不存在")
                return nil
            }
        } catch {
            print("读取或解析配置文件失败: \(error)")
            return nil
        }
    }

    func create_a_configuration_file(configFileURL:URL) {
        // 创建一个配置文件
        
        let configFileURL = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )[0].appendingPathComponent("taiConfig.json")
        
        if FileManager.default.fileExists(atPath: configFileURL.path) {
            print("配置文件已存在")
        } else {
            do {
                let encoder = JSONEncoder()
                encoder.outputFormatting = .prettyPrinted // 启用格式化
                let data = try encoder.encode(Config.defaults)
                try data.write(to: configFileURL)
            } catch {
                print("Error saving config: \(error)")
            }
        }
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







extension AppDelegate {
    func getConfigs_local() {
        self.configs = self.readConfig() ?? []
        self.initMenus(configs:self.configs)
        self.initHotKeys(configs:self.configs)
    }
}





// 模拟按键
func analogButton(flags:CGEventFlags,key:CGKeyCode) {
    let src = CGEventSource(stateID: CGEventSourceStateID.hidSystemState)
    let spcd = CGEvent(keyboardEventSource: src, virtualKey: key, keyDown: true)
    spcd?.flags = flags
    spcd?.post(tap: CGEventTapLocation.cghidEventTap)
}
