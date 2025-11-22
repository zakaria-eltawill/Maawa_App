import 'package:shared_preferences/shared_preferences.dart';

class AppCache {
  final SharedPreferences _prefs;

  AppCache(this._prefs);

  // Cache property filters
  Future<void> savePropertyFilters({
    String? city,
    String? propertyType,
    double? minPrice,
    double? maxPrice,
  }) async {
    if (city != null) {
      await _prefs.setString('filter_city', city);
    }
    if (propertyType != null) {
      await _prefs.setString('filter_property_type', propertyType);
    }
    if (minPrice != null) {
      await _prefs.setDouble('filter_min_price', minPrice);
    }
    if (maxPrice != null) {
      await _prefs.setDouble('filter_max_price', maxPrice);
    }
  }

  Future<Map<String, dynamic>> getPropertyFilters() async {
    return {
      'city': _prefs.getString('filter_city'),
      'property_type': _prefs.getString('filter_property_type'),
      'min_price': _prefs.getDouble('filter_min_price'),
      'max_price': _prefs.getDouble('filter_max_price'),
    };
  }

  Future<void> clearPropertyFilters() async {
    await _prefs.remove('filter_city');
    await _prefs.remove('filter_property_type');
    await _prefs.remove('filter_min_price');
    await _prefs.remove('filter_max_price');
  }
}

