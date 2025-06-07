import 'package:environ/src/env_reader.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// A utility class for loading and accessing environment variables from a .env file.
///
/// Example usage:
/// ```dart
/// // First, load the .env file
/// await Environ.loadEnv();
///
/// // Then access variables
/// final apiKey = Environ.getString('API_KEY');
/// final port = Environ.getInt('PORT');
/// final isDebug = Environ.getBool('DEBUG');
/// ```
class Environ {
  static final EnvReader _reader = EnvReader();
  static Map<String, String>? _envVars;

  /// Loads the .env file from the project root, parses it using the Parser, and returns a Map<String, String> of environment variables.
  ///
  /// Example .env file content:
  /// ```
  /// API_KEY=your_secret_key
  /// PORT=8080
  /// DEBUG=true
  /// DATABASE_URL=postgres://user:pass@localhost:5432/db
  /// ```
  ///
  /// Example usage:
  /// ```dart
  /// await Environ.loadEnv(); // Uses default .env file
  /// // or
  /// await Environ.loadEnv(filePath: 'config/.env.production');
  /// ```
  static loadEnv({
    String filePath = '.env',
    Map<String, String> mergeWith = const {},
  }) async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      var envString = await rootBundle.loadString(filePath);
      if (envString.isEmpty) {
        throw Exception('The .env file is empty: $filePath');
      }
      final lines = envString.split('\n');
      _envVars = _reader.processLines(lines, mergeWith);
    } catch (e) {
      throw Exception('Error loading .env file: $e');
    }
  }

  /// Get a string value from environment variables.
  ///
  /// Example:
  /// ```dart
  /// // .env: API_KEY=abc123
  /// final apiKey = Environ.getString('API_KEY'); // Returns 'abc123'
  /// final missing = Environ.getString('MISSING', defaultValue: 'default'); // Returns 'default'
  /// ```
  static String getString(String key, {String defaultValue = ''}) {
    return _envVars?[key] ?? defaultValue;
  }

  /// Get an integer value from environment variables.
  ///
  /// Example:
  /// ```dart
  /// // .env: PORT=8080
  /// final port = Environ.getInt('PORT'); // Returns 8080
  /// final missing = Environ.getInt('MISSING', defaultValue: 3000); // Returns 3000
  /// ```
  static int getInt(String key, {int defaultValue = 0}) {
    final value = _envVars?[key];
    if (value == null) return defaultValue;
    return _reader.getInt(value, defaultValue: defaultValue);
  }

  /// Get a double value from environment variables.
  ///
  /// Example:
  /// ```dart
  /// // .env: PRICE=19.99
  /// final price = Environ.getDouble('PRICE'); // Returns 19.99
  /// final missing = Environ.getDouble('MISSING', defaultValue: 0.0); // Returns 0.0
  /// ```
  static double getDouble(String key, {double defaultValue = 0.0}) {
    final value = _envVars?[key];
    if (value == null) return defaultValue;
    return _reader.getDouble(value, defaultValue: defaultValue);
  }

  /// Get a boolean value from environment variables.
  ///
  /// Example:
  /// ```dart
  /// // .env: DEBUG=true
  /// final isDebug = Environ.getBool('DEBUG'); // Returns true
  /// final missing = Environ.getBool('MISSING', defaultValue: false); // Returns false
  /// ```
  static bool getBool(String key, {bool defaultValue = false}) {
    final value = _envVars?[key];
    if (value == null) return defaultValue;
    return _reader.getBool(value, defaultValue: defaultValue);
  }

  /// Get a list of strings from environment variables.
  ///
  /// Example:
  /// ```dart
  /// // .env: ALLOWED_ORIGINS=localhost,127.0.0.1,example.com
  /// final origins = Environ.getStringList('ALLOWED_ORIGINS');
  /// // Returns ['localhost', '127.0.0.1', 'example.com']
  ///
  /// final missing = Environ.getStringList('MISSING', defaultValue: ['default']);
  /// // Returns ['default']
  /// ```
  static List<String> getStringList(
    String key, {
    List<String> defaultValue = const [],
  }) {
    final value = _envVars?[key];
    if (value == null) return defaultValue;
    return _reader.getStringList(value, defaultValue: defaultValue);
  }

  /// Get a JSON object from environment variables.
  ///
  /// Example:
  /// ```dart
  /// // .env: CONFIG={"name":"app","version":"1.0.0","features":["auth","api"]}
  /// final config = Environ.getJson('CONFIG');
  /// // Returns {'name': 'app', 'version': '1.0.0', 'features': ['auth', 'api']}
  ///
  /// final missing = Environ.getJson('MISSING', defaultValue: {'default': true});
  /// // Returns {'default': true}
  /// ```
  static Map<String, dynamic> getJson(
    String key, {
    Map<String, dynamic> defaultValue = const {},
  }) {
    final value = _envVars?[key];
    if (value == null) return defaultValue;
    return _reader.getJson(value, defaultValue: defaultValue);
  }

  static env(String key) {
    return _envVars?[key];
  }
}
