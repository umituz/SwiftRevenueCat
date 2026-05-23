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
- `SubscriptionStore.shared.isSubscribed == false`.
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
- `configurationError == .apiKeyMissing`.
- `isSubscribed == false`.
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
- After reset: all state cleared (`isSubscribed == false`, `offerings == nil`, `plans == []`, `customerInfo == nil`, `hasVerifiedWithServer == false`).
- RevenueCat customer info cache invalidated.
- Second configure succeeds — offerings load again.
- Console: `"SubscriptionStore reset"` then `"RevenueCat configured successfully"`.

**Pass:** Reconfiguration works after reset.

---

### 1.5 URL-Type Configuration

**Steps:**
1. Configure with a custom URL:
   ```swift
   let config = SubscriptionStore.Configuration(
       manageSubscriptionsURL: URL(string: "https://example.com/manage")!
   )
   SubscriptionStore.shared.configure(with: config)
   ```
2. Call `SubscriptionStore.shared.manageSubscription()`.

**Expected:**
- Safari opens `https://example.com/manage`.
- No string-to-URL conversion errors.
- Compile-time type safety: passing a `String` for `manageSubscriptionsURL` is a compiler error.

**Pass:** URL configuration is type-safe at compile time and opens correctly at runtime.

---

## 2. Purchase Flow

### 2.0 Purchase Result Equatable Conformance

**Precondition:** N/A

**Steps:**
1. Verify `PurchaseResult.success == PurchaseResult.success` compiles.
2. Verify `RestoreResult.restored == RestoreResult.restored` compiles.
3. Verify `PurchaseResult.failed(.networkError) == PurchaseResult.failed(.networkError)` compiles.

**Expected:**
- Both result types conform to `Equatable`.
- Equality comparisons compile and produce correct results.

**Pass:** Equatable conformance works for all result types.

---

### 2.1 Successful Purchase via Plan

**Precondition:** Sandbox account configured. Valid offerings loaded.

**Steps:**
1. Get a plan: `let plan = SubscriptionStore.shared.plans.first!`.
2. Call `await SubscriptionStore.shared.purchase(plan)`.
3. Complete the sandbox purchase dialog.

**Expected:**
- `isLoading` transitions `true → false`.
- `isSubscribed == true`.
- `customerInfo` is non-nil.
- `activePlan` matches the purchased plan.
- `display.isSubscribed == true`.
- `display.planName` shows the purchased plan title.
- `relativeExpirationDate` shows a relative date string.
- `onStatusChanged` callback fired with `(true, customerInfo)`.
- Console: `"Starting purchase for: <id>"` then `"Purchase successful and entitled"`.

**Pass:** All above true.

---

### 2.2 Successful Purchase via Package (Advanced)

**Precondition:** Developer has direct access to RevenueCat `Package`.

**Steps:**
1. Get a package: `let package = SubscriptionStore.shared.offerings?.current?.availablePackages.first!`.
2. Call `await SubscriptionStore.shared.purchase(package)`.

**Expected:**
- Same result as 2.1 — purchase completes successfully.

**Pass:** Both `purchase(_ plan: Plan)` and `purchase(_ package: Package)` work.

---

### 2.3 User Cancels Purchase

**Precondition:** Valid offerings loaded.

**Steps:**
1. Call `await SubscriptionStore.shared.purchase(plan)`.
2. Tap "Cancel" on the sandbox purchase dialog.

**Expected:**
- `isLoading` returns to `false`.
- `isSubscribed` remains unchanged.
- Purchase call returns `PurchaseResult.cancelled`.
- No error alert shown to user.
- Console: `"User cancelled purchase"`.

**Pass:** Cancel handled gracefully, no crash, no error shown.

---

### 2.4 Purchase on Restricted Device

**Precondition:** Enable Screen Time > Content & Privacy Restrictions > In-App Purchases = OFF.

**Steps:**
1. Try to purchase any plan.

**Expected:**
- Purchase returns `PurchaseResult.failed(.purchaseNotAllowed)`.
- `isSubscribed` remains `false`.
- Console: `"Device cannot make payments - restrictions enabled"`.

**Pass:** Clear error, no crash.

---

### 2.5 Purchase with No Network

**Precondition:** Airplane mode ON.

**Steps:**
1. Try to purchase any plan.

**Expected:**
- Purchase returns `PurchaseResult.failed(.networkError)`.
- `isSubscribed` remains `false`.

**Pass:** Network error surfaced clearly.

---

### 2.6 Purchase Without Configuration

**Precondition:** RevenueCat NOT configured (`configure()` not called).

**Steps:**
1. Call `await SubscriptionStore.shared.purchase(plan)`.

**Expected:**
- Returns `PurchaseResult.failed(.notConfigured)`.
- Console: `"Purchases is not configured. Cannot perform purchase."`.

**Pass:** Missing configuration surfaced, no crash.

---

## 3. Restore Flow

### 3.1 Restore with Active Purchase

**Precondition:** A sandbox purchase was previously completed.

**Steps:**
1. Delete and reinstall the app.
2. Configure store.
3. Call `await SubscriptionStore.shared.restorePurchases()`.

**Expected:**
- Returns `RestoreResult.restored`.
- `isSubscribed == true`.
- `customerInfo` populated with active entitlement.
- Console: `"Restore successful - subscription found"`.

**Pass:** Subscription restored.

---

### 3.2 Restore with No Previous Purchase

**Precondition:** Fresh sandbox account with no purchases.

**Steps:**
1. Call `await SubscriptionStore.shared.restorePurchases()`.

**Expected:**
- Returns `RestoreResult.nothingToRestore`.
- `isSubscribed == false`.
- Console: `"Restore finished - no subscription found"`.

**Pass:** No crash, no false positive.

---

### 3.3 Restore with Network Error

**Precondition:** Airplane mode ON.

**Steps:**
1. Call `await SubscriptionStore.shared.restorePurchases()`.

**Expected:**
- Returns `RestoreResult.failed(.networkError)`.
- `isSubscribed` remains unchanged.
- Console: `"Restore failed: ..."`.

**Pass:** Network error handled gracefully.

---

### 3.4 Restore Without Configuration

**Precondition:** RevenueCat NOT configured.

**Steps:**
1. Call `await SubscriptionStore.shared.restorePurchases()`.

**Expected:**
- Returns `RestoreResult.failed(.notConfigured)`.
- Console: `"Purchases is not configured. Cannot perform restore."`.

**Pass:** Error surfaced, no crash.

---

## 4. Entitlement Resolution

### 4.1 Dynamic Entitlement (No entitlementId)

**Precondition:** RevenueCat dashboard has at least one active entitlement. `Configuration` initialized without `entitlementId`.

**Steps:**
1. Complete a sandbox purchase.
2. Check `SubscriptionStore.shared.isSubscribed`.

**Expected:**
- `isSubscribed == true` — first active entitlement detected automatically.
- `EntitlementResolver.hasActiveEntitlement(from: customerInfo)` returns `true`.

**Pass:** Dynamic detection works.

---

### 4.2 Specific Entitlement ID

**Precondition:** RevenueCat dashboard has entitlement named "pro_access".

**Steps:**
1. Configure with `Configuration(entitlementId: "pro_access")`.
2. Complete a sandbox purchase that grants "pro_access".
3. Check `SubscriptionStore.shared.isSubscribed`.

**Expected:**
- `isSubscribed == true`.

**Pass:** Specific entitlement resolved correctly.

---

### 4.3 No Active Entitlement

**Precondition:** No purchase completed.

**Steps:**
1. Check `SubscriptionStore.shared.isSubscribed`.
2. Call `EntitlementResolver.activeEntitlement(from: customerInfo)`.

**Expected:**
- `isSubscribed == false`.
- `activeEntitlement` returns `nil`.

**Pass:** Clean free state.

---

## 5. Plan Display (Data-Driven)

### 5.1 Plan Order Matches RevenueCat Dashboard

**Precondition:** Valid offerings loaded with multiple packages configured in RevenueCat dashboard.

**Steps:**
1. Note the order of packages in RevenueCat dashboard (Current Offering).
2. Check `SubscriptionStore.shared.plans`.

**Expected:**
- Plans appear in the SAME order as RevenueCat dashboard configuration.
- No manual re-sorting applied.

**Pass:** Dashboard order is respected.

---

### 5.2 Best Value Badge — Calculated from Cost-Per-Day

**Precondition:** Offerings contain at least 2 plans with different periods.

**Steps:**
1. Check `SubscriptionStore.shared.plans`.
2. Find the plan with the LOWEST cost-per-day.

**Expected:**
- That plan has `badge != nil` (e.g., "Best Value").
- All other plans have `badge == nil` (unless lifetime).
- Badge is calculated from real data, not hardcoded to annual.

