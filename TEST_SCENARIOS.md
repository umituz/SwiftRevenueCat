# SwiftRevenueCat — Manual Test Scenarios

This document describes every test scenario you should manually verify before releasing. Each scenario includes step-by-step instructions, expected results, and pass/fail criteria.

---

## 1. Configuration

### 1.1 Happy Path — Valid API Key

**Precondition:** `RCApiKey` is set in `Info.plist` with a valid RevenueCat API key.

**Steps:**
1. Launch the app from a clean install (delete app first).
2. Observe console logs.

**Expected:**
- No error alert shown.
- `SubscriptionStore.shared.isPro == false`.
- `SubscriptionStore.shared.isLoading` transitions `true → false`.
- `SubscriptionStore.shared.configurationError == nil`.
- `SubscriptionStore.shared.offerings` is populated after a few seconds.
- `SubscriptionStore.shared.plans` contains at least one plan.
- Console: `"RevenueCat configured successfully"`.

**Pass:** All above true.
**Fail:** Any above false. Check API key in Info.plist.

---

### 1.2 Missing API Key

**Precondition:** Remove `RCApiKey` from `Info.plist` or set it to empty string.

**Steps:**
1. Launch the app.
2. Check `SubscriptionStore.shared.configurationError`.

**Expected:**
- `configurationError` is non-nil and contains "missing or empty" message.
- `isPro == false`.
- `offerings == nil`.
- Console: `"RevenueCat configuration failed - API key missing"`.

**Pass:** Error surfaced correctly.
**Fail:** Silent failure or crash.

---

### 1.3 Duplicate configure() Calls

**Precondition:** Valid API key set.

**Steps:**
1. Call `SubscriptionStore.shared.configure()`.
2. Call `SubscriptionStore.shared.configure()` again immediately.

**Expected:**
- Second call is silently ignored.
- Console: `"SubscriptionStore already configured - ignoring duplicate call"`.

**Pass:** No crash, no double initialization.

---

### 1.4 Reset and Reconfigure

**Precondition:** Valid API key. Store is configured.

**Steps:**
1. Call `SubscriptionStore.shared.configure()`.
2. Wait for offerings to load.
3. Call `SubscriptionStore.shared.reset()`.
4. Call `SubscriptionStore.shared.configure()` again.

**Expected:**
- After reset: all state cleared (`isPro == false`, `offerings == nil`, `plans == []`, `customerInfo == nil`).
- Second configure succeeds — offerings load again.
- Console: `"SubscriptionStore reset"` then `"RevenueCat configured successfully"`.

**Pass:** Reconfiguration works after reset.

---

## 2. Purchase Flow

### 2.1 Successful Purchase

**Precondition:** Sandbox account configured in Settings > App Store > Sandbox Account. Valid offerings loaded.

**Steps:**
1. Tap the purchase button for any plan.
2. Complete the sandbox purchase dialog (confirm with sandbox account).
3. Wait for the purchase to complete.

**Expected:**
- `isLoading` transitions `true → false`.
- `isPro == true`.
- `customerInfo` is non-nil.
- `activePlan` matches the purchased plan.
- `display.isPro == true`.
- `display.planName` shows the purchased plan title.
- `relativeExpirationDate` shows a relative date string.
- `onStatusChanged` callback fired with `(true, customerInfo)`.
- Console: `"Purchase successful and entitled"`.

**Pass:** All above true.

---

### 2.2 User Cancels Purchase

**Precondition:** Valid offerings loaded.

**Steps:**
1. Tap the purchase button for any plan.
2. Tap "Cancel" on the sandbox purchase dialog.

**Expected:**
- `isLoading` returns to `false`.
- `isPro` remains unchanged.
- Purchase call returns `PurchaseResult.cancelled`.
- No error alert shown to user.
- Console: `"User cancelled purchase"`.

**Pass:** Cancel handled gracefully, no crash, no error shown.

---

### 2.3 Purchase on Restricted Device

**Precondition:** Enable Screen Time > Content & Privacy Restrictions > In-App Purchases = OFF.

**Steps:**
1. Try to purchase any plan.

**Expected:**
- Purchase returns `PurchaseResult.failed(.purchaseNotAllowed)`.
- `isPro` remains `false`.
- `errorMessage` contains "not allowed" or "restricted" text.
- Console: `"Device cannot make payments - restrictions enabled"`.

