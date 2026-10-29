# 🔐 iOS Code Signing Guide - Custom iSH Build

**Setup Apple Developer & Code Signing for Custom iSH**

---

## **📋 Overview**

Code signing allows you to:
- ✅ Build and test on your iPhone
- ✅ Deploy custom iSH with hotspot control
- ✅ Control distribution (Ad Hoc, TestFlight, App Store)

---

## **Step 1: Apple Developer Account** (Free)

```
1. Visit: https://developer.apple.com
2. Sign in or create account
3. Enroll in Apple Developer Program
   • Individual: $99/year
   • Organization: $99/year
   • Student: Free
4. Agree to terms
```

---

## **Step 2: Certificates**

### **Create Development Certificate:**

```
1. Visit: https://developer.apple.com/account
2. Certificates, Identifiers & Profiles
3. Certificates → +
4. Choose: iOS App Development
5. Upload Certificate Signing Request (CSR)
   
   Option A: Create via Xcode
   • Xcode > Preferences > Accounts
   • Click "Manage Certificates..."
   • Press "+" > iOS Development
   
   Option B: Create manually
   • Open Keychain Access
   • Keychain Access > Certificate Assistant > Request...
   • Save to disk
   • Upload on Apple Developer site

6. Download .cer file
7. Double-click to import to Keychain
```

### **Verify Certificate:**

```bash
# List certificates
security find-certificate -a -c "YOUR_APPLE_ID" -p | openssl x509 -text -noout

# Should show:
# Subject: CN = iPhone Developer
# Issuer: CN = Apple Development
```

---

## **Step 3: App ID & Bundle Identifier**

### **Register App ID:**

```
1. Visit: Apple Developer > Certificates > App IDs
2. Click "+"
3. Description: "iSH Hotspot Control"
4. Bundle ID: app.ish.hotspot
   (must be unique)
5. Check capabilities:
   ✓ Network Extension
   ✓ HotSpot
   ✓ VPN (if needed)
6. Register
```

---

## **Step 4: Provisioning Profile**

### **Create Development Profile:**

```
1. Visit: Certificates > Profiles
2. Click "+"
3. Choose: iOS App Development
4. Select App ID: app.ish.hotspot
5. Select certificate (from Step 2)
6. Select device (your iPhone)
7. Name: "iSH Development"
8. Download .mobileprovision file
9. Double-click to install
```

### **Verify Profile:**

```bash
# List provisioning profiles
ls ~/Library/MobileDevice/Provisioning\ Profiles/

# Should show .mobileprovision files
```

---

## **Step 5: Register Your Device**

### **Get Device UDID:**

**Method 1: Xcode**
```
1. Connect iPhone
2. Xcode > Window > Devices and Simulators
3. Select your device
4. Copy UDID from list
```

**Method 2: Finder**
```
1. Connect iPhone
2. Finder > Select device
3. Click "Serial Number" to toggle UDID
4. Cmd+C to copy
```

**Method 3: iTunes**
```
1. Open iTunes
2. Connect iPhone
3. Summary tab
4. Click "Serial Number" area until UDID shows
5. Cmd+C to copy
```

### **Register Device:**

```
1. Apple Developer > Devices
2. Click "+"
3. Paste UDID
4. Name: "My iPhone"
5. Register
```

---

## **Step 6: Xcode Configuration**

### **Open Project:**

```bash
cd ~/ish
open iSH.xcodeproj
```

### **Set Build Settings:**

```
1. Select iSH.xcodeproj (left panel)
2. Select "iSH" target
3. Build Settings tab
4. Search for each setting below

Set these:
┌─────────────────────────────────────────┐
│ DEVELOPMENT_TEAM = ABCD123456          │ (Your Team ID)
│ PROVISIONING_PROFILE_SPECIFIER =        │
│   iSH Development                       │
│ CODE_SIGN_IDENTITY = iPhone Developer   │
│ CODE_SIGN_STYLE = Automatic             │
│ PRODUCT_BUNDLE_IDENTIFIER =             │
│   app.ish.hotspot                       │
└─────────────────────────────────────────┘
```

### **Find Team ID:**

```
Xcode > Preferences > Accounts
Select your Apple ID
View Details...
Copy "Team ID" (ABCD123456)
```

---

## **Step 7: Build & Deploy**

### **Build on Device:**

