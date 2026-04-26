# GridGuide Quality Backlog

Last audit: 2026-04-27

Baseline verification:

- `xcodebuild -list -project GridGuide.xcodeproj`: succeeded; scheme `GridGuide` found.
- `xcodebuild -project GridGuide.xcodeproj -scheme GridGuide -configuration Debug -derivedDataPath /tmp/GridGuideDerivedData -destination platform=macOS build CODE_SIGNING_ALLOWED=NO`: succeeded outside the Codex sandbox. The same command failed inside the sandbox because `sandbox-exec` could not apply the Swift compiler sandbox.

Priority formula: Impact x Confidence / Effort.

## Q-001

- Item ID: Q-001
- Title: Recalculate grid cells from the live view size
- Category: UX correctness
- Severity: High
- Confidence: 4
- Estimated effort: 1
- Priority score: 20.0
- Status: DONE
- Evidence: `GridGuideView` captures `NSScreen.main?.visibleFrame` once in stored properties, initializes row and column counts from those fixed values, and ignores the `GeometryReader` size. Resizing, screen changes, or window frame adjustments can leave the overlay grid out of sync with the actual window bounds.
- Proposed fix: Derive row and column counts from `GeometryProxy.size` on each render and keep the count calculation covered by unit tests.
- Verification plan: Run `xcodebuild -project GridGuide.xcodeproj -scheme GridGuide -configuration Debug -derivedDataPath /tmp/GridGuideDerivedData -destination platform=macOS test -only-testing:GridGuideTests CODE_SIGNING_ALLOWED=NO`.
- Verification result: Passed. Full scheme test also ran the unit tests successfully, but the placeholder UI test runner exited before bootstrapping.
- Commit hash when completed: bfc8faa

## Q-002

- Item ID: Q-002
- Title: Add meaningful UI smoke coverage or remove the placeholder UI target
- Category: Test gap
- Severity: Medium
- Confidence: 3
- Estimated effort: 3
- Priority score: 3.0
- Status: TODO
- Evidence: `GridGuideUITests.swift` still contains the default template launch test without assertions. A full scheme test completed the unit tests but the UI test runner exited before bootstrapping, so this target is not yet a useful quality gate.
- Proposed fix: Either add a stable UI smoke assertion that can run on local and CI macOS hosts, or remove the placeholder UI test target from routine verification.
- Verification plan: Run `xcodebuild -project GridGuide.xcodeproj -scheme GridGuide -configuration Debug -derivedDataPath /tmp/GridGuideDerivedData -destination platform=macOS test CODE_SIGNING_ALLOWED=NO`.
- Commit hash when completed:

## Q-003

- Item ID: Q-003
- Title: Use typed notification names consistently
- Category: Maintainability
- Severity: Medium
- Confidence: 4
- Estimated effort: 1
- Priority score: 12.0
- Status: DONE
- Evidence: `NotificationExtension.swift` defines typed names, but `GridGuideApp` posts notifications using raw `NSNotification.Name("...")` strings. A typo would compile and silently disconnect menu controls from the overlay.
- Proposed fix: Post notifications with `.gridSizeChanged`, `.gridTransparencyChanged`, and `.gridVisibilityChanged`.
- Verification plan: Run `xcodebuild -project GridGuide.xcodeproj -scheme GridGuide -configuration Debug -derivedDataPath /tmp/GridGuideDerivedData -destination platform=macOS build CODE_SIGNING_ALLOWED=NO`.
- Verification result: Passed.
- Commit hash when completed: e1725d1

## Q-004

- Item ID: Q-004
- Title: Make CI independent of unavailable formatter tools
- Category: Build reliability
- Severity: Medium
- Confidence: 3
- Estimated effort: 1
- Priority score: 9.0
- Status: DONE
- Evidence: The GitHub Actions workflow pipes `xcodebuild` through `xcpretty`, but the repository does not install or pin `xcpretty`. If the runner image does not include it, CI fails before reporting real build errors.
- Proposed fix: Either install `xcpretty` explicitly or remove the formatter pipe and rely on raw `xcodebuild` output.
- Verification plan: Inspect workflow syntax and run the local build command it invokes without relying on unpinned tools.
- Verification result: Passed with `xcodebuild clean build analyze -scheme GridGuide -project GridGuide.xcodeproj -derivedDataPath /tmp/GridGuideCIDerivedData -destination platform=macOS CODE_SIGNING_ALLOWED=NO`.
- Commit hash when completed: Pending commit.

## Q-005

- Item ID: Q-005
- Title: Ignore local Finder metadata in the repository
- Category: Repository hygiene
- Severity: Low
- Confidence: 4
- Estimated effort: 1
- Priority score: 8.0
- Status: TODO
- Evidence: `.DS_Store` files exist in the working tree, but `.gitignore` only ignores Xcode user data. Local Finder metadata can accidentally appear as untracked noise on machines without a global ignore.
- Proposed fix: Add `.DS_Store` to `.gitignore`.
- Verification plan: Run `git status --short` and confirm no unrelated files are staged.
- Commit hash when completed:
