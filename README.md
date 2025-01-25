# 🎙️ **Powered by [WhisperKit](https://github.com/argmaxinc/WhisperKit)**  
**iOS Application Example for Real-Time Transcription & File-Based Processing**  
Swift | SwiftUI  

---

## Description  
WhisperKit is an iOS application built with Swift and SwiftUI, showcasing real-time transcription and file-based audio processing using WhisperKit Package. Designed to demonstrate the capabilities of Whisper in a clean, modern iOS interface, WhisperKit serves as an ideal starting point for developers exploring speech-to-text applications.  

---

## 🚀 Features  

### 🔊 Real-Time Transcription  
- Perform accurate, real-time transcription of live audio directly on your device.  
- Powered by WhisperKit for lightweight, efficient on-device processing.

### 📂 File-Based Processing  
- Transcribe pre-recorded audio files.  
- Supports multiple audio formats (e.g., MP3, WAV, AAC).  

### 🧠 Model Selection  
- Currently, it uses the default model provided by WhisperKit.  

### 🖥️ SwiftUI Design  
- Modern, intuitive user interface with seamless navigation and responsive layouts.

### 🔒 Privacy Focused  
- All audio processing is handled locally on your device, ensuring complete data privacy.

---

## 🛠️ Installation  

### Prerequisites  
- **iOS 15+**  
- **Xcode 14+**

### Steps  
1. Clone the repository:  
   ```bash
   git clone https://github.com/DeepBhupatkar/WishperKit-iOS.git
   cd whisperkit
   ```
2. Install dependencies using Swift Package Manager (from WhisperKit):  
   ```swift
   dependencies: [
       .package(url: "https://github.com/argmaxinc/WhisperKit.git", from: "0.9.0"),
   ],
   ```
3. Build and run the app on a physical device or simulator.

---

## ⚙️ How It Works  

### Real-Time Transcription  
1. Tap the **Record** button to start live transcription.  
2. Audio is processed in chunks and converted to text in real time.  

### File-Based Processing  
1. Upload an audio file from your device.  
2. Whisper processes the file and outputs the transcribed text.  

---

## 🧰 Tools and Technologies  

- **WhisperKit:** A lightweight Whisper implementation for fast on-device transcription.  
- **Swift & SwiftUI:** For building a modern and efficient iOS application.  

---

## 🤝 Contributing  

Contributions are welcome!  

1. Fork the repository.  
2. Create a feature branch: `git checkout -b feature-name`.  
3. Commit your changes: `git commit -m 'Add feature'`.  
4. Push to the branch: `git push origin feature-name`.  
5. Submit a pull request.  

---

## 📄 License  

This project is licensed under the MIT License. See the `LICENSE` file for details.
