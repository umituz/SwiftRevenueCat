# SwiftRevenueCat

A shared Swift package providing reusable RevenueCat subscription infrastructure across all umituz iOS apps.

## Features

- Dynamic entitlement resolution (no hardcoded entitlement keys)
- Centralized subscription state management (`SubscriptionStore`)
- Offerings fetching with deduplication and retry
- Keychain-based subscription cache (`SubscriptionCache`)
- Real-time CustomerInfo updates via stream observer
- Purchase and restore operations with clean result types
- Lifetime (non-consumable) purchase support
- Subscription display model mapping for Settings UI
- Data-driven plan display — badges, savings, and ordering all derived from RevenueCat data

## Requirements

- iOS 17.0+
- macOS 14.0+
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

### 3. Check Subscription Status

```swift
if SubscriptionStore.shared.isSubscribed {
    // Show premium features
}
```

### 4. Purchase a Plan

```swift
let plan = store.plans.first { $0.isAnnual }
let result = await store.purchase(plan)
```

### 5. Purchase a Consumable (credits, coins, one-time packs)

Consumables never grant an entitlement, so success is judged on the
completed transaction instead:

```swift
let offerings = try await Purchases.shared.offerings()
let pack = offerings.current?.availablePackages.first { $0.storeProduct.productIdentifier == "my_credits_100" }
if let pack {
    let result = await store.purchaseConsumable(pack)
    // .success → grant the credits in your app
}
```

### 6. Optional: Status Change Callback

```swift
SubscriptionStore.shared.onStatusChanged = { isSubscribed, customerInfo in
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
  ├── PlanMapper (Package -> Plan, data-driven badges & savings)
  ├── SubscriptionCache (Keychain)
  ├── SubscriptionDisplayMapper (UI display model)
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
| `Plan` | UI representation of a subscription plan (RevenueCat internals hidden) |
| `PurchaseResult` | Purchase outcome (success/cancelled/failed) |
| `RestoreResult` | Restore outcome (restored/nothing/failed) |
| `SubscriptionStatus` | Subscription status snapshot |
| `SubscriptionDisplayModel` | Settings UI display model |
| `TrialEligibility` | Trial eligibility check result |

## Key Design Principles

**No hardcoded strings.** Entitlement names, offering names, and package types are all resolved dynamically from the SDK.

**Data-driven plan display.** Badges, savings percentages, and plan ordering all come from RevenueCat data — no assumptions about which plan types exist.

**Clean API surface.** Purchase via `store.purchase(plan)` — no need to access RevenueCat `Package` type directly.

**Generic terminology.** Uses `isSubscribed` instead of app-specific tier names like "Pro" or "Premium".

```swift
// WRONG
let proActive = info.entitlements["Pro Access"]?.isActive == true

// CORRECT (automatic detection)
let subscribed = EntitlementResolver.hasActiveEntitlement(from: info)
```

## License

MIT
