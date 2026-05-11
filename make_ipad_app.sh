#!/bin/bash
# ═══════════════════════════════════════════
# LecturePad iPad App Generator
# ═══════════════════════════════════════════
# Usage:
#   1. Put this script and LecturePad.html in the same folder
#   2. chmod +x make_ipad_app.sh
#   3. ./make_ipad_app.sh
#   4. Open LecturePadApp/LecturePadApp.xcodeproj in Xcode
#   5. Connect iPad, select it as target, hit Run

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
HTML_FILE="$SCRIPT_DIR/LecturePad.html"

if [ ! -f "$HTML_FILE" ]; then
    echo "❌ LecturePad.html not found in $SCRIPT_DIR"
    echo "   Put this script and LecturePad.html in the same folder."
    exit 1
fi

PROJ_DIR="$SCRIPT_DIR/LecturePadApp"
SRC_DIR="$PROJ_DIR/LecturePadApp"
XCPROJ="$PROJ_DIR/LecturePadApp.xcodeproj"

echo "🔨 Creating Xcode project..."

mkdir -p "$SRC_DIR"
mkdir -p "$XCPROJ"

# Download CDN scripts for offline use
echo "📥 Downloading dependencies..."
curl -sL "https://cdnjs.cloudflare.com/ajax/libs/pdf.js/3.11.174/pdf.min.js" -o "$SRC_DIR/pdf.min.js"
curl -sL "https://cdnjs.cloudflare.com/ajax/libs/pdf.js/3.11.174/pdf.worker.min.js" -o "$SRC_DIR/pdf.worker.min.js"
curl -sL "https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js" -o "$SRC_DIR/jspdf.umd.min.js"

# Verify downloads
for f in pdf.min.js pdf.worker.min.js jspdf.umd.min.js; do
    if [ ! -s "$SRC_DIR/$f" ]; then
        echo "❌ Failed to download $f. Check your internet connection."
        exit 1
    fi
done
echo "✅ Dependencies downloaded"

# Copy HTML and patch to use local scripts
cp "$HTML_FILE" "$SRC_DIR/LecturePad.html"
sed -i '' 's|https://cdnjs.cloudflare.com/ajax/libs/pdf.js/3.11.174/pdf.min.js|pdf.min.js|g' "$SRC_DIR/LecturePad.html"
sed -i '' 's|https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js|jspdf.umd.min.js|g' "$SRC_DIR/LecturePad.html"
sed -i '' 's|https://cdnjs.cloudflare.com/ajax/libs/pdf.js/3.11.174/pdf.worker.min.js|pdf.worker.min.js|g' "$SRC_DIR/LecturePad.html"

# ── App Entry Point ──
cat > "$SRC_DIR/LecturePadApp.swift" << 'SWIFT'
import SwiftUI

@main
struct LecturePadApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .ignoresSafeArea()
        }
    }
}
SWIFT

# ── ContentView with WKWebView + download/share handling ──
cat > "$SRC_DIR/ContentView.swift" << 'SWIFT'
import SwiftUI
import WebKit
import UniformTypeIdentifiers

struct ContentView: View {
    var body: some View {
        WebView()
            .ignoresSafeArea()
    }
}

class WebViewCoordinator: NSObject, WKScriptMessageHandler, WKUIDelegate, WKNavigationDelegate, UIDocumentPickerDelegate {
    var webView: WKWebView?