**Pass:** Badge assigned to the actual cheapest-per-day plan.

---

### 5.3 Lifetime Plan Badge

**Precondition:** Offerings contain a lifetime package.

**Steps:**
1. Find the lifetime plan in `plans`.

**Expected:**
- `badge` is set for lifetime.
- `period` indicates one-time.
- `plan.isLifetime == true`.

**Pass:** Lifetime correctly identified and badged.

---

### 5.4 Savings Text — Calculated Against Most Expensive Plan

**Precondition:** Offerings contain at least 2 plans with different prices.

**Steps:**
1. Check each plan's `savingsText`.
2. The most expensive plan (highest cost-per-day) should have `savingsText == nil`.
3. Other plans should show savings percentage.

**Expected:**
- Most expensive plan: `savingsText == nil`.
- Cheaper plans: `savingsText` shows savings percentage.
- Calculation works regardless of plan types.

**Pass:** Savings are mathematically correct and data-driven.

---

### 5.5 Single Plan — No Badge or Savings

**Precondition:** RevenueCat dashboard configured with only 1 package.

**Steps:**
1. Check `SubscriptionStore.shared.plans`.

**Expected:**
- `plans.count == 1`.
- `plans[0].badge == nil`.
- `plans[0].savingsText == nil`.

**Pass:** Single plan has no comparative badges.

---

### 5.6 Free Trial Display

**Precondition:** A product with introductory free trial discount is configured.

**Steps:**
1. Find the plan with `hasFreeTrial == true`.
2. Check `trialPeriod`, `introductoryPrice`, `offerDescription`.

**Expected:**
- `hasFreeTrial == true`.
- `introductoryPrice` shows free trial pricing.
- `trialPeriod` shows something like `"1 week"`.
- `offerDescription` shows offer details.

**Pass:** Trial offer displayed correctly.

---

### 5.7 Clean Plan API — No RevenueCat Package Exposure

**Steps:**
1. Check `Plan` struct public properties.

**Expected:**
- `Plan.revenueCatPackage` is `internal` — not visible to consumers.
- Developer purchases via `store.purchase(plan)` — no need to access `plan.revenueCatPackage`.

**Pass:** RevenueCat internals hidden from public API.

---

## 6. Subscription Status & Display

### 6.1 Active Subscription Display

**Precondition:** Active subscription purchased.

**Steps:**
1. Check `SubscriptionStore.shared.display`.

**Expected:**
- `display.isSubscribed == true`.
- `display.isLifetime == false` (for auto-renewable).
- `display.planName` is the product's localized title.
- `display.priceText` is formatted with currency.
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
- `display.isSubscribed == true`.
- `display.isLifetime == true`.
- `display.expirationDate == nil`.
- `display.willRenew == false`.

**Pass:** Lifetime correctly identified.

---

### 6.3 Empty Display (Free User)

**Precondition:** No purchases.

**Steps:**
1. Check `SubscriptionStore.shared.display`.

**Expected:**
- `display.isSubscribed == false`.
- `display.planName` indicates free tier.
- All other fields are empty/nil/false.

**Pass:** Clean empty state.

---

## 7. Subscription Cache

### 7.1 Cache Persistence Across App Launches

**Precondition:** Subscription active.

**Steps:**
1. Subscribe to a plan (verify `isSubscribed == true`).
2. Kill the app (not just background).
3. Turn on airplane mode.
4. Relaunch the app.

**Expected:**
- Cache entry exists in Keychain with SHA256 integrity hash.
- `isSubscribed` restored from cache before server verification.
- Console: `"Restored subscribed status from offline cache"`.
- App shows subscribed features even without network.

**Pass:** Cache works offline.

---

### 7.2 Cache Expiration

**Precondition:** Subscription has expired.

**Steps:**
1. Wait for sandbox subscription to expire.
2. Relaunch the app with network.

**Expected:**
- `isSubscribed == false` after server verification.
- `SubscriptionCache.needsReverification()` returns `true` before verification.

**Pass:** Expired subscription correctly detected.

---

### 7.3 Cache Cleared on Reset

**Steps:**
1. Subscribe to a plan.
2. Call `SubscriptionStore.shared.reset()`.
3. Check Keychain for cache entry.

**Expected:**
- `isSubscribed == false`.
- Keychain entry removed.
- RevenueCat customer info cache invalidated.
- Console: `"SubscriptionStore reset"`.

