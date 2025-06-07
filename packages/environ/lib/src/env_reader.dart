import 'dart:convert';

class EnvReader {
  static const _singleQuote = "'";
  static final _exportRegex = RegExp(r'''^ *export ?''');
  static final _commentRegex = RegExp(r'''#[^'"]*$''');
  static final _quoteRegex = RegExp(r'''^(["'])(.*?[^\\])\1''');
  static final _variableRegex = RegExp(
    r'''(\\)?(\$)(\{)?([a-zA-Z_][\w]*)+(\})?''',
  );

  const EnvReader();

  /// Converts environment variable lines into a key-value map.
  Map<String, String> processLines(
    Iterable<String> lines,
    Map<String, String> mergeWith,
  ) {
    final envMap = <String, String>{};
    envMap.addAll(mergeWith);
    for (final line in lines) {
      final entry = processSingleLine(line, envMap);
      if (entry.isNotEmpty) {
        envMap[entry.keys.first] = entry.values.first;
      }
    }
    return envMap;
  }

  /// Parses a single line into a key-value pair.
  Map<String, String> processSingleLine(
    String line,
    Map<String, String> envMap,
  ) {
    final cleanLine = removeComments(line);
    if (!cleanLine.contains('=')) return {};

    final parts = cleanLine.split('=');
    final key = stripExport(parts[0]).trim();
    if (key.isEmpty) return {};

    final value = parts[1].trim();
    final quoteType = getQuoteType(value);
    var processedValue = stripQuotes(value);

    if (quoteType == _singleQuote) {
      processedValue = processedValue.replaceAll("\\'", "'");
    } else if (quoteType == '"') {
      processedValue = processedValue
          .replaceAll('\\"', '"')
          .replaceAll('\\n', '\n');
    }

    final finalValue = substituteVars(
      processedValue,
      envMap,
    ).replaceAll("\\\$", "\$");
    return {key: finalValue};
  }

  /// Substitutes variables in the value with their actual values.
  String substituteVars(String value, Map<String, String> envMap) {
    return value.replaceAllMapped(_variableRegex, (match) {
      if (match.group(1) == "\\") {
        return match.group(0)!;
      }
      final varName = match.group(4)!;
      return envMap.containsKey(varName) && envMap[varName] != null
          ? envMap[varName]!
          : '';
    });
  }

  /// Identifies the type of quotes used in a value.
  String getQuoteType(String value) {
    final match = _quoteRegex.firstMatch(value);
    return match != null ? match.group(1)! : '';
  }

  /// Removes quotes from a value.
  String stripQuotes(String value) {
    final match = _quoteRegex.firstMatch(value);
    return match != null
        ? match.group(2)!
        : removeComments(value, keepQuotes: true).trim();
  }

  /// Removes comments from a line.
  String removeComments(String line, {bool keepQuotes = false}) {
    return line
        .replaceAll(keepQuotes ? _commentRegex : _commentRegex, '')
        .trim();
  }

  /// Removes the 'export' keyword from a line.
  String stripExport(String line) {
    return line.replaceAll(_exportRegex, '').trim();
  }

  /// Get a string value from environment variables
  String getString(String key, {String defaultValue = ''}) {
    return key;
  }

  /// Get an integer value from environment variables
  int getInt(String key, {int defaultValue = 0}) {
    try {
      return int.parse(key);
    } catch (e) {
      return defaultValue;
    }
  }

  /// Get a double value from environment variables
  double getDouble(String key, {double defaultValue = 0.0}) {
    try {
      return double.parse(key);
    } catch (e) {
      return defaultValue;
    }
  }

  /// Get a boolean value from environment variables
  bool getBool(String key, {bool defaultValue = false}) {
    final value = key.toLowerCase();
    if (value == 'true' || value == '1' || value == 'yes') {
      return true;
    } else if (value == 'false' || value == '0' || value == 'no') {
      return false;
    }
    return defaultValue;
  }

  /// Get a list of strings from environment variables
  List<String> getStringList(
    String key, {
    List<String> defaultValue = const [],
  }) {
    try {
      return key.split(',').map((e) => e.trim()).toList();
    } catch (e) {
      return defaultValue;
    }
  }

  /// Get a JSON object from environment variables
  Map<String, dynamic> getJson(
    String key, {
    Map<String, dynamic> defaultValue = const {},
  }) {
    try {
      return json.decode(key) as Map<String, dynamic>;
    } catch (e) {
      return defaultValue;
    }
  }
}