**Pass:** Clear error, no crash.

---

### 2.4 Purchase with No Network

**Precondition:** Airplane mode ON. Valid API key configured.

**Steps:**
1. Launch app with airplane mode.
2. Try to purchase any plan.

**Expected:**
- Purchase returns `PurchaseResult.failed(.networkError)`.
- `errorMessage` contains network-related text.
- `isPro` remains `false`.

**Pass:** Network error surfaced clearly.

---

## 3. Restore Flow

### 3.1 Restore with Active Purchase

**Precondition:** A sandbox purchase was previously completed (possibly on another device with same sandbox account).

**Steps:**
1. Delete and reinstall the app.
2. Configure store.
3. Call `SubscriptionStore.shared.restorePurchases()`.

**Expected:**
- Returns `RestoreResult.restored`.
- `isPro == true`.
- `customerInfo` populated with active entitlement.
- Console: `"Restore successful - Pro status found"`.

**Pass:** Pro status restored.

---

### 3.2 Restore with No Previous Purchase

**Precondition:** Fresh sandbox account with no purchases.

**Steps:**
1. Call `SubscriptionStore.shared.restorePurchases()`.

**Expected:**
- Returns `RestoreResult.nothingToRestore`.
- `isPro == false`.
- Console: `"Restore finished - No Pro status found"`.

**Pass:** No crash, no false positive.

---

### 3.3 Restore with Network Error

**Precondition:** Airplane mode ON.

**Steps:**
1. Call `SubscriptionStore.shared.restorePurchases()`.

**Expected:**
- Returns `RestoreResult.failed(.networkError)`.
- `isPro` remains unchanged.

**Pass:** Network error handled gracefully.

---

## 4. Entitlement Resolution

### 4.1 Dynamic Entitlement (No entitlementId)

**Precondition:** RevenueCat dashboard has at least one active entitlement. `Configuration` initialized without `entitlementId`.

**Steps:**
1. Complete a sandbox purchase.
2. Check `SubscriptionStore.shared.isPro`.

**Expected:**
- `isPro == true` — first active entitlement detected automatically.
- `EntitlementResolver.isPro(from: customerInfo)` returns `true`.

**Pass:** Dynamic detection works.

---

### 4.2 Specific Entitlement ID

**Precondition:** RevenueCat dashboard has entitlement named "pro_access".

**Steps:**
1. Configure with `Configuration(entitlementId: "pro_access")`.
2. Complete a sandbox purchase that grants "pro_access".
3. Check `SubscriptionStore.shared.isPro`.

**Expected:**
- `isPro == true`.
- `EntitlementResolver.activeEntitlement(from: customerInfo, entitlementId: "pro_access")` returns the correct entitlement.

**Pass:** Specific entitlement resolved correctly.

---

### 4.3 No Active Entitlement

**Precondition:** No purchase completed.

**Steps:**
1. Check `SubscriptionStore.shared.isPro`.
2. Call `EntitlementResolver.activeEntitlement(from: customerInfo)`.

**Expected:**
- `isPro == false`.
- `activeEntitlement` returns `nil`.

**Pass:** Clean free state.

---

## 5. Plan Display

### 5.1 Plan Mapping

**Precondition:** Valid offerings loaded with annual, monthly, and weekly packages.

**Steps:**
1. Check `SubscriptionStore.shared.plans`.

**Expected:**
- Plans sorted by price (cheapest first).
- Annual plan has `badge == "Best Value"`.
- Weekly plan has `badge == "Most Popular"`.
- Each plan has non-empty `title`, `price`, `period`.
- `period` format: `"/ month"`, `"/ year"`, `"/ week"`, or `"once"`.

**Pass:** Plans rendered correctly.

---

### 5.2 Savings Calculation

**Precondition:** Offerings contain both weekly and annual plans.

**Steps:**
1. Find the annual plan in `plans`.
2. Check `savingsText`.

**Expected:**
- `savingsText` is non-nil, format: `"SAVE XX%"`.
- Percentage is positive integer.
- Calculation: `((weekly_price - annual_price/52) / weekly_price) * 100`.

**Pass:** Savings displayed correctly.

---

### 5.3 Free Trial Display

**Precondition:** A product with introductory free trial discount is configured in RevenueCat/App Store Connect.

**Steps:**
1. Find the plan with `hasFreeTrial == true`.
2. Check `trialPeriod`, `introductoryPrice`, `offerDescription`.

