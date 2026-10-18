//
//  SettingsView.swift
//  GridGuide
//

import ServiceManagement
import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings: GridSettings
    @ObservedObject var shortcutManager: ShortcutManager

    var body: some View {
        VStack(spacing: 0) {
            if !settings.hasSeenWelcome {
                WelcomeBanner(settings: settings)
                Divider()
            }
            TabView {
                LayoutsTab(settings: settings)
                    .tabItem { Label("Layouts", systemImage: "square.grid.3x3") }
                AppearanceTab(settings: settings)
                    .tabItem { Label("Appearance", systemImage: "paintpalette") }
                GeneralTab(settings: settings, shortcutManager: shortcutManager)
                    .tabItem { Label("General", systemImage: "gearshape") }
            }
            .padding(12)
        }
        .frame(width: 680, height: settings.hasSeenWelcome ? 520 : 600)
    }
}

private struct WelcomeBanner: View {
    @ObservedObject var settings: GridSettings

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: "squareshape.split.3x3")
                .font(.system(size: 28))
                .foregroundStyle(Color.accentColor)
            VStack(alignment: .leading, spacing: 4) {
                Text("Grid Guide lives in your menu bar")
                    .font(.headline)
                Text(welcomeText)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
            Button("Got It") {
                settings.hasSeenWelcome = true
            }
            .keyboardShortcut(.defaultAction)
        }
        .padding(16)
    }

    private var welcomeText: String {
        let toggle = settings.shortcuts[.toggleGrid].map { "Press \($0.displayString) anywhere to show or hide the grid. " } ?? ""
        return toggle + "Pick a layout below or build your own: square grids, columns and composition guides."
    }
}

// MARK: - Layouts

private struct LayoutsTab: View {
    @ObservedObject var settings: GridSettings

    var body: some View {
        HStack(spacing: 0) {
            VStack(spacing: 0) {
                List(selection: selection) {
                    ForEach(settings.presets) { preset in
                        Text(preset.name)
                            .tag(preset.id)
                    }
                    .onMove { settings.presets.move(fromOffsets: $0, toOffset: $1) }
                }
                .listStyle(.sidebar)

                Divider()
                HStack(spacing: 2) {
                    Button(action: settings.addPreset) {
                        Image(systemName: "plus")
                    }
                    .help("New layout")
                    Button(action: settings.deleteActivePreset) {
                        Image(systemName: "minus")
                    }
                    .help("Delete layout")
                    .disabled(!settings.canDeletePreset)
                    Button(action: settings.duplicateActivePreset) {
                        Image(systemName: "plus.square.on.square")
                    }
                    .help("Duplicate layout")
                    Spacer()
                }
                .buttonStyle(.borderless)
                .padding(6)
            }
            .frame(width: 180)

            Divider()

            PresetEditor(preset: activePreset)
        }
    }

    private var selection: Binding<UUID?> {
        Binding(
            get: { settings.activePresetID },
            set: { id in
                if let id { settings.selectPreset(id) }
            }
        )
    }

    private var activePreset: Binding<GridPreset> {
        Binding(
            get: { settings.activePreset },
            set: { settings.activePreset = $0 }
        )
    }
}

private struct PresetEditor: View {
    @Binding var preset: GridPreset

