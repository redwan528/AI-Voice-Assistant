//
//  ViewModel.swift
//  AI Voice Assistant
//
//  Created by Redwan Khan on 11/28/23.
//

import AVFoundation
import Foundation
import Observation
import XCAOpenAIClient

@Observable
class ViewModel: NSObject {
    let client = OpenAIClient(apiKey: "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")
    
    var selectedVoice = VoiceType.alloy
    var state = VoiceChatState.idle {
        didSet { print(state)}
    }
    var isIdle: Bool {
        if case .idle = state {
            return true
        }
        return false
    }
    
    var audioPower = 0.0
    
    func startCaptureAudio(){
        
    }
}