```bash
# Option 1: Via Xcode GUI
1. Connect iPhone
2. Select your device (top-left)
3. Cmd+R (Run)
4. Approve on iPhone when prompted
5. App installs and launches

# Option 2: Via Command Line
xcodebuild \
  -project iSH.xcodeproj \
  -scheme iSH \
  -configuration Debug \
  -arch arm64 \
  -derivedDataPath build \
  -destination 'platform=iOS,name=My iPhone'
```

### **Approve on iPhone:**

```
When app builds:
1. iPhone shows dialog
2. Settings > General > Device Management
3. Trust the developer certificate
4. Return to iSH
5. App launches!
```

---

## **Step 8: Automated Setup**

### **Run Setup Script:**

```bash
cd ~/ish
bash scripts/setup-code-signing.sh

# Guides you through:
✓ Apple ID verification
✓ Team ID detection
✓ Certificate installation
✓ Provisioning profile
✓ Device registration
✓ Xcode configuration
```

---

## **🚀 Quick Build & Run**

```bash
# 1. Connect iPhone
# 2. From iSH directory:

xcodebuild build-for-testing \
  -project iSH.xcodeproj \
  -scheme iSH \
  -configuration Release \
  -destination generic/platform=iOS

# 3. Or simpler: Open Xcode and Cmd+R
```

---

## **📝 Troubleshooting**

### **"No profiles for iSH.hotspot"**

```
✓ Check: App ID bundle matches
✓ Check: Device is registered
✓ Check: Profile includes device
✓ Fix: Regenerate profile in Apple Developer
✓ Fix: Re-download and install .mobileprovision
```

### **"Code Signing Identity not found"**

```
✓ Check: Certificate imported to Keychain
✓ Check: Team ID set correctly
✓ Fix: security import certificate.cer -k ~/Library/Keychains/login.keychain
```

### **"iPhone isn't yet registered"**

```
✓ Check: UDID copied correctly
✓ Check: Device shows in Apple Developer
✓ Check: Profile includes device
✓ Fix: Regenerate provisioning profile
```

### **"Trust this app?" on iPhone**

```
This is normal! Tap:
Settings > General > Device Management
Trust [Your Name]
Return to iSH
```

---

## **🔐 Security**

### **Protect Your Files:**

```bash
# Protect certificates (already in Keychain)
# Don't commit to git:

# .gitignore entries:
*.cer
*.p12
*.mobileprovision
*.signing.config
build/
.xcworkspace/xcuserdata/
```

### **Revoke Certificate If Compromised:**

```
1. Apple Developer > Certificates
2. Find certificate
3. Revoke
4. Create new one
5. Update Xcode project
```

---

## **📊 Team ID & Bundle ID Reference**

```
Team ID: Your unique Apple Developer ID
  Format: ABCD123456
  Location: Apple Developer Account
  Xcode: Preferences > Accounts > View Details

Bundle ID: App identifier
  Format: app.ish.hotspot
  Must be unique
  Can't start with reserved words (com.apple, etc)
```

---

## **✅ Checklist Before Building**

```
□ Apple ID account created
□ Developer certificate downloaded & installed
□ App ID registered (app.ish.hotspot)
□ Provisioning profile created & installed
□ iPhone device registered (UDID)
□ Xcode build settings configured
□ Team ID verified
□ Keychain certificate shows "Valid"
□ iPhone connected and trusted
```

---

## **🎯 Distribution Options**

### **Ad Hoc (Test on specific devices)**

```
1. Create Ad Hoc provisioning profile
   • Include specific device UDIDs
2. Build with Ad Hoc profile
3. Export .ipa file
4. Install on registered devices
```

### **TestFlight (Beta testing)**

```
1. Create Testflight profile
2. Upload build to App Store Connect
3. Add testers
4. Testers accept invite
5. Download from TestFlight app
```

### **App Store (Public release)**

```
1. Create App Store profile
2. Submit for review
3. Apple reviews
4. Approved = Public download
```

---

## **📞 Support**

If you encounter issues:

1. **Apple Developer Support**
   - Visit: https://developer.apple.com/support

2. **Xcode Help**
   - Help > Xcode Help > Code Signing

3. **iSH Community**
   - GitHub Issues: github.com/ish-app/ish/issues
   - Discord: https://discord.gg/HFAXj44

---

## **🎉 Success!**

Once code signing is set up:

```bash
# Simply:
cd ~/ish
# Open iSH.xcodeproj in Xcode
# Select your device
# Press Cmd+R

# Your custom iSH builds and installs!
```

---

**🚀 Ready to build your custom iSH!**