    // Handle messages from JavaScript
    func userContentController(_ controller: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let dict = message.body as? [String: Any] else { return }
        let action = dict["action"] as? String ?? ""

        if action == "saveFile" {
            // Save PDF or JSON file
            guard let base64 = dict["data"] as? String,
                  let filename = dict["filename"] as? String,
                  let data = Data(base64Encoded: base64) else { return }

            let tmp = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
            try? data.write(to: tmp)

            DispatchQueue.main.async {
                guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                      let root = scene.windows.first?.rootViewController else { return }
                let ac = UIActivityViewController(activityItems: [tmp], applicationActivities: nil)
                ac.popoverPresentationController?.sourceView = root.view
                ac.popoverPresentationController?.sourceRect = CGRect(x: root.view.bounds.midX, y: 60, width: 0, height: 0)
                root.present(ac, animated: true)
            }
        }

        if action == "openPDF" {
            // Open file picker for PDF
            DispatchQueue.main.async {
                guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                      let root = scene.windows.first?.rootViewController else { return }
                let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.pdf])
                picker.delegate = self
                picker.allowsMultipleSelection = false
                root.present(picker, animated: true)
            }
        }

        if action == "present" {
            DispatchQueue.main.async { self.toggleExternalDisplay() }
        }
    }

    // ── External Display for Present Mode ──
    var extWindow: UIWindow?
    var extImageView: UIImageView?
    var captureTimer: Timer?

    func toggleExternalDisplay() {
        if captureTimer != nil {
            stopExternalDisplay()
            return
        }
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        let screens = scene.windows // Check for external scenes
        // Use the additional screen if available
        let allScenes = UIApplication.shared.connectedScenes
        for s in allScenes {
            guard let ws = s as? UIWindowScene, ws != scene else { continue }
            // Found external scene
            setupExternalWindow(on: ws)
            startCapture()
            return
        }
        // No external display — alert user
        guard let root = scene.windows.first?.rootViewController else { return }
        let alert = UIAlertController(title: "External Display", message: "Connect to a projector or AirPlay display, then tap Present again.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        root.present(alert, animated: true)
    }

    func setupExternalWindow(on scene: UIWindowScene) {
        extWindow = UIWindow(windowScene: scene)
        extWindow?.frame = scene.screen.bounds
        extWindow?.backgroundColor = .black
        let iv = UIImageView(frame: scene.screen.bounds)
        iv.contentMode = .scaleAspectFit
        iv.backgroundColor = .black
        extWindow?.rootViewController = UIViewController()
        extWindow?.rootViewController?.view.addSubview(iv)
        extImageView = iv
        extWindow?.isHidden = false
    }

    func startCapture() {
        captureTimer = Timer.scheduledTimer(withTimeInterval: 1.0/30.0, repeats: true) { [weak self] _ in
            self?.captureCanvas()
        }
    }

    func captureCanvas() {
        webView?.evaluateJavaScript("""
            (function(){
                var p=document.getElementById('pdfCanvas'),d=document.getElementById('drawCanvas');
                if(!p||!d) return '';
                var c=document.createElement('canvas');c.width=p.width;c.height=p.height;
                var x=c.getContext('2d');x.drawImage(p,0,0);x.drawImage(d,0,0);
                return c.toDataURL('image/jpeg',0.85);
            })()
        """) { [weak self] result, _ in
            guard let dataURL = result as? String, dataURL.count > 100,
                  let commaIdx = dataURL.firstIndex(of: ",") else { return }
            let b64 = String(dataURL[dataURL.index(after: commaIdx)...])
            guard let data = Data(base64Encoded: b64),
                  let img = UIImage(data: data) else { return }
            DispatchQueue.main.async { self?.extImageView?.image = img }
        }
    }

    func stopExternalDisplay() {
        captureTimer?.invalidate()
        captureTimer = nil
        extWindow?.isHidden = true
        extWindow = nil
        extImageView = nil
    }

    // File picker result
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        guard url.startAccessingSecurityScopedResource() else { return }
        defer { url.stopAccessingSecurityScopedResource() }

        guard let data = try? Data(contentsOf: url) else { return }
        let base64 = data.base64EncodedString()
        let name = url.deletingPathExtension().lastPathComponent
            .replacingOccurrences(of: "'", with: "\\'")

        DispatchQueue.main.async {
            self.webView?.evaluateJavaScript(
                "window._iosLoadPDF('\(name)', '\(base64)')"
            )
        }
    }

    // Allow inline media
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }
}

