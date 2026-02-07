import 'dart:io';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class RevenueCatService {
  static const String entitlementID = 'BukuKas Pro';

  static const String _apiKeyAndroid = 'goog_QXtjBAiXptTDVXQxDkFKCJnqrIW';
  static const String _apiKeyIOS = 'test_DwLaBEmnqppWwGPFWEabiVzOscX';
  // static const String _apiKeyDebug = 'test_DwLaBEmnqppWwGPFWEabiVzOscX';
  static const String _apiKeyDebug = 'goog_QXtjBAiXptTDVXQxDkFKCJnqrIW';

  static Future<void> initialize() async {
    await Purchases.setLogLevel(LogLevel.debug);

    PurchasesConfiguration configuration;
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      configuration = PurchasesConfiguration(_apiKeyDebug);
    } else {
      if (Platform.isAndroid) {
        configuration = PurchasesConfiguration(_apiKeyAndroid);
      } else if (Platform.isIOS) {
        configuration = PurchasesConfiguration(_apiKeyIOS);
      } else {
        return;
      }
    }

    await Purchases.configure(configuration);
  }

  /// Mengambil daftar paket (Bulanan, Tahunan, Lifetime)
  static Future<Offerings?> getOfferings() async {
    try {
      Offerings offerings = await Purchases.getOfferings();
      if (offerings.current != null &&
          offerings.current!.availablePackages.isNotEmpty) {
        return offerings;
      }
    } on PlatformException catch (e) {
      print("Error fetching offerings: $e");
    }
    return null;
  }

  /// Melakukan pembelian
  static Future<bool> makePurchase(Package package) async {
    try {
      final result = await Purchases.purchase(PurchaseParams.package(package));
      CustomerInfo customerInfo = result.customerInfo;
      return _checkEntitlement(customerInfo);
    } on PlatformException catch (e) {
      var errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
        print("Purchase Error: $e");
      }
      return false;
    }
  }

  /// Restore Purchase (Wajib ada untuk iOS/Google)
  static Future<bool> restorePurchases() async {
    try {
      CustomerInfo customerInfo = await Purchases.restorePurchases();
      return _checkEntitlement(customerInfo);
    } on PlatformException catch (e) {
      print("Restore Error: $e");
      return false;
    }
  }

  /// Cek status apakah user Premium
  static Future<bool> isUserPremium() async {
    try {
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      return _checkEntitlement(customerInfo);
    } catch (e) {
      return false;
    }
  }

  // Fungsi internal untuk cek entitlement aktif atau tidak
  static bool _checkEntitlement(CustomerInfo customerInfo) {
    return customerInfo.entitlements.all[entitlementID]?.isActive ?? false;
  }
}