**Expected:**
- `hasFreeTrial == true`.
- `introductoryPrice == "Free"`.
- `trialPeriod` shows something like `"1 week"`.
- `offerDescription` shows `"1 week free, then $X.XX/ week"`.

**Pass:** Trial offer displayed correctly.

---

## 6. Subscription Status & Display

### 6.1 Active Subscription Display

**Precondition:** Active subscription purchased.

**Steps:**
1. Check `SubscriptionStore.shared.display`.

**Expected:**
- `display.isPro == true`.
- `display.isLifetime == false` (for auto-renewable).
- `display.planName` is the product's localized title.
- `display.priceText` is `"$X.XX/ month"` format.
- `display.expirationDate` is a formatted date string.
- `display.purchaseDate` is a formatted date string.
- `display.willRenew == true` (if auto-renewing).
- `display.storeName == "App Store"` (for sandbox).

**Pass:** All display fields correct.

---

### 6.2 Lifetime Purchase Display

**Precondition:** Non-consumable lifetime product purchased.

**Steps:**
1. Check `SubscriptionStore.shared.display`.

**Expected:**
- `display.isPro == true`.
- `display.isLifetime == true`.
- `display.expirationDate == nil` (lifetime has no expiration).
- `display.willRenew == false`.

**Pass:** Lifetime correctly identified.

---

### 6.3 Empty Display (Free User)

**Precondition:** No purchases.

**Steps:**
1. Check `SubscriptionStore.shared.display`.

**Expected:**
- `display.isPro == false`.
- `display.planName == "Free"`.
- All other fields are empty/nil/false.

**Pass:** Clean empty state.

---

### 6.4 Relative Expiration Date

**Precondition:** Active subscription with future expiration date.

**Steps:**
1. Access `SubscriptionStore.shared.relativeExpirationDate`.

**Expected:**
- Returns a human-readable relative string like `"in 29 days"` or `"in 3 weeks"`.
- Returns `nil` if no expiration date (lifetime).

**Pass:** Relative date formatted correctly.

---

## 7. Pro Status Cache

### 7.1 Cache Persistence Across App Launches

**Precondition:** Pro status active.

**Steps:**
1. Subscribe to a plan (verify `isPro == true`).
2. Kill the app (not just background).
3. Turn on airplane mode.
4. Relaunch the app.

**Expected:**
- `ProStatusCache.load()` returns `true` (cached pro status).
- App shows Pro features even without network.

**Pass:** Cache works offline.

---

### 7.2 Cache Expiration

**Precondition:** Subscription has expired.

**Steps:**
1. Wait for sandbox subscription to expire (or force it in RevenueCat dashboard).
2. Relaunch the app with network.

**Expected:**
- `ProStatusCache.load()` returns `false` (cache respects expiration date).
- `isPro == false` after server verification.
- `ProStatusCache.needsReverification()` returns `true` before verification.

**Pass:** Expired subscription correctly detected.

---

### 7.3 Cache Cleared on Reset

**Steps:**
1. Subscribe to a plan.
2. Call `SubscriptionStore.shared.reset()`.
3. Call `ProStatusCache.load()`.

**Expected:**
- `ProStatusCache.load()` returns `false`.
- Keychain entry removed.

**Pass:** Cache cleared completely.

---

## 8. Permission Gateway

### 8.1 Free User Under Limit

**Steps:**
1. `isPro == false`, `currentCount = 2`, `limit = 5`.
2. Call `PermissionGateway.checkCreation(isPro: false, currentCount: 2, limit: 5)`.

**Expected:**
- Returns `PermissionResult(allowed: true, error: nil)`.

**Pass:** Free user allowed when under limit.

---

### 8.2 Free User at Limit

**Steps:**
1. Call `PermissionGateway.checkCreation(isPro: false, currentCount: 5, limit: 5)`.

**Expected:**
- Returns `PermissionResult(allowed: false, error: .freeLimitReached(...))`.
- `error!.errorDescription` contains `"5/5 items limit reached"`.

**Pass:** Free user blocked at limit.

---

### 8.3 Pro User Unlimited

**Steps:**
1. Call `PermissionGateway.checkCreation(isPro: true, currentCount: 999, limit: 5)`.

**Expected:**
- Returns `PermissionResult(allowed: true, error: nil)`.

