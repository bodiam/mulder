import Cocoa
import SwiftUI
import Foundation
import AVFoundation


class MyNSWindow : NSWindow {
    private var captureSession: AVCaptureSession?
    private var cameraCaptureOutput: CameraCaptureOutput?
    private var stillImageOutput: AVCapturePhotoOutput?
    
    func start() {
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .medium
        
        guard let backCamera = AVCaptureDevice.default(for: AVMediaType.video)
            else {
                print("Unable to access back camera!")
                return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
            let stillImageOutput = AVCapturePhotoOutput()
                                    
            if captureSession.canAddInput(input) && captureSession.canAddOutput(stillImageOutput) {
                captureSession.addInput(input)
                captureSession.addOutput(stillImageOutput)
                captureSession.startRunning()
            }
            self.stillImageOutput = stillImageOutput
            self.captureSession = captureSession
        }
        catch let error  {
            print("Error Unable to initialize back camera:  \(error.localizedDescription)")
        }
    }
    
    override func flagsChanged(with event: NSEvent) {
        print("flag changed")

        makePhoto()
    }
   
    override func mouseDown(with event: NSEvent) {
       print("Mouse down")
        
        makePhoto()
    }
    
    override func keyDown(with event: NSEvent) {
        print("Received key \(event.keyCode)")

        makePhoto()
    }
    
    func makePhoto() {
        if let stillImageOutput = self.stillImageOutput {
            print("Capturing")
            let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
            let output = CameraCaptureOutput()
            stillImageOutput.capturePhoto(with: settings, delegate: output)
            self.cameraCaptureOutput = output
        } else {
          print("Call start first")
        }
        
        lockScreen()
    }
    
    func lockScreen() {
        print("Lockscreen")
        
        shell("/System/Library/CoreServices/ScreenSaverEngine.app/Contents/MacOS/ScreenSaverEngine")
                
        let seconds = 4.0
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            print("Exit")
            
            exit(0)
        }
    }
    
    @discardableResult
    func shell(_ args: String...) -> Int32 {
        let url = URL(fileURLWithPath:args[0])
        do {
            try Process.run(url, arguments: []) { (process) in
                print("\ndidFinish: \(!process.isRunning) : \(process.terminationStatus)")
            }
        } catch {}
        
        return 0
    }
}

class CameraCaptureOutput: NSObject, AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation()
            else { return }
        
        let image = NSImage(data: imageData)
        let paths = FileManager.default.urls(for: .picturesDirectory, in: .userDomainMask)
        let newPicturePath = URL(fileURLWithPath: "blah-" + String(NSDate().timeIntervalSince1970 * 1000) + ".png"  , isDirectory: false, relativeTo: paths[0])
        let result = self.savePNG(image: image!, path: newPicturePath)
        print("capture photo, result=\(result)")
    }
    
    func savePNG(image: NSImage, path: URL) -> Bool {
        let imageRep = NSBitmapImageRep(data: image.tiffRepresentation!)
        let pngData = imageRep?.representation(using: NSBitmapImageRep.FileType.png, properties: [:])
        
        do {
            try pngData?.write(to: path, options: [.atomic])
        } catch {
            fatalError("Failed to write: \(error.localizedDescription)")
        }
        
        return true
    }
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var window: MyNSWindow!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        // Create the SwiftUI view that provides the window contents.
        let contentView = ContentView()
        
        // Create the window and set the content view.
        window = MyNSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.toggleFullScreen(nil)
        window.center()
        window.setFrameAutosaveName("Main Window")
        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(nil)
        window.makeFirstResponder(nil)
        window.start()
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}
