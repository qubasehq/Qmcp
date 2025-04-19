class ServerConfig {
  final String command;
  final List<String> args;
  final Map<String, String> env;
  final String author;

  const ServerConfig({
    required this.command,
    required this.args,
    this.env = const {},
    this.author = '',
  });

  // Create ServerConfig from JSON Map
  factory ServerConfig.fromJson(Map<String, dynamic> json) {
    return ServerConfig(
      command: json['command'] as String,
      args: (json['args'] as List<dynamic>).cast<String>(),
      env: (json['env'] as Map<String, dynamic>?)?.cast<String, String>() ??
          const {},
    );
  }

  // Convert ServerConfig to JSON Map
  Map<String, dynamic> toJson() {
    return {
      'command': command,
      'args': args,
      'env': env,
      'author': author,
    };
  }
}
