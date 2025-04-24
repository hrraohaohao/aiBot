class EnvConfig {
  // 从环境变量中获取API基础URL
  static String get apiBaseUrl {
    return const String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'https://api.example.com', // 默认生产环境URL
    );
  }

  // 环境名称
  static String get environmentName {
    return const String.fromEnvironment(
      'ENVIRONMENT_NAME',
      defaultValue: '生产环境',
    );
  }
  
  // 判断当前是否是生产环境
  static bool get isProduction {
    return environmentName == '生产环境';
  }
  
  // 判断当前是否是测试环境
  static bool get isTest {
    return environmentName == '测试环境';
  }
  
  // 判断当前是否是预发环境
  static bool get isStaging {
    return environmentName == '预发环境';
  }
} 