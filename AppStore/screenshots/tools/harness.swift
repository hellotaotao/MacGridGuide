// Offscreen renderer for App Store screenshots. Compiled together with the app sources so the
// overlay and settings window are drawn by the real views.
import AppKit
import SwiftUI

let outDir = URL(fileURLWithPath: CommandLine.arguments[1])
let screen = CGSize(width: 1440, height: 900)
let menuBarHeight: CGFloat = 24
let overlaySize = CGSize(width: screen.width, height: screen.height - menuBarHeight)

let suite = "GridGuideScreenshotHarness"
nonisolated(unsafe) let defaults = UserDefaults(suiteName: suite)!
defaults.removePersistentDomain(forName: suite)

func writePNG(_ rep: NSBitmapImageRep, _ name: String) {
    let data = rep.representation(using: .png, properties: [:])!
    try! data.write(to: outDir.appendingPathComponent(name))
    print("wrote \(name) \(rep.pixelsWide)x\(rep.pixelsHigh)")
}

@MainActor
func renderOverlay(_ name: String, preset: GridPreset, style: GridStyle = GridStyle(), opacity: Double = 0.5) {
    let settings = GridSettings(defaults: defaults)
    settings.presets = [preset]
    settings.activePresetID = preset.id
    settings.style = style
    settings.opacity = opacity
    let view = GridGuideView(settings: settings)
        .frame(width: overlaySize.width, height: overlaySize.height)
        .environment(\.displayScale, 2)
    let renderer = ImageRenderer(content: view)
    renderer.scale = 2
    renderer.isOpaque = false
    let rep = NSBitmapImageRep(cgImage: renderer.cgImage!)
    writePNG(rep, name)
}

@MainActor
func renderSymbol(_ symbol: String, pointSize: CGFloat, name: String, weight: NSFont.Weight = .regular) {
    let config = NSImage.SymbolConfiguration(pointSize: pointSize, weight: weight)
    let image = NSImage(systemSymbolName: symbol, accessibilityDescription: nil)!.withSymbolConfiguration(config)!
    let size = image.size
    let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(size.width * 2), pixelsHigh: Int(size.height * 2),
                               bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
                               colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    rep.size = size
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    image.draw(in: NSRect(origin: .zero, size: size))
    NSColor.black.set()
    NSRect(origin: .zero, size: size).fill(using: .sourceAtop)
    NSGraphicsContext.restoreGraphicsState()
    writePNG(rep, name)
}

/// Reports itself active so controls use their active (accent colour) appearance.
final class HarnessApplication: NSApplication {
    override var isActive: Bool { true }
}

/// Draws as the active key window even though a background process cannot take activation.
final class AlwaysKeyWindow: NSWindow {
    override var isKeyWindow: Bool { true }
    override var isMainWindow: Bool { true }
    @objc func _hasActiveAppearance() -> Bool { true }
    @objc func _hasActiveAppearanceIgnoringKeyFocus() -> Bool { true }
    @objc func _hasKeyAppearance() -> Bool { true }
    @objc func _hasMainAppearance() -> Bool { true }
}

@MainActor
func renderSettingsWindow(_ name: String, selectPresetNamed presetName: String, welcome: Bool) {
    let settings = GridSettings(defaults: defaults)
    settings.presets = GridPreset.builtIn()
    settings.activePresetID = settings.presets.first { $0.name == presetName }!.id
    settings.hasSeenWelcome = !welcome
    let shortcutManager = ShortcutManager(settings: settings) { _ in }
    let hosting = NSHostingController(rootView: SettingsView(settings: settings, shortcutManager: shortcutManager))
    let window = AlwaysKeyWindow(contentViewController: hosting)
    window.title = "Grid Guide Settings"
    window.styleMask = [.titled, .closable, .miniaturizable]
    window.appearance = NSAppearance(named: .aqua)
    window.setFrameOrigin(NSPoint(x: -10000, y: -10000))
    NSApp.activate(ignoringOtherApps: true)
    window.makeKeyAndOrderFront(nil)
    RunLoop.main.run(until: Date().addingTimeInterval(1.5))
    // CGWindowListCreateImage is unavailable in the current SDK but still works for the
    // process's own windows without Screen Recording permission.
    typealias CreateImage = @convention(c) (CGRect, UInt32, UInt32, UInt32) -> Unmanaged<CGImage>?
    let handle = dlopen(nil, RTLD_NOW)
    let create = unsafeBitCast(dlsym(handle, "CGWindowListCreateImage")!, to: CreateImage.self)
    // kCGWindowListOptionIncludingWindow = 8, kCGWindowImageBestResolution = 8
    let image = create(.null, 8, UInt32(window.windowNumber), 8)!.takeRetainedValue()
    writePNG(NSBitmapImageRep(cgImage: image), name)
    window.orderOut(nil)
}

@MainActor
func renderAll() {
    let presets = GridPreset.builtIn()
    renderOverlay("overlay-columns.png", preset: presets[2], opacity: 0.7)
    renderOverlay("overlay-8pt.png", preset: presets[1],
                  style: GridStyle(color: RGBAColor(red: 0.04, green: 0.52, blue: 1)), opacity: 0.35)
    renderOverlay("overlay-baseline.png",
                  preset: GridPreset(name: "Article",
                                     grid: SquareGrid(isEnabled: true, size: 24, axes: .horizontal),
                                     columns: ColumnGrid(isEnabled: true, count: 6, gutter: 32, margin: 0, maxWidth: 960),
                                     guides: Guides(showsCenter: false, showsThirds: false)),
                  style: GridStyle(color: RGBAColor(red: 1, green: 0.18, blue: 0.85), lineWidth: 1, showsContrastOutline: false),
                  opacity: 0.55)

    renderSymbol("squareshape.split.3x3", pointSize: 15, name: "sym-grid.png")
    renderSymbol("apple.logo", pointSize: 15, name: "sym-apple.png")
    renderSymbol("wifi", pointSize: 14, name: "sym-wifi.png")
    renderSymbol("battery.75percent", pointSize: 15, name: "sym-battery.png")
    renderSymbol("magnifyingglass", pointSize: 13, name: "sym-search.png")
    renderSymbol("switch.2", pointSize: 13, name: "sym-control.png")

    renderSettingsWindow("settings-columns.png", selectPresetNamed: "12 Columns", welcome: true)
}

final class HarnessDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            renderAll()
            defaults.removePersistentDomain(forName: suite)
            NSApp.terminate(nil)
        }
    }
}

MainActor.assumeIsolated {
    // Overlay scroll bars regardless of this Mac's "Show scroll bars" setting.
    UserDefaults.standard.setVolatileDomain(["AppleShowScrollBars": "WhenScrolling"], forName: UserDefaults.argumentDomain)
    let app = HarnessApplication.shared
    app.setActivationPolicy(.accessory)
    let delegate = HarnessDelegate()
    app.delegate = delegate
    app.run()
}
