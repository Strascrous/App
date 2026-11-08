import 'package:flutter/foundation.dart';

const String PROD_BASE_URL = 'http://localhost:3000';

final String BASE_URL =
    kDebugMode && !kIsWeb && defaultTargetPlatform == TargetPlatform.android
        ? 'http://10.0.2.2:3000'
        : 'http://localhost:3000';
