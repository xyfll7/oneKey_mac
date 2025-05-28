//
//  config.swift
//  tai
//
//  Created by 小洋粉 on 2025/4/21.
//

import AppKit

// 配置模型
struct Config: Codable {
    var title:String
    var key:String
    var command:String
    var windows_title:String
    var windows_key:String
    // 多个默认配置
    static let defaults = [
        Config(
            title: "⌘+P Pronunce",
            key: "command+p",
            command: "pronunce",
            windows_title: "ctrl+P Pronunce",
            windows_key: "Control+P"
        ),
        Config(
            title: "⌘+D DeepSeek",
            key: "command+d",
            command: "deepseek",
            windows_title: "ctrl+D DeepSeek",
            windows_key: "Control+D"
        ),
        Config(
            title: "⌘+O 一键欧陆",
            key: "command+o",
            command: "https://dict.eudic.net/dicts/en/",
            windows_title: "ctrl+O 一键欧陆",
            windows_key: "Control+O"
        ),
        Config(
            title:"⌘+Y 一键有道",
            key: "command+y",
            command: "https://www.youdao.com/result?lang=en&word=",
            windows_title:"ctrl+Y 一键有道",
            windows_key:"Control+Y",
        ),
        Config(
            title:"⌘+Y 一键有道",
            key: "command+y",
            command: "https://www.youdao.com/result?lang=en&word=",
            windows_title:"ctrl+Y 一键有道",
            windows_key:"Control+Y",
        ),
        Config(
            title:"⌘+Y 一键有道",
            key: "command+y",
            command: "https://www.youdao.com/result?lang=en&word=",
            windows_title:"ctrl+Y 一键有道",
            windows_key:"Control+Y",
        ),
        Config(
            title:"⌘+D 一键抖音",
            key: "command+d",
            command: "https://www.douyin.com/search/",
            windows_title:"ctrl+D 一键抖音",
            windows_key:"Control+D",
        ),
        Config(
            title:"⌘+J 一键剑桥",
            key: "command+j",
            command: "https://dictionary.cambridge.org/zhs/%E8%AF%8D%E5%85%B8/%E8%8B%B1%E8%AF%AD/",
            windows_title:"ctrl+J 一键剑桥",
            windows_key:"Control+J",
        ),
        Config(
             title:"⌘+B 一键百度",
             key: "command+b",
             command: "https://www.baidu.com/s?ie=UTF-8&wd=",
             windows_title:"ctrl+B 一键百度",
             windows_key:"Control+B",
        ),
        Config(
            title:"⌘+G 一键谷歌",
            key: "command+g",
            command: "https://www.google.com/search?q=",
            windows_title:"ctrl+G 一键谷歌",
            windows_key:"Control+G",
        ),
        Config(
             title:"⌘⌥+B 一键百度翻译",
             key: "command+option+b",
             command: "https://fanyi.baidu.com/#en/zh/",
             windows_title:"ctrl+B 一键百度翻译",
             windows_key:"Control+Alt+B",
        ),
        Config(
            title:"⌘⌥+G 一键谷歌翻译",
            key: "command+option+g",
            command: "https://translate.google.cn/?sl=zh-CN&tl=en&op=translate&text=",
            windows_title:"ctrl+G 一键谷歌翻译",
            windows_key:"Control+Alt+G",
        ),
    ]
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
