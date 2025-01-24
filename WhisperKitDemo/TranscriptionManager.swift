//
//  TranscriptionManager.swift
//  WhisperKitDemo
//
//  Created by Deep Bhupatkar on 24/01/25.
//

import Foundation
import WhisperKit
import AVFoundation

@MainActor
class TranscriptionManager: ObservableObject {
    @Published var transcriptionText = ""
    @Published var isTranscribing = false
    @Published var selectedAudioURL: URL?
    @Published var isRecording = false
    
    private var realTimeProcessor: RealTimeAudioProcessor?
    private var whisperKit: WhisperKit?
    private var audioBuffer = [Float]()
    private let bufferThreshold = 16000 * 3 // 3 seconds of audio at 16kHz
    
    init() {
        setupWhisperKit()
    }
    
    private func setupWhisperKit() {
        Task {
            do {
                whisperKit = try await WhisperKit()
                // Optional: Pre-warm models
                try await whisperKit?.prewarmModels()
            } catch {
                print("Error setting up WhisperKit: \(error)")
            }
        }
    }
    
    // Existing file-based transcription
    func transcribeAudio() {
        guard let audioPath = selectedAudioURL?.path else {
            transcriptionText = "No audio file selected"
            return
        }
        
        isTranscribing = true
        
        Task {
            do {
                guard let transcription = try await whisperKit?.transcribe(audioPath: audioPath).first else {
                    throw WhisperError.transcriptionFailed("Transcription failed")
                }
                transcriptionText = transcription.text
                isTranscribing = false
            } catch {
                transcriptionText = "Error: \(error.localizedDescription)"
                isTranscribing = false
            }
        }
    }
    
    // Real-time transcription methods
    func startRecording() {
        realTimeProcessor = RealTimeAudioProcessor()
        realTimeProcessor?.onAudioDataReceived = { [weak self] audioData in
            self?.processAudioData(audioData)
        }
        
        do {
            try realTimeProcessor?.startRealTimeProcessingAndPlayback()
            isRecording = true
        } catch {
            print("Error starting recording: \(error)")
        }
    }
    
    func stopRecording() {
        realTimeProcessor?.stopRecord()
        isRecording = false
        // Process any remaining audio in buffer
        processRemainingAudio()
    }
    
    private func processAudioData(_ newData: [Float]) {
        audioBuffer.append(contentsOf: newData)
        
        // Process audio when buffer reaches threshold
        if audioBuffer.count >= bufferThreshold {
            transcribeBuffer()
        }
    }
    
    private func processRemainingAudio() {
        if !audioBuffer.isEmpty {
            transcribeBuffer()
        }
        audioBuffer.removeAll()
    }
    
    private func transcribeBuffer() {
        let audioToProcess = Array(audioBuffer)
        audioBuffer.removeAll()
        
        Task {
            do {
//                let options = DecodingOptions(
//                    language: nil,
//                    task: .transcribe,
//                    temperature: 0,
//                    verbose: false
//                )
                
                if let results = try await whisperKit?.transcribe(audioArray: audioToProcess) {
                    let newText = results.map { $0.text }.joined(separator: " ")
                    await MainActor.run {
                        self.transcriptionText += newText + " "
                    }
                }
            } catch {
                print("Error transcribing audio buffer: \(error)")
            }
        }
    }
}
