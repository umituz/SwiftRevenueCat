# SwiftRevenueCat

A shared Swift package providing reusable RevenueCat subscription infrastructure across all umituz iOS apps.

## Features

- Dynamic entitlement resolution (no hardcoded entitlement keys)
- Centralized subscription state management (`SubscriptionStore`)
- Offerings fetching with deduplication and retry
- Keychain-based Pro status caching (`ProStatusCache`)
- Real-time CustomerInfo updates via stream observer
- Purchase and restore operations with clean result types
- Permission gateway for feature gating
- Lifetime (non-consumable) purchase support
- Subscription display model mapping for Settings UI

## Requirements

- iOS 17.0+
- Swift 5.9+
- Xcode 15+

## Installation

Add to your `project.yml`:

```yaml
packages:
  SwiftRevenueCat:
    url: https://github.com/umituz/SwiftRevenueCat
    from: 1.0.0

targets:
  YourApp:
    dependencies:
      - package: SwiftRevenueCat
```

## Quick Start

### 1. Configure API Key

Create `Config/Secrets.xcconfig`:

```
RC_API_KEY = your_revenuecat_api_key_here
```

Add to `project.yml`:

```yaml
targets:
  YourApp:
    configFiles:
      Debug: Config/Secrets.xcconfig
      Release: Config/Secrets.xcconfig
    info:
      properties:
        RCApiKey: $(RC_API_KEY)
```

### 2. Initialize in App Entry Point

```swift
import SwiftRevenueCat

@main
struct MyApp: App {
    init() {
        SubscriptionStore.shared.configure()
    }
}
```

### 3. Check Pro Status

```swift
if SubscriptionStore.shared.isPro {
    // Show premium features
}
```

### 4. Optional: Status Change Callback

```swift
SubscriptionStore.shared.onStatusChanged = { isPro, customerInfo in
    // CloudKit sync, analytics, etc.
}
```

## Architecture

```
SubscriptionStore (central @MainActor singleton)
  ├── RCConfigurator (SDK init)
  ├── SubscriptionAPIKeyProvider (API key from Info.plist)
  ├── CustomerInfoObserver (real-time stream)
  ├── OfferingsRepository (fetch + retry + dedup)
  ├── PurchaseExecutor (purchase/restore)
  ├── EntitlementResolver (dynamic entitlement detection)
  ├── PlanMapper (Package -> Plan)
  ├── ProStatusCache (Keychain)
  ├── SubscriptionDisplayMapper (UI display model)
  ├── PermissionGateway (feature gating)
  └── SubscriptionContentResolver (display content)
```

## Protocols

| Protocol | Purpose |
|----------|---------|
| `SubscriptionStateProviding` | Read-only subscription state |
| `OfferingsProviding` | Fetch offerings and refresh status |
| `PurchaseProviding` | Execute purchases and restores |

## Models

| Model | Purpose |
|-------|---------|
| `Plan` | UI representation of a subscription plan |
| `PurchaseResult` | Purchase outcome (success/cancelled/failed) |
| `RestoreResult` | Restore outcome (restored/nothing/failed) |
| `SubscriptionStatus` | Subscription status snapshot |
| `PermissionResult` | Feature permission check result |
| `SubscriptionDisplayModel` | Settings UI display model |

## Key Design Principle

**No hardcoded strings.** Entitlement names, offering names, and package types are all resolved dynamically from the SDK.

```swift
// WRONG
let proActive = info.entitlements["Pro Access"]?.isActive == true

// CORRECT (automatic detection)
let proActive = EntitlementResolver.isPro(from: info)
```

## License

MIT