**Pass:** Cache cleared completely.

---

### 7.4 Cache Corruption Recovery

**Precondition:** Manually corrupt the keychain entry.

**Steps:**
1. Write invalid data to the keychain entry.
2. Launch the app.

**Expected:**
- Cache returns `false` for subscribed status.
- Corrupted entry is automatically cleared.
- Console: `"Cache entry corrupted, clearing: ..."`.

**Pass:** Corruption detected and cleaned up, no crash.

---

### 7.5 Cache Integrity — Tampering Detection (SHA256)

**Precondition:** Subscription cached with active status.

**Steps:**
1. Modify the payload bytes in the Keychain entry without updating the SHA256 hash.
2. Launch the app.

**Expected:**
- Hash verification fails.
- Cache is cleared immediately.
- Console: `"Cache integrity check failed — possible tampering. Clearing cache."`.
- `isSubscribed == false` (falls back to server verification).
- No crash, no false positive subscription status.

**Pass:** Tampering detected, cache invalidated, no crash.

---

### 7.6 Offline Cache Restore on Configure

**Precondition:** Previously subscribed. Network unavailable.

**Steps:**
1. Subscribe to a plan with network available.
2. Kill the app.
3. Enable airplane mode.
4. Relaunch the app (triggers `configure()`).

**Expected:**
- Before any server call, cache is checked.
- `isSubscribed == true` restored from cache.
- Console: `"Restored subscribed status from offline cache"`.
- `hasVerifiedWithServer == false` until network returns.

**Pass:** Offline restore happens synchronously during configure, before server.

---

## 8. Login / Logout

### 8.1 Login with User ID

**Precondition:** Valid RevenueCat configuration.

**Steps:**
1. Call `try await SubscriptionStore.shared.logIn("user_123")`.

**Expected:**
- Returns `true` if new user created, `false` if existing.
- `customerInfo` updated.
- `isSubscribed` reflects the user's subscription status.

**Pass:** Login updates state correctly.

---

### 8.2 Login Without Configuration

**Precondition:** RevenueCat NOT configured.

**Steps:**
1. Call `try await SubscriptionStore.shared.logIn("user_123")`.

**Expected:**
- Throws `SubscriptionError.notConfigured`.
- No crash.

**Pass:** Error thrown, not silently swallowed.

---

### 8.3 Logout

**Steps:**
1. Call `try await SubscriptionStore.shared.logOut()`.

**Expected:**
- `customerInfo` updated to anonymous user.
- `isSubscribed` reflects anonymous state.

**Pass:** Logout clears user state.

---

### 8.4 Logout Without Configuration

**Precondition:** RevenueCat NOT configured.

**Steps:**
1. Call `try await SubscriptionStore.shared.logOut()`.

**Expected:**
- Throws `SubscriptionError.notConfigured`.
- No crash.

**Pass:** Error thrown, not silently swallowed.

---

## 9. Manage Subscription

### 9.1 Open Subscription Management

**Precondition:** Configured with `manageSubscriptionsURL`.

**Steps:**
1. Call `SubscriptionStore.shared.manageSubscription()`.

**Expected:**
- Safari/App Store opens to the configured management URL.

**Pass:** Subscription management page opens.

---

### 9.2 Management URL Not Configured

**Precondition:** Store NOT configured.

**Steps:**
1. Call `SubscriptionStore.shared.manageSubscription()`.

**Expected:**
- Does NOT open any URL.
- Console: `"manageSubscriptionsURL is not configured"`.

**Pass:** Graceful no-op when not configured.

---

## 10. Code Redemption

### 10.1 Present Code Redemption Sheet

**Precondition:** iOS device (not macOS).

**Steps:**
1. Call `SubscriptionStore.shared.presentCodeRedemptionSheet()`.

**Expected:**
- App Store code redemption sheet appears.
- Uses `SKPaymentQueue.default().presentCodeRedemptionSheet()`.
- No crash on macOS (silently does nothing due to `#if canImport(UIKit)`).

**Pass:** Sheet presents on iOS, no-op on macOS.

---

## 11. Trial Eligibility

### 11.1 Check Trial Eligibility

**Precondition:** RevenueCat configured.

**Steps:**
1. Call `await SubscriptionStore.shared.checkTrialEligibility(for: "com.app.product_id")`.

