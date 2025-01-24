//
//  RealTimeAudioProcessor.swift
//  WhisperKitDemo
//
//  Created by Deep Bhupatkar on 24/01/25.
//

import AVFoundation

class RealTimeAudioProcessor {
    let audioEngine = AVAudioEngine()
    let audioSession = AVAudioSession.sharedInstance()
    var audioBuffer: AVAudioPCMBuffer?
    var lastBuffer: AVAudioPCMBuffer?
    var audioPlayer: AVAudioPlayer?
    var formatConverter: AVAudioConverter!
    var dataFloats = [Float]()
    var canStop = false
    var onAudioDataReceived: (([Float]) -> Void)?

    
    // Assume you have an AVAudioPCMBuffer named audioBuffer
    
    func startRealTimeProcessingAndPlayback() throws {
        try audioSession.setCategory(.playAndRecord, mode: .default)
        
        audioSession.requestRecordPermission { [weak self] granted in
            guard let self = self else { return }
            if granted {
                do {
                    try self.audioSession.setActive(true, options: .notifyOthersOnDeactivation)
                    let inputNode = self.audioEngine.inputNode
                    let format = inputNode.inputFormat(forBus: 0)
                    
                    let outputFormat = AVAudioFormat(
                        commonFormat: .pcmFormatFloat32,
                        sampleRate: 16000,
                        channels: 1,
                        interleaved: true
                    )!
                    self.formatConverter = AVAudioConverter(from: format, to: outputFormat)!
                    
                    inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, time in
                        guard let self = self else { return }
                        self.processAudioBuffer(buffer, format: format, outputFormat: outputFormat)
                    }
                    
                    try self.audioEngine.start()
                    print("Real-time audio processing started.")
                } catch {
                    print("Error starting real-time processing: \(error)")
                }
            } else {
                print("User denied record permission.")
            }
        }
    }
    
    private func processAudioBuffer(_ buffer: AVAudioPCMBuffer, format: AVAudioFormat, outputFormat: AVAudioFormat) {
        do {
            let outputBuffer = AVAudioPCMBuffer(
                pcmFormat: outputFormat,
                frameCapacity: AVAudioFrameCount(
                    outputFormat.sampleRate * Double(buffer.frameLength) / format.sampleRate
                )
            )!
            
            var error: NSError?
            guard self.formatConverter.convert(
                to: outputBuffer,
                error: &error,
                withInputFrom: { _, outStatus in
                    outStatus.pointee = .haveData
                    return buffer
                }
            ) != .error else {
                if let error = error {
                    print("Conversion error: \(error)")
                }
                return
            }
            
            if let audioData = try? self.decodePCMBuffer(outputBuffer) {
                self.onAudioDataReceived?(audioData)
            }
        } catch {
            print("Error processing audio buffer: \(error)")
        }
    }
    
    func decodePCMBuffer(_ buffer: AVAudioPCMBuffer) throws -> [Float] {
        guard let floatChannelData = buffer.floatChannelData else {
            throw NSError(domain: "Invalid PCM Buffer", code: 0, userInfo: nil)
        }
        
        let channelCount = Int(buffer.format.channelCount)
        let frameLength = Int(buffer.frameLength)
        
        var floats = [Float]()
        
        for frame in 0..<frameLength {
            for channel in 0..<channelCount {
                let floatData = floatChannelData[channel]
                let index = frame * channelCount + channel
                let floatSample = floatData[index]
                floats.append(max(-1.0, min(floatSample, 1.0)))
            }
        }
        
        return floats
    }
    
    func stopRecord() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
    }
}
