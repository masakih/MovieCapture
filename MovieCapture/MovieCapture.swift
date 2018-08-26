//
//  MovieCapture.swift
//  MovieCapture
//
//  Created by Hori,Masaki on 2018/08/23.
//  Copyright © 2018年 Hori,Masaki. All rights reserved.
//

import AVFoundation

public enum MovieCaptureError: Error {
    
    case canNotGetDisplauId
    
    case canNotAddScreenInput
    
    case canNotCreateFileOutput
    
    case canNotAddFileOutput
    
    case alreadyRunning
}

public class MovieCapture: NSObject {
    
    public let frame: NSRect
    public let maximumFramerate: Int32
    public let scaleFactor: CGFloat
    
    public var captureMouseClick = false
    public var captureCursor = true
    
    public private(set) var isRunning = false
    
    private let session: AVCaptureSession
    private var screenInput: AVCaptureScreenInput
    private var fileOutput: AVCaptureMovieFileOutput?
    
    private var completionHandler: ((URL, Error?) -> Void)?
    
    private var audioDeviceAdded = false
    
    public init(screenFrame frame: NSRect, preset: AVCaptureSession.Preset? = nil, maxFramerate: Int32 = 15, scaleFactor: CGFloat = 1.0) throws {
        
        self.frame = frame
        (self.session, self.screenInput) = try MovieCapture.createSession(preset.map({ [$0] }))
        self.maximumFramerate = maxFramerate
        self.scaleFactor = scaleFactor
    }
    
    deinit {
        
        session.stopRunning()
    }
    
    private static func createSession(_ presets: [AVCaptureSession.Preset]?) throws -> (AVCaptureSession, AVCaptureScreenInput) {
        
        let session = AVCaptureSession()
        
        (presets ?? [.iFrame1280x720, .iFrame960x540, .hd1280x720, .qHD960x540, .vga640x480, .cif352x288, .qvga320x240, .high])
            .first(where: session.canSetSessionPreset)
            .map { session.sessionPreset = $0 }
        
        let screenInput = AVCaptureScreenInput(displayID: CGMainDisplayID())
        
        guard session.canAddInput(screenInput) else {
            
            throw MovieCaptureError.canNotAddScreenInput
        }
        session.addInput(screenInput)
        
        session.startRunning()
        
        return (session, screenInput)
    }
    
    public var preset: AVCaptureSession.Preset {
        
        get {
            
            return session.sessionPreset
        }
        
        set {
            
            session.sessionPreset = newValue
        }
    }
    
    public func start() throws {
        
        guard !isRunning else {
            
            throw MovieCaptureError.alreadyRunning
        }
        
        isRunning = true
        
        try setupInput()
        
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(temporaryName())
            .appendingPathExtension("mov")
        
        try setupFileOutput(url)
    }
    
    public func stop(completionHandler: @escaping (URL, Error?) -> Void) {
        
        self.completionHandler = completionHandler
        
        fileOutput?.stopRecording()
        
        isRunning = false
    }
    
    private func setupInput() throws {
        
        session.beginConfiguration()
        defer { session.commitConfiguration() }
        
        session.removeInput(screenInput)
        
        let display = getDisplay() ?? CGMainDisplayID()
        screenInput = AVCaptureScreenInput(displayID: display)
        
        guard session.canAddInput(screenInput) else {
            
            throw MovieCaptureError.canNotAddScreenInput
        }
        
        session.addInput(screenInput)
        
        screenInput.minFrameDuration = CMTime(value: 1, timescale: maximumFramerate)
        screenInput.cropRect = frame
        screenInput.capturesMouseClicks = captureMouseClick
        screenInput.capturesCursor = captureCursor
        screenInput.scaleFactor = scaleFactor
        
        //
        guard !audioDeviceAdded else { return }
        audioDeviceAdded = true
        
        try AVCaptureDevice.devices(for: .audio)
            .filter { $0.localizedName.hasPrefix("Soundflower") }
            .forEach { device in
                
                let audioInput = try AVCaptureDeviceInput(device: device)
                guard session.canAddInput(audioInput) else { return }
                session.addInput(audioInput)
        }
    }
    
    private func setupFileOutput(_ url: URL) throws {
        
        fileOutput = AVCaptureMovieFileOutput()
        guard let fileOutput = fileOutput else {
            
            throw MovieCaptureError.canNotCreateFileOutput
        }
        fileOutput.delegate = self
        
        guard session.canAddOutput(fileOutput) else {
            
            throw MovieCaptureError.canNotAddFileOutput
        }
        session.addOutput(fileOutput)
        
        fileOutput.startRecording(to: url, recordingDelegate: self)
    }
    
    private func getDisplay() -> CGDirectDisplayID? {
        
        var ids = UnsafeMutablePointer<CGDirectDisplayID>.allocate(capacity: 1)
        defer { ids.deallocate() }
        
        var num: UInt32 = 0
        
        CGGetDisplaysWithPoint(frame.origin, 1, ids, &num)
        
        guard num != 0 else { return nil }
        
        return ids[0]
    }
    
    private static var formatter: Formatter = {
        
        let fo = DateFormatter()
        fo.dateFormat = "yyyy-MM-dd-HH-mm-ss-AAA"
        
        return fo
    }()
    
    private func temporaryName() -> String {
        
        return MovieCapture.formatter.string(for: Date()) ?? Date().description
    }
}

extension MovieCapture: AVCaptureFileOutputDelegate {
    
    public func fileOutputShouldProvideSampleAccurateRecordingStart(_ output: AVCaptureFileOutput) -> Bool {
        
        return false
    }
}

extension MovieCapture: AVCaptureFileOutputRecordingDelegate {
    
    public func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        
        completionHandler?(outputFileURL, error)
        completionHandler = nil
    }
}
