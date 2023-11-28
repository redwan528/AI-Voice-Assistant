//
//  AI_Voice_AssistantApp.swift
//  AI Voice Assistant
//
//  Created by Redwan Khan on 11/28/23.
//

import SwiftUI

@main
struct AI_Voice_AssistantApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
            #if os(macOS) //conditional macros
                .frame(width: 400, height: 400)
            #endif
        }
        #if os(macOS)
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        #endif
    }
}
