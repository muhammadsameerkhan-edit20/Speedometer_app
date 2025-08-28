# Google Maps API Key Setup

To fix the map functionality in your speedometer app, you need to set up a Google Maps API key.

## Steps to Get Google Maps API Key:

### 1. Go to Google Cloud Console
- Visit: https://console.cloud.google.com/
- Sign in with your Google account

### 2. Create a New Project (or select existing)
- Click on the project dropdown at the top
- Click "New Project" or select an existing one
- Give it a name (e.g., "Speedometer App")

### 3. Enable Maps SDK for Android
- In the left sidebar, click "APIs & Services" > "Library"
- Search for "Maps SDK for Android"
- Click on it and click "Enable"

### 4. Create Credentials
- Go to "APIs & Services" > "Credentials"
- Click "Create Credentials" > "API Key"
- Copy the generated API key

### 5. Restrict the API Key (Recommended)
- Click on the created API key
- Under "Application restrictions", select "Android apps"
- Add your app's package name: `com.example.speedo_meter`
- Add your SHA-1 certificate fingerprint
- Under "API restrictions", select "Restrict key" and choose "Maps SDK for Android"

### 6. Add API Key to Your App
- Open `android/local.properties`
- Add this line:
```
MAPS_API_KEY=your_actual_api_key_here
```

### 7. Rebuild Your App
```bash
flutter clean
flutter pub get
flutter build apk --release
```

## Alternative: Quick Test with Unrestricted Key
If you want to test quickly (not recommended for production):
- Use the unrestricted API key temporarily
- The map should work immediately after adding the key

## Troubleshooting:
- Make sure the API key is correctly added to `local.properties`
- Verify the Maps SDK for Android is enabled
- Check that your app has internet permission
- Ensure location permissions are granted

## Security Note:
- Never commit your API key to version control
- Use restricted API keys for production apps
- Monitor your API usage in Google Cloud Console
