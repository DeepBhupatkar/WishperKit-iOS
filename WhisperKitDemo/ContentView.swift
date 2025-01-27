//
//  ContentView.swift
//  WhisperKitDemo
//
//  Created by Deep Bhupatkar on 24/01/25.
//

import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @StateObject private var transcriptionManager = TranscriptionManager()
    @State private var showingFilePicker = false
    
    let availableModels = [
        "openai_whisper-tiny",
        "openai_whisper-tiny.en",
        "openai_whisper-base",
        "openai_whisper-base.en",
        "openai_whisper-small",
        "openai_whisper-small.en"
    ]
    
    var body: some View {
        VStack {
            Text("WhisperKit Transcriber")
                .font(.title)
                .padding()
            
            // Model selection
            Picker("Select Model", selection: $transcriptionManager.selectedModel) {
                ForEach(availableModels, id: \.self) { model in
                    Text(model).tag(model)
                }
            }
            .disabled(transcriptionManager.isModelLoaded)
            .padding()
            
            // Load Model button
            Button(action: {
                Task {
                    do {
                        try await transcriptionManager.loadModel()
                    } catch {
                        print("Error loading model: \(error)")
                    }
                }
            }) {
                Text(transcriptionManager.isModelLoaded ? "Model Loaded" : "Load Model")
                    .padding()
                    .background(transcriptionManager.isModelLoaded ? Color.indigo : Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(transcriptionManager.isModelLoaded)
            .padding(.bottom)
            
            // File selection controls
            HStack {
                Button(action: { showingFilePicker = true }) {
                    Text(transcriptionManager.selectedAudioURL?.lastPathComponent ?? "Select Audio File")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(!transcriptionManager.isModelLoaded)
                
                Button(action: {
                    transcriptionManager.transcribeAudio()
                }) {
                    Text(transcriptionManager.isTranscribing ? "Transcribing..." : "Transcribe File")
                        .padding()
                        .background(transcriptionManager.selectedAudioURL != nil ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(!transcriptionManager.isModelLoaded || transcriptionManager.selectedAudioURL == nil || transcriptionManager.isTranscribing)
            }
            
            // Recording button
            Button(action: {
                if transcriptionManager.isRecording {
                    transcriptionManager.stopRecording()
                } else {
                    transcriptionManager.startRecording()
                }
            }) {
                Text(transcriptionManager.isRecording ? "Stop Recording" : "Start Recording")
                    .padding()
                    .background(transcriptionManager.isRecording ? Color.red : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(!transcriptionManager.isModelLoaded)
            .padding()
            
            // Transcription output
            ScrollView {
                Text(transcriptionManager.transcriptionText)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            .padding()
        }
        .fileImporter(
            isPresented: $showingFilePicker,
            allowedContentTypes: [.audio],
            onCompletion: { result in
                do {
                    let fileURL = try result.get()
                    
                    // Start accessing the security-scoped resource
                    guard fileURL.startAccessingSecurityScopedResource() else {
                        print("Could not access the file")
                        return
                    }
                    
                    // Copy file to app's documents directory
                    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                    let destinationURL = documentsDirectory.appendingPathComponent(fileURL.lastPathComponent)
                    
                    try? FileManager.default.removeItem(at: destinationURL)
                    try FileManager.default.copyItem(at: fileURL, to: destinationURL)
                    
                    // Stop accessing the security-scoped resource
                    fileURL.stopAccessingSecurityScopedResource()
                    
                    transcriptionManager.selectedAudioURL = destinationURL
                } catch {
                    print("Error selecting file: \(error)")
                }
            }
        )
    }
}

#Preview {
    ContentView()
}
