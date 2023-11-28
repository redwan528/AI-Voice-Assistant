//
//  Models.swift
//  AI Voice Assistant
//
//  Created by Redwan Khan on 11/28/23.
//

import Foundation

enum VoiceType: String, Codable, Hashable, Sendable, CaseIterable {
    case alloy
    case echo
    case fable
    case onyx
    case nova
    case shimmer
}

enum VoiceChatState {
    case idle // app launch
    case recordingSpeech //when user hits record
    case processingSpeech //when making call to OpenAI API, speech to text, prompting gpt4, also prompting gpt4 response to speech data
    case playingSpeech
    case error(Error)
}