struct WebView: UIViewRepresentable {
    func makeCoordinator() -> WebViewCoordinator {
        WebViewCoordinator()
    }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")

        // Register message handler for JS→Swift communication
        let handler = context.coordinator
        config.userContentController.add(handler, name: "iosHandler")

        // Inject iOS detection + bridge script
        let iosScript = WKUserScript(source: """
            window._isIOSApp = true;

            // Override file downloads to use native share sheet
            window._iosSaveFile = function(base64, filename) {
                window.webkit.messageHandlers.iosHandler.postMessage({
                    action: 'saveFile', data: base64, filename: filename
                });
            };

            // Override file open to use native picker
            window._iosOpenPDF = function() {
                window.webkit.messageHandlers.iosHandler.postMessage({action: 'openPDF'});
            };

            // Called from Swift after file picker returns
            window._iosLoadPDF = async function(name, base64) {
                const binary = atob(base64);
                const bytes = new Uint8Array(binary.length);
                for(let i = 0; i < binary.length; i++) bytes[i] = binary.charCodeAt(i);
                const data = bytes.buffer;
                const pdf = await pdfjsLib.getDocument({data: data.slice(0)}).promise;
                newTab('pdf', name, pdf, data);
            };
        """, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        config.userContentController.addUserScript(iosScript)

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.isOpaque = false
        webView.backgroundColor = .black
        webView.scrollView.bounces = false
        webView.scrollView.maximumZoomScale = 1.0
        webView.scrollView.minimumZoomScale = 1.0
        webView.uiDelegate = handler
        webView.navigationDelegate = handler

        handler.webView = webView

        if let url = Bundle.main.url(forResource: "LecturePad", withExtension: "html") {
            webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        }

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
SWIFT

# ── Info.plist ──
cat > "$SRC_DIR/Info.plist" << 'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>
    <string>LecturePad</string>
    <key>CFBundleExecutable</key>
    <string>LecturePadApp</string>
    <key>CFBundleDisplayName</key>
    <string>LecturePad</string>
    <key>CFBundleIdentifier</key>
    <string>com.lecturepad.app</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>LSRequiresIPhoneOS</key>
    <true/>
    <key>UILaunchStoryboardName</key>
    <string></string>
    <key>UIRequiredDeviceCapabilities</key>
    <array>
        <string>arm64</string>
    </array>
    <key>UISupportedInterfaceOrientations~ipad</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
        <string>UIInterfaceOrientationPortraitUpsideDown</string>
        <string>UIInterfaceOrientationLandscapeLeft</string>
        <string>UIInterfaceOrientationLandscapeRight</string>
    </array>
    <key>UISupportsDocumentBrowser</key>
    <true/>
</dict>
</plist>
PLIST

# ── Xcode project.pbxproj ──
# Generate unique IDs
cat > "$XCPROJ/project.pbxproj" << 'PBXPROJ'
// !$*UTF8*$!
{
	archiveVersion = 1;
	classes = {};
	objectVersion = 56;
	objects = {

/* Begin PBXBuildFile section */
		AAA00001 /* LecturePadApp.swift in Sources */ = {isa = PBXBuildFile; fileRef = BBB00001; };
		AAA00002 /* ContentView.swift in Sources */ = {isa = PBXBuildFile; fileRef = BBB00002; };
		AAA00003 /* LecturePad.html in Resources */ = {isa = PBXBuildFile; fileRef = BBB00003; };
		AAA00004 /* pdf.min.js in Resources */ = {isa = PBXBuildFile; fileRef = BBB00005; };
		AAA00005 /* pdf.worker.min.js in Resources */ = {isa = PBXBuildFile; fileRef = BBB00006; };
		AAA00006 /* jspdf.umd.min.js in Resources */ = {isa = PBXBuildFile; fileRef = BBB00007; };
/* End PBXBuildFile section */

/* Begin PBXFileReference section */
		BBB00001 /* LecturePadApp.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = LecturePadApp.swift; sourceTree = "<group>"; };
		BBB00002 /* ContentView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ContentView.swift; sourceTree = "<group>"; };
		BBB00003 /* LecturePad.html */ = {isa = PBXFileReference; lastKnownFileType = text.html; path = LecturePad.html; sourceTree = "<group>"; };
		BBB00004 /* Info.plist */ = {isa = PBXFileReference; lastKnownFileType = text.plist.xml; path = Info.plist; sourceTree = "<group>"; };
		BBB00005 /* pdf.min.js */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.javascript; path = "pdf.min.js"; sourceTree = "<group>"; };
		BBB00006 /* pdf.worker.min.js */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.javascript; path = "pdf.worker.min.js"; sourceTree = "<group>"; };
		BBB00007 /* jspdf.umd.min.js */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.javascript; path = "jspdf.umd.min.js"; sourceTree = "<group>"; };
		BBB00010 /* LecturePadApp.app */ = {isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = LecturePadApp.app; sourceTree = BUILT_PRODUCTS_DIR; };
/* End PBXFileReference section */

/* Begin PBXGroup section */
		CCC00001 = {
			isa = PBXGroup;
			children = (
				CCC00002 /* LecturePadApp */,
				CCC00003 /* Products */,
			);
			sourceTree = "<group>";
		};
		CCC00002 /* LecturePadApp */ = {
			isa = PBXGroup;
			children = (
				BBB00001 /* LecturePadApp.swift */,
				BBB00002 /* ContentView.swift */,
				BBB00003 /* LecturePad.html */,
				BBB00005 /* pdf.min.js */,
				BBB00006 /* pdf.worker.min.js */,
				BBB00007 /* jspdf.umd.min.js */,
				BBB00004 /* Info.plist */,
			);
			path = LecturePadApp;
			sourceTree = "<group>";
		};
		CCC00003 /* Products */ = {
			isa = PBXGroup;
			children = (
				BBB00010 /* LecturePadApp.app */,
			);
			name = Products;
			sourceTree = "<group>";
		};
/* End PBXGroup section */

/* Begin PBXNativeTarget section */
		DDD00001 /* LecturePadApp */ = {
			isa = PBXNativeTarget;
			buildConfigurationList = EEE00003;
			buildPhases = (
				DDD00002 /* Sources */,
				DDD00003 /* Resources */,
			);
			buildRules = ();
			dependencies = ();
			name = LecturePadApp;
			productName = LecturePadApp;
			productReference = BBB00010;
			productType = "com.apple.product-type.application";
		};
/* End PBXNativeTarget section */

/* Begin PBXProject section */
		FFF00001 /* Project object */ = {
			isa = PBXProject;
			attributes = {
				BuildIndependentTargetsInParallel = 1;
				LastSwiftUpdateCheck = 1500;
				LastUpgradeCheck = 1500;
			};
			buildConfigurationList = EEE00001;
			compatibilityVersion = "Xcode 14.0";
			developmentRegion = en;
			hasScannedForEncodings = 0;
			knownRegions = (en, Base);
			mainGroup = CCC00001;
			productRefGroup = CCC00003;
			projectDirPath = "";
			projectRoot = "";
			targets = (DDD00001);
		};
/* End PBXProject section */

/* Begin PBXResourcesBuildPhase section */
		DDD00003 /* Resources */ = {
			isa = PBXResourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
				AAA00003 /* LecturePad.html in Resources */,
				AAA00004 /* pdf.min.js in Resources */,
				AAA00005 /* pdf.worker.min.js in Resources */,
				AAA00006 /* jspdf.umd.min.js in Resources */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXResourcesBuildPhase section */

/* Begin PBXSourcesBuildPhase section */
		DDD00002 /* Sources */ = {
			isa = PBXSourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
				AAA00001 /* LecturePadApp.swift in Sources */,
				AAA00002 /* ContentView.swift in Sources */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXSourcesBuildPhase section */

/* Begin XCBuildConfiguration section */
		EEE00D01 /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CLANG_ENABLE_MODULES = YES;
				CODE_SIGN_STYLE = Automatic;
				INFOPLIST_FILE = LecturePadApp/Info.plist;
				IPHONEOS_DEPLOYMENT_TARGET = 16.0;
				LD_RUNPATH_SEARCH_PATHS = "$(inherited) @executable_path/Frameworks";
				PRODUCT_BUNDLE_IDENTIFIER = com.lecturepad.app;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SDKROOT = iphoneos;
				SUPPORTED_PLATFORMS = "iphoneos iphonesimulator";
				SWIFT_VERSION = 5.0;
				TARGETED_DEVICE_FAMILY = "1,2";
			};
			name = Debug;
		};
		EEE00R01 /* Release */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CLANG_ENABLE_MODULES = YES;
				CODE_SIGN_STYLE = Automatic;
				INFOPLIST_FILE = LecturePadApp/Info.plist;
				IPHONEOS_DEPLOYMENT_TARGET = 16.0;
				LD_RUNPATH_SEARCH_PATHS = "$(inherited) @executable_path/Frameworks";
				PRODUCT_BUNDLE_IDENTIFIER = com.lecturepad.app;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SDKROOT = iphoneos;
				SUPPORTED_PLATFORMS = "iphoneos iphonesimulator";
				SWIFT_VERSION = 5.0;
				TARGETED_DEVICE_FAMILY = "1,2";
			};
			name = Release;
		};
		EEE00D00 /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CLANG_ENABLE_MODULES = YES;
				"CODE_SIGN_IDENTITY[sdk=iphoneos*]" = "Apple Development";
				COPY_PHASE_STRIP = NO;
				DEBUG_INFORMATION_FORMAT = dwarf;
				GCC_OPTIMIZATION_LEVEL = 0;
				IPHONEOS_DEPLOYMENT_TARGET = 16.0;
				SDKROOT = iphoneos;
				SWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG;
				SWIFT_OPTIMIZATION_LEVEL = "-Onone";
				SWIFT_VERSION = 5.0;
			};
			name = Debug;
		};
		EEE00R00 /* Release */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CLANG_ENABLE_MODULES = YES;
				"CODE_SIGN_IDENTITY[sdk=iphoneos*]" = "Apple Development";
				COPY_PHASE_STRIP = YES;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				GCC_OPTIMIZATION_LEVEL = s;
				IPHONEOS_DEPLOYMENT_TARGET = 16.0;
				SDKROOT = iphoneos;
				SWIFT_OPTIMIZATION_LEVEL = "-O";
				SWIFT_VERSION = 5.0;
				VALIDATE_PRODUCT = YES;
			};
			name = Release;
		};
/* End XCBuildConfiguration section */

/* Begin XCConfigurationList section */
		EEE00001 /* Build configuration list for PBXProject */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				EEE00D00 /* Debug */,
				EEE00R00 /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		};
		EEE00003 /* Build configuration list for PBXNativeTarget */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				EEE00D01 /* Debug */,
				EEE00R01 /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		};
/* End XCConfigurationList section */
	};
	rootObject = FFF00001;
}
PBXPROJ

echo ""
echo "  ✅ Project created at: $PROJ_DIR"
echo ""
echo "  Next steps:"
echo "  1. open $XCPROJ"
echo "  2. Xcode → Signing & Capabilities → select your Apple ID"
echo "  3. Connect iPad via USB"
echo "  4. Select your iPad as target (top bar)"
echo "  5. Hit ▶ Run"
echo ""
echo "  No Apple Developer Program ($99) needed."
echo "  Free Apple ID is enough for personal devices."
echo ""

# Auto-open in Xcode
open "$XCPROJ" 2>/dev/null
