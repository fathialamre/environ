<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).
-->

# Environ

A Flutter package for managing environment variables with type-safe access. This package provides a simple and type-safe way to load and access environment variables from a `.env` file in your Flutter application.

## Features

- Load environment variables from a `.env` file
- Support for multiple environment files (e.g., `.env.prod`, `.env.dev`, `.env.staging`)
- Type-safe access to environment variables
- Support for various data types:
  - String
  - Integer
  - Double
  - Boolean
  - String List
  - JSON objects
- Default values for missing variables
- Flutter asset bundle integration

## Getting started

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  environ: ^0.0.1
```

## Usage

1. Create your environment files in your project root:

```env
# .env (default)
API_KEY=dev_key
PORT=8080
DEBUG=true
DATABASE_URL=postgres://user:pass@localhost:5432/db

# .env.prod
API_KEY=prod_key
PORT=80
DEBUG=false
DATABASE_URL=postgres://user:pass@prod-server:5432/db

# .env.staging
API_KEY=staging_key
PORT=8080
DEBUG=true
DATABASE_URL=postgres://user:pass@staging-server:5432/db
```

> **Important**: Make sure to add your `.env` files to `.gitignore` to prevent sensitive information from being committed to version control. You can do this by adding the following lines to your `.gitignore` file:
> ```
> .env
> .env.*
> ```

2. Add the environment files to your `pubspec.yaml`:

```yaml
flutter:
  assets:
    - .env
    - .env.prod
    - .env.staging
```

3. Load and use environment variables in your code:

```dart
import 'package:environ/environ.dart';

void main() async {
  // Load the default .env file
  await Environ.loadEnv(); // By default, loads .env
  
  // Or load a specific environment file
  await Environ.loadEnv(filePath: '.env.prod'); // Loads production environment
  await Environ.loadEnv(filePath: '.env.staging'); // Loads staging environment
  
  // Access variables with type safety
  final apiKey = Environ.getString('API_KEY');
  final port = Environ.getInt('PORT');
  final isDebug = Environ.getBool('DEBUG');
  
  // Use default values for missing variables
  final missing = Environ.getString('MISSING', defaultValue: 'default');
}
```

### Environment File Selection

The package will look for environment files in your Flutter assets. By default, it loads `.env`, but you can specify a different file:

```dart
// Load different environment files based on build configuration
void loadEnvironment() async {
  const environment = String.fromEnvironment('ENVIRONMENT', defaultValue: 'dev');
  
  switch (environment) {
    case 'prod':
      await Environ.loadEnv(filePath: '.env.prod');
      break;
    case 'staging':
      await Environ.loadEnv(filePath: '.env.staging');
      break;
    default:
      await Environ.loadEnv(); // Loads .env
  }
}
```

## Additional information

For more information about environment variables and best practices, check out:
- [Environment Variables](https://medium.com/chingu/an-introduction-to-environment-variables-and-how-to-use-them-f602f66d15fa)

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
