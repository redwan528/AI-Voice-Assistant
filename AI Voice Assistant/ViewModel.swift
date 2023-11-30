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
class ViewModel: NSObject, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    let client = OpenAIClient(apiKey: "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")
    var audioPlayer: AVAudioPlayer!
    var audioRecorder: AVAudioRecorder!
    
    #if !os(macOS)
    var recordingSession = AVAudioSession.sharedInstance()
    #endif
    var animatedTimer: Timer?
    var recordingTimer: Timer?
    var audioPower = 0.0
    var prevAudioPower: Double?
    
    
    var selectedVoice = VoiceType.alloy
    
    var captureURL: URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
            .first!.appendingPathComponent("recording.m4a")
    }
    
    var state = VoiceChatState.idle {
        didSet { print(state)}
    }
    var isIdle: Bool {
        if case .idle = state {
            return true
        }
        return false
    }
    
    var siriWaveFormOpacity: CGFloat {
        switch state{
            
//        case .idle:
//            <#code#>
        case .recordingSpeech:
            return 1
//        case .processingSpeech:
//            <#code#>
        case .playingSpeech:
            return 1
//        case .error(_):
//            <#code#>
        default: return 0
        }
    }
    
    override init(){
        super.init()
        #if !os(macOS)
        do {
            #if os(iOS)
            try recordingSession.setCategory(.playAndRecord, options: .defaultToSpeaker)
            #else
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            #endif
            try recordingSession.setActive(true)
            
            AVAudioApplication.requestRecordPermission { [unowned self] allowed in
                if !allowed {
                    self.state = .error("Recording not allowed by the user")
                }
            }
        } catch {
            state = .error(error)
        }
        #endif
    }
    
    
    func startCaptureAudio(){
        resetValues() //
        state = .recordingSpeech
        
        do {
            audioRecorder = try AVAudioRecorder(url: captureURL, 
            settings: [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 12000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ])
            
            audioRecorder.isMeteringEnabled = true
            audioRecorder.delegate = self
            audioRecorder.record()
            
            animatedTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true, block: {[unowned self]_ in
                guard self.audioRecorder != nil else {return}
                self.audioRecorder.updateMeters()
                let power = min(1, max(0,1 - abs(Double(self.audioRecorder.averagePower(forChannel: 0)) / 50) ))
                self.audioPower = power
            })
            recordingTimer = Timer.scheduledTimer(withTimeInterval: 1.6, repeats: true, block: { [unowned self]_ in
            
                guard self.audioRecorder != nil else { return }
                self.audioRecorder.updateMeters()
                let power = min(1, max(0,1 - abs(Double(self.audioRecorder.averagePower(forChannel: 0)) / 50) ))
                if self.prevAudioPower == nil {
                    self.prevAudioPower = power
                    return
                }
                
                if let prevAudioPower = self.prevAudioPower, prevAudioPower < 0.25 && power < 0.175 {
                    self.finishCaptureAudio()
                    return
                }
                self.prevAudioPower = power
            })
            
        } catch {
            resetValues()
            state = .error(error)
        }
    }
    
    func finishCaptureAudio(){
        resetValues()
        do {
            let data = try Data(contentsOf: captureURL)
            try playAudio(data: data)
        } catch {
            state = .error(error)
            resetValues()
        }
    }
    
    func playAudio(data: Data ) throws {
        self.state = .playingSpeech
        audioPlayer = try AVAudioPlayer(data: data)
        audioPlayer.isMeteringEnabled = true
        audioPlayer.delegate = self
        audioPlayer.play()
        
        animatedTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true, block: {[unowned self]_ in
            guard self.audioPlayer != nil else {return}
            self.audioPlayer.updateMeters()
            let power = min(1, max(0,1 - abs(Double(self.audioPlayer.averagePower(forChannel: 0)) / 160) ))
            self.audioPower = power
        })
    }
    
    func cancelRecording(){
        resetValues()
        state = .idle
        
    }
    
    func cancelProcessingTask(){
        
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            resetValues()
            state = .idle
        }
    }
    
    func audioPlayerDidFinishRecording(_ player: AVAudioPlayer, successfully flag: Bool) {
       resetValues()
        state = .idle
    }
    
   
    
    func resetValues(){
        audioPower = 0
        prevAudioPower = nil
        audioRecorder?.stop()
        audioRecorder = nil
        audioPlayer?.stop()
        audioPlayer = nil
        recordingTimer = nil
        animatedTimer?.invalidate()
        animatedTimer = nil
        
        
        
    }
}