**Pass:** Pro user always allowed.

---

### 8.4 Limit Info

**Steps:**
1. Call `PermissionGateway.getLimitInfo(isPro: false, currentCount: 3, limit: 5)`.

**Expected:**
- `isUnlimited == false`.
- `remainingSlots == 2`.
- `isAtLimit == false`.

**Pass:** Correct limit calculation.

---

## 9. Login / Logout

### 9.1 Login with User ID

**Precondition:** Valid RevenueCat configuration.

**Steps:**
1. Call `try await SubscriptionStore.shared.logIn("user_123")`.
2. Check return value and state.

**Expected:**
- Returns `true` if new user created, `false` if existing.
- `customerInfo` updated.
- `isPro` reflects the user's subscription status.

**Pass:** Login updates state correctly.

---

### 9.2 Logout

**Steps:**
1. Call `await SubscriptionStore.shared.logOut()`.

**Expected:**
- `customerInfo` updated to anonymous user.
- `isPro` reflects anonymous state.

**Pass:** Logout clears user state.

---

### 9.3 Logout Failure

**Precondition:** Network error during logout.

**Steps:**
1. Enable airplane mode.
2. Call `await SubscriptionStore.shared.logOut()`.

**Expected:**
- `reset()` called as fallback.
- All state cleared.
- Console: `"RevenueCat logout failed: ..."`.

**Pass:** Graceful degradation on logout failure.

---

## 10. Manage Subscription

### 10.1 Open Subscription Management

**Precondition:** Device has App Store account signed in.

**Steps:**
1. Call `SubscriptionStore.shared.manageSubscription()`.

**Expected:**
- Safari/App Store opens to subscription management page.
- URL: `https://apps.apple.com/account/subscriptions` (default).

**Pass:** Subscription management page opens.

---

### 10.2 Custom Management URL

**Steps:**
1. Configure with `Configuration(manageSubscriptionsURL: "https://custom.example.com/manage")`.
2. Call `manageSubscription()`.

**Expected:**
- Opens the custom URL.

**Pass:** Custom URL respected.

---

## 11. Code Redemption

### 11.1 Present Code Redemption Sheet

**Precondition:** iOS device. Not available on macOS.

**Steps:**
1. Call `SubscriptionStore.shared.presentCodeRedemptionSheet()`.

**Expected:**
- App Store code redemption sheet appears.
- No crash on macOS (silently does nothing).

**Pass:** Sheet presents on iOS, no-op on macOS.

---

## 12. Trial Eligibility

### 12.1 Check Trial Eligibility

**Steps:**
1. Call `await SubscriptionStore.shared.checkTrialEligibility(for: "com.app.product_id")`.

**Expected:**
- Returns `.eligible` if user hasn't used a trial before.
- Returns `.ineligible` if user already used a trial.
- Returns `.noOfferAvailable` if product has no intro offer.
- Returns `.unknown` if eligibility can't be determined.

**Pass:** Eligibility result is accurate.

---

## 13. Edge Cases

### 13.1 Multiple Rapid Purchase Attempts

**Steps:**
1. Tap purchase button rapidly 5 times.

**Expected:**
- Only one purchase flow initiated (loading state prevents duplicates).
- No crash.
- No duplicate charges.

**Pass:** Deduplication works.

---

### 13.2 App Background During Purchase

**Steps:**
1. Start a purchase.
2. Immediately background the app (home button).
3. Wait 30 seconds.
4. Return to app.

**Expected:**
- Purchase completes or fails gracefully.
- `isLoading` returns to `false`.
- No frozen loading state.

**Pass:** Background/foreground handles correctly.

---

### 13.3 Offline Launch

**Precondition:** Airplane mode ON. Previously had an active subscription.

**Steps:**
1. Launch app with airplane mode.
2. Check state.

**Expected:**
- `isPro` restored from cache.
- `hasVerifiedWithServer == false`.
- `offerings == nil` (can't fetch without network).
- No crash.

**Pass:** Offline state is usable from cache.

---

### 13.4 Sandbox Detection

**Precondition:** Running in sandbox environment.

**Steps:**
1. Complete a sandbox purchase.
2. Check `SubscriptionStore.shared.display.isSandbox`.

**Expected:**
- `isSandbox == true` in sandbox.
- `isSandbox == false` in production.

**Pass:** Sandbox correctly detected.