**Expected:**
- Returns `.eligible` / `.ineligible` / `.noOfferAvailable` / `.unknown` accurately.

**Pass:** Eligibility result is accurate.

---

### 11.2 Trial Eligibility Without Configuration

**Precondition:** RevenueCat NOT configured.

**Steps:**
1. Call `await SubscriptionStore.shared.checkTrialEligibility(for: "com.app.product_id")`.

**Expected:**
- Returns `.unknown`.
- Console: `"Purchases is not configured yet. Skipping checkTrialEligibility."`.

**Pass:** Graceful fallback, no crash.

---

## 12. Critical Operation Verification

### 12.1 Verify Subscription — Server-First

**Precondition:** Subscription active.

**Steps:**
1. Call `await SubscriptionStore.shared.verifySubscriptionForCriticalOperation()`.

**Expected:**
- ALWAYS checks with RevenueCat server (not just cache).
- Returns `true` if server confirms active entitlement.
- Cache is updated after verification.
- Console: `"Subscription verified for critical operation"`.

**Pass:** Server verification is authoritative.

---

### 12.2 Verification Fails — No Active Subscription

**Precondition:** No active subscription.

**Steps:**
1. Call `await SubscriptionStore.shared.verifySubscriptionForCriticalOperation()`.

**Expected:**
- Returns `false`.
- Console: `"No active subscription found for critical operation"`.

**Pass:** Correctly reports no subscription.

---

### 12.3 Verification Without Configuration

**Precondition:** RevenueCat NOT configured.

**Steps:**
1. Call `await SubscriptionStore.shared.verifySubscriptionForCriticalOperation()`.

**Expected:**
- Returns `false`.
- Console: `"Purchases is not configured yet. Skipping subscription verification."`.

**Pass:** Graceful no-op, no crash.

---

## 13. Error Mapping

### 13.1 SubscriptionError Type Safety

**Steps:**
1. Verify that `SubscriptionError` uses specific enum cases — no String parameters except `.unknown`:
   - `.networkError`
   - `.purchaseCancelled`
   - `.purchaseNotAllowed`
   - `.storeProblem`
   - `.productNotAvailable`
   - `.receiptInUse`
   - `.paymentPending`
   - `.insufficientPermissions`
   - `.apiKeyInvalid`
   - `.apiKeyMissing`
   - `.notConfigured`
   - `.unknown(String)`

**Pass:** All error types are type-safe enum cases with `Equatable` conformance.

---

### 13.2 All Error Paths Mapped

**Steps:**
1. Verify error mapping works for:
   - RevenueCat `ErrorCode` cases
   - `StoreKitError` cases
   - `SKErrorDomain` NSError cases
   - Unknown errors → `.unknown(message)`

**Pass:** All error types mapped correctly with user-friendly messages.

---

## 14. Edge Cases

### 14.1 Multiple Rapid Purchase Attempts

**Steps:**
1. Tap purchase button rapidly 5 times.

**Expected:**
- Only one purchase flow initiated (loading state prevents duplicates).
- No crash, no duplicate charges.

**Pass:** Deduplication works.

---

### 14.2 App Background During Purchase

**Steps:**
1. Start a purchase.
2. Background the app immediately.
3. Wait 30 seconds.
4. Return to app.

**Expected:**
- Purchase completes or fails gracefully.
- `isLoading` returns to `false`.

**Pass:** Background/foreground handles correctly.

---

### 14.3 Offline Launch — Cache Restore

**Precondition:** Airplane mode ON. Previously subscribed.

**Steps:**
1. Launch app with airplane mode.

**Expected:**
- `isSubscribed` restored from Keychain cache.
- `hasVerifiedWithServer == false`.
- `offerings == nil`.
- Console: `"Restored subscribed status from offline cache"`.
- No crash.

**Pass:** Offline state is usable from cache.

---

### 14.4 Offerings Fetch Retry

**Precondition:** Network briefly unavailable then restored.

**Steps:**
1. Enable airplane mode, launch app (offerings fetch fails).
2. Disable airplane mode.
3. Wait for retry.

**Expected:**
- First fetch fails with error log: `"Offerings fetch failed: ..."`.
- After delay, retry succeeds.
- Console: `"Offerings fetch retry succeeded"`.

**Pass:** Retry mechanism works.

---

### 14.5 CustomerInfo Stream Updates

**Precondition:** Store configured. Purchase completed.

