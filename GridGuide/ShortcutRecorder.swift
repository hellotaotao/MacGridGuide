//
//  ShortcutRecorder.swift
//  GridGuide
//

import AppKit
import Carbon.HIToolbox
import SwiftUI

/// Click to record, then press a key combination. Escape cancels, Delete clears.
struct ShortcutRecorder: View {
    let shortcut: Shortcut?
    let onShortcutChange: (Shortcut?) -> Void
    let onRecordingChange: (Bool) -> Void

    @State private var isRecording = false
    @State private var monitor: Any?

    var body: some View {
        HStack(spacing: 4) {
            Button(action: toggleRecording) {
                Text(isRecording ? "Type shortcut…" : shortcut?.displayString ?? "Record Shortcut")
                    .frame(minWidth: 110)
            }
            if shortcut != nil, !isRecording {
                Button {
                    onShortcutChange(nil)
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.borderless)
                .help("Clear shortcut")
            }
        }
        .onDisappear(perform: stopRecording)
    }

    private func toggleRecording() {
        isRecording ? stopRecording() : startRecording()
    }

    private func startRecording() {
        isRecording = true
        onRecordingChange(true)
        monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
            let hasShortcutModifier = !flags.intersection([.command, .control, .option]).isEmpty
            let keyCode = Int(event.keyCode)
            switch keyCode {
            case kVK_Escape:
                stopRecording()
            case _ where (keyCode == kVK_Delete || keyCode == kVK_ForwardDelete) && !hasShortcutModifier:
                onShortcutChange(nil)
                stopRecording()
            default:
                guard let recorded = Shortcut(event: event) else {
                    NSSound.beep()
                    return nil
                }
                onShortcutChange(recorded)
                stopRecording()
            }
            return nil
        }
    }

    private func stopRecording() {
        if let monitor {
            NSEvent.removeMonitor(monitor)
        }
        monitor = nil
        if isRecording {
            isRecording = false
            onRecordingChange(false)
        }
    }
}