    var body: some View {
        Form {
            Section {
                TextField("Name", text: $preset.name)
            }

            Section {
                Toggle("Square grid", isOn: $preset.grid.isEnabled)
                NumberField(title: "Cell size", value: $preset.grid.size, range: SquareGrid.sizeRange, step: 1, unit: "pt")
                    .disabled(!preset.grid.isEnabled)
                Picker("Lines", selection: $preset.grid.axes) {
                    ForEach(GridAxes.allCases) { axes in
                        Text(axes.title).tag(axes)
                    }
                }
                .pickerStyle(.segmented)
                .disabled(!preset.grid.isEnabled)
            } footer: {
                Text("Use Rows for a baseline grid.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section {
                Toggle("Columns", isOn: $preset.columns.isEnabled)
                Group {
                    LabeledContent("Count") {
                        Stepper(value: $preset.columns.count, in: ColumnGrid.countRange) {
                            Text("\(preset.columns.count)")
                                .monospacedDigit()
                        }
                    }
                    NumberField(title: "Gutter", value: $preset.columns.gutter, range: ColumnGrid.gutterRange, step: 1, unit: "pt")
                    NumberField(title: "Margin", value: $preset.columns.margin, range: ColumnGrid.marginRange, step: 1, unit: "pt")
                    NumberField(title: "Max width", value: $preset.columns.maxWidth, range: ColumnGrid.maxWidthRange, step: 10, unit: "pt")
                }
                .disabled(!preset.columns.isEnabled)
            } footer: {
                Text("Columns sit in a centred container. Set max width to 0 to span the whole display.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("Guides") {
                Toggle("Center lines", isOn: $preset.guides.showsCenter)
                Toggle("Rule of thirds", isOn: $preset.guides.showsThirds)
            }
        }
        .formStyle(.grouped)
    }
}

/// A numeric text field paired with a stepper. Values are clamped to `range`.
private struct NumberField: View {
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    let unit: String

    var body: some View {
        LabeledContent(title) {
            HStack(spacing: 4) {
                TextField(title, value: clamped, format: .number.precision(.fractionLength(0...1)))
                    .labelsHidden()
                    .multilineTextAlignment(.trailing)
                    .frame(width: 70)
                Stepper(title, value: clamped, in: range, step: step)
                    .labelsHidden()
                Text(unit)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var clamped: Binding<Double> {
        Binding(
            get: { value },
            set: { value = min(max($0, range.lowerBound), range.upperBound) }
        )
    }
}

// MARK: - Appearance

private struct AppearanceTab: View {
    @ObservedObject var settings: GridSettings

    var body: some View {
        Form {
            Section {
                ColorPicker("Line color", selection: color, supportsOpacity: false)
                LabeledContent("Line width") {
                    HStack {
                        Slider(value: $settings.style.lineWidth, in: GridStyle.lineWidthRange, step: 0.5)
                            .frame(width: 180)
                        Text(String(format: "%.1f pt", settings.style.lineWidth))
                            .monospacedDigit()
                            .frame(width: 48, alignment: .trailing)
                    }
                }
                LabeledContent("Opacity") {
                    HStack {
                        Slider(value: $settings.opacity, in: GridSettings.opacityRange)
                            .frame(width: 180)
                        Text("\(Int((settings.opacity * 100).rounded()))%")
                            .monospacedDigit()
                            .frame(width: 48, alignment: .trailing)
                    }
                }
            }

            Section {
                Toggle("Contrast outline", isOn: $settings.style.showsContrastOutline)
            } footer: {
                Text("Adds a dark or light edge to every line so the grid stays visible on both light and dark content.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section {
                LabeledContent("Presets") {
                    HStack(spacing: 6) {
                        ForEach(Self.swatches.indices, id: \.self) { index in
                            let swatch = Self.swatches[index]
                            Button {
                                settings.style.color = swatch
                            } label: {
                                Circle()
                                    .fill(swatch.color)
                                    .overlay(Circle().strokeBorder(.primary.opacity(0.25)))
                                    .frame(width: 18, height: 18)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
        .formStyle(.grouped)
    }

    private static let swatches: [RGBAColor] = [
        RGBAColor(red: 1, green: 0.23, blue: 0.19),
        RGBAColor(red: 1, green: 0.18, blue: 0.85),
        RGBAColor(red: 0.04, green: 0.52, blue: 1),
        RGBAColor(red: 0.2, green: 0.78, blue: 0.35),
        RGBAColor(red: 1, green: 0.8, blue: 0),
        RGBAColor(red: 1, green: 1, blue: 1),
        RGBAColor(red: 0, green: 0, blue: 0),
    ]

    private var color: Binding<Color> {
        Binding(
            get: { settings.style.color.color },
            set: { settings.style.color = RGBAColor($0) }
        )
    }
}

// MARK: - General

private struct GeneralTab: View {
    @ObservedObject var settings: GridSettings
    @ObservedObject var shortcutManager: ShortcutManager
    @StateObject private var launchAtLogin = LaunchAtLogin()

    var body: some View {
        Form {
            Section {
                Toggle("Launch at login", isOn: Binding(
                    get: { launchAtLogin.isEnabled },
                    set: { launchAtLogin.setEnabled($0) }
                ))
                if let message = launchAtLogin.message {
                    Text(message)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Section("Keyboard Shortcuts") {
                ForEach(ShortcutAction.allCases) { action in
                    LabeledContent(action.title) {
                        VStack(alignment: .trailing, spacing: 2) {
                            ShortcutRecorder(
                                shortcut: settings.shortcuts[action],
                                onShortcutChange: { settings.setShortcut($0, for: action) },
                                onRecordingChange: { shortcutManager.isPaused = $0 }
                            )
                            if shortcutManager.unavailableActions.contains(action) {
                                Text("In use by another app")
                                    .font(.caption)
                                    .foregroundStyle(.red)
                            }
                        }
                    }
                }
            }
        }
        .formStyle(.grouped)
        .onAppear(perform: launchAtLogin.refresh)
    }
}

/// Wraps `SMAppService.mainApp`, which works inside the App Sandbox.
private final class LaunchAtLogin: ObservableObject {
    @Published private(set) var isEnabled = false
    @Published private(set) var message: String?

    init() {
        refresh()
    }

    func refresh() {
        let status = SMAppService.mainApp.status
        isEnabled = status == .enabled
        message = status == .requiresApproval
            ? "Allow Grid Guide in System Settings › General › Login Items."
            : nil
    }

    func setEnabled(_ enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
            refresh()
        } catch {
            refresh()
            message = error.localizedDescription
        }
    }
}