**Steps:**
1. Change subscription on another device or RevenueCat dashboard.
2. Wait for stream to deliver updated CustomerInfo.

**Expected:**
- `isSubscribed` updates automatically.
- `onStatusChanged` callback fires.
- Console: `"New CustomerInfo received from stream"`.

**Pass:** Real-time updates work.

---

### 14.6 Reset Clears RevenueCat Cache

**Precondition:** Configured and subscribed.

**Steps:**
1. Call `SubscriptionStore.shared.reset()`.
2. Check that RevenueCat SDK customer info cache is invalidated.

**Expected:**
- `Purchases.shared.invalidateCustomerInfoCache()` is called.
- Next `configure()` fetches fresh data from server.
- Console: `"SubscriptionStore reset"`.

**Pass:** RevenueCat SDK cache is cleared alongside local cache.

---

### 14.7 Observer Handles Unconfigured Purchases

**Precondition:** `CustomerInfoObserver` started but Purchases becomes unconfigured.

**Steps:**
1. Configure store.
2. Call `reset()`.
3. Observer stream may still emit.

**Expected:**
- Observer logs: `"Purchases is not configured. CustomerInfoObserver will not start."`.
- No crash from accessing unconfigured `Purchases.shared`.

**Pass:** Observer handles unconfigured state gracefully.

---

### 14.8 Offerings Refresh After Purchase

**Precondition:** Valid offerings loaded. Subscription not active.

**Steps:**
1. Complete a purchase via `SubscriptionStore.shared.purchase(plan)`.
2. Check `SubscriptionStore.shared.offerings` after purchase completes.
3. Check `SubscriptionStore.shared.plans` after purchase completes.

**Expected:**
- `offerings` is refreshed (non-nil) after purchase.
- `plans` array is populated after purchase.
- `isLoading` transitions `true → false` correctly.
- No infinite loading state.

**Pass:** Offerings are refreshed as part of the purchase flow.

---

### 14.9 Offerings Refresh After Restore

**Precondition:** Previously subscribed. Fresh install.

**Steps:**
1. Call `await SubscriptionStore.shared.restorePurchases()`.
2. Check `offerings` and `plans` after restore completes.

**Expected:**
- `offerings` is refreshed after restore.
- `plans` array is populated.
- `isLoading` transitions `true → false` correctly.

**Pass:** Restore triggers full status and offerings refresh.

---

### 14.10 Reset Cancels In-Flight Refresh

**Precondition:** Store configured. Slow network.

**Steps:**
1. Configure store (triggers background refresh).
2. Immediately call `reset()` before refresh completes.
3. Configure again.

**Expected:**
- In-flight refresh task is cancelled.
- No stale data applied from the first configure's refresh.
- Second configure starts fresh.
- Console: `"SubscriptionStore reset"` then `"RevenueCat configured successfully"`.

**Pass:** Reset properly cancels in-flight operations.

---

### 14.11 Concurrent Fetch Deduplication

**Precondition:** Store configured.

**Steps:**
1. Call `fetchOfferings()` from two places simultaneously.
2. Observe network traffic or console logs.

**Expected:**
- Only one actual network request to RevenueCat.
- Both callers receive the same result.
- Console: `"Offerings fetched successfully"` appears once (not twice).

**Pass:** Concurrent fetch requests are deduplicated via OfferingsRepository.

---

## 15. Keychain Isolation

### 15.1 Keychain Service Identifier

**Precondition:** App uses shared keychain group.

**Steps:**
1. Subscribe to a plan (creates keychain entry).
2. Inspect keychain entry attributes.

**Expected:**
- Entry includes `kSecAttrService = "SwiftRevenueCat"`.
- Entry is isolated from other apps in the shared keychain group.
- Other apps using the same account name do not collide.

**Pass:** Keychain entries properly scoped with service identifier.

---

## 16. Concurrency Safety

### 16.1 onStatusChanged Callback Thread Safety

**Precondition:** Subscription active. Callback registered.

**Steps:**
1. Register a callback: `SubscriptionStore.shared.onStatusChanged = { subscribed, info in ... }`.
2. Trigger a status change (purchase, restore, etc.).
3. Verify callback is invoked without threading issues.

**Expected:**
- Callback is `@Sendable` — no compiler warnings.
- No data races reported by Thread Sanitizer.
- Callback receives current `Bool` and `CustomerInfo?`.

**Pass:** Callback is thread-safe across actor boundaries.
