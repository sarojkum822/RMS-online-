import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

/// Unified App Preferences Cache
/// Pre-loaded at startup for INSTANT access (no async lag)
/// Only stores non-sensitive UI preferences - NO security data
class AppPrefsCache {
  static late SharedPreferences _prefs;
  
  // Keys
  static const _kTheme = 'theme_mode';
  static const _kLocale = 'app_locale';
  static const _kCurrency = 'currency_code';
  static const _kLastTab = 'last_dashboard_tab';
  static const _kOnboardingDone = 'onboarding_complete';
  static const _kLastSyncTime = 'last_sync_timestamp';
  static const _kCachedTotalRevenue = 'cached_total_revenue';
  static const _kCachedPropertyCount = 'cached_property_count';
  static const _kCachedTenantCount = 'cached_tenant_count';
  static const _kNotificationSound = 'notification_sound_enabled';
  static const _kPrintPaperSize = 'print_paper_size';
  
  /// Initialize cache - call ONCE in main.dart before runApp
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }
  
  // ============ THEME ============
  static String get theme => _prefs.getString(_kTheme) ?? 'light';
  static set theme(String value) => _prefs.setString(_kTheme, value);
  
  // ============ LOCALE ============
  static String get locale => _prefs.getString(_kLocale) ?? 'en-US';
  static set locale(String value) => _prefs.setString(_kLocale, value);
  
  // ============ CURRENCY ============
  static String get currencyCode => _prefs.getString(_kCurrency) ?? 'INR';
  static set currencyCode(String value) => _prefs.setString(_kCurrency, value);
  
  static String get currencySymbol {
    switch (currencyCode) {
      case 'USD': return '\$';
      case 'EUR': return '€';
      case 'GBP': return '£';
      case 'INR': 
      default: return '₹';
    }
  }
  
  // ============ LAST TAB ============
  static int get lastDashboardTab => _prefs.getInt(_kLastTab) ?? 0;
  static set lastDashboardTab(int value) => _prefs.setInt(_kLastTab, value);
  
  // ============ ONBOARDING ============
  static bool get onboardingComplete => _prefs.getBool(_kOnboardingDone) ?? false;
  static set onboardingComplete(bool value) => _prefs.setBool(_kOnboardingDone, value);
  
  // ============ CACHED STATS (for instant dashboard load) ============
  static double get cachedTotalRevenue => _prefs.getDouble(_kCachedTotalRevenue) ?? 0.0;
  static set cachedTotalRevenue(double value) => _prefs.setDouble(_kCachedTotalRevenue, value);
  
  static int get cachedPropertyCount => _prefs.getInt(_kCachedPropertyCount) ?? 0;
  static set cachedPropertyCount(int value) => _prefs.setInt(_kCachedPropertyCount, value);
  
  static int get cachedTenantCount => _prefs.getInt(_kCachedTenantCount) ?? 0;
  static set cachedTenantCount(int value) => _prefs.setInt(_kCachedTenantCount, value);
  
  // ============ LAST SYNC ============
  static DateTime? get lastSyncTime {
    final ms = _prefs.getInt(_kLastSyncTime);
    return ms != null ? DateTime.fromMillisecondsSinceEpoch(ms) : null;
  }
  static set lastSyncTime(DateTime? value) {
    if (value != null) {
      _prefs.setInt(_kLastSyncTime, value.millisecondsSinceEpoch);
    }
  }
  
  // ============ NOTIFICATION SETTINGS ============
  static bool get notificationSoundEnabled => _prefs.getBool(_kNotificationSound) ?? true;
  static set notificationSoundEnabled(bool value) => _prefs.setBool(_kNotificationSound, value);
  
  // ============ PRINT SETTINGS ============
  static String get printPaperSize => _prefs.getString(_kPrintPaperSize) ?? 'A4';
  static set printPaperSize(String value) => _prefs.setString(_kPrintPaperSize, value);
  
  // ============ UTILITY ============
  /// Update cached dashboard stats (call after Firestore fetch)
  static void updateDashboardCache({
    double? totalRevenue,
    int? propertyCount,
    int? tenantCount,
  }) {
    if (totalRevenue != null) cachedTotalRevenue = totalRevenue;
    if (propertyCount != null) cachedPropertyCount = propertyCount;
    if (tenantCount != null) cachedTenantCount = tenantCount;
    lastSyncTime = DateTime.now();
  }
  
  // ============ REPORT CACHE ============
  static String _getReportKey(String rangeLabel) => 'cached_report_${rangeLabel.replaceAll(' ', '_')}';
  
  static String? getCachedReport(String rangeLabel) => _prefs.getString(_getReportKey(rangeLabel));
  
  static Future<void> setCachedReport(String rangeLabel, String json) => _prefs.setString(_getReportKey(rangeLabel), json);


  /// Clear all cached data (for logout)
  static Future<void> clearAll() async {
    await _prefs.clear();
  }
  
  /// Clear only dashboard cache (keep preferences)
  static void clearDashboardCache() {
    _prefs.remove(_kCachedTotalRevenue);
    _prefs.remove(_kCachedPropertyCount);
    _prefs.remove(_kCachedTenantCount);
    _prefs.remove(_kLastSyncTime);
  }
}
