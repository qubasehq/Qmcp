import 'dart:io';
import 'package:logging/logging.dart';

Future<String> getDefaultPath([String? additionalPath]) async {
  final List<String> defaultPaths = [];

  if (Platform.isWindows) {
    defaultPaths.addAll([
      'C:\\Windows\\System32',
      'C:\\Windows',
      'C:\\Windows\\System32\\Wbem',
      'C:\\Windows\\System32\\WindowsPowerShell\\v1.0',
    ]);
  } else if (Platform.isMacOS) {
    defaultPaths.addAll([
      '/opt/homebrew/bin',
      '/usr/local/bin',
      '/usr/bin',
      '/bin',
      '/usr/sbin',
      '/sbin',
    ]);
  } else {
    defaultPaths.addAll([
      '/usr/local/bin',
      '/usr/bin',
      '/bin',
      '/usr/sbin',
      '/sbin',
    ]);
  }

  final String pathSeparator = Platform.isWindows ? ';' : ':';
  final String systemPath = Platform.environment['PATH'] ?? '';

  // Combine default paths, system PATH, and additional paths
  final List<String> allPaths = [
    ...defaultPaths,
    ...systemPath.split(pathSeparator),
  ];

  // If additional paths are provided, add them to the list
  if (additionalPath != null && additionalPath.isNotEmpty) {
    allPaths.addAll(additionalPath.split(pathSeparator));
  }

  // Remove empty paths and deduplicate
  return allPaths.where((path) => path.isNotEmpty).toSet().join(pathSeparator);
}

Future<bool> isCommandAvailable(String command) async {
  try {
    final String whichCommand = Platform.isWindows ? 'where' : 'which';
    final Map<String, String> env = Map.of(Platform.environment);
    env['PATH'] = await getDefaultPath();

    final result = await Process.run(
      whichCommand,
      [command],
      environment: env,
      includeParentEnvironment: true,
    );

    return result.exitCode == 0;
  } catch (e) {
    return false;
  }
}

Map<String, String>? _cachedEnv;

Future<Map<String, String>> _loadShellEnv() async {
  if (!Platform.isMacOS && !Platform.isLinux) {
    return {};
  }

  try {
    // Get the user's default shell
    final String shell = Platform.environment['SHELL'] ?? '/bin/bash';
    final String homeDir = Platform.environment['HOME'] ?? '';
    final String user = Platform.environment['USER'] ?? '';

    // Create a temporary script to load environment variables
    final tempDir = await Directory.systemTemp.createTemp('env_loader');
    final scriptFile = File('${tempDir.path}/load_env.sh');

    // Write the environment loading script
    await scriptFile.writeAsString('''
#!$shell
# Set basic environment
export HOME="$homeDir"
export USER="$user"
export SHELL="$shell"
export TERM="xterm-256color"
export LANG="en_US.UTF-8"
export ENV_PREPARED=1

# Load system-level configuration
if [ -f /etc/profile ]; then
  . /etc/profile
fi

# Load configuration based on the shell type
if [[ "$shell" == *"/bash" ]]; then
  # Bash shell
  if [ -f "\$HOME/.bash_profile" ]; then
    . "\$HOME/.bash_profile"
  elif [ -f "\$HOME/.bash_login" ]; then
    . "\$HOME/.bash_login"
  elif [ -f "\$HOME/.profile" ]; then
    . "\$HOME/.profile"
  fi
elif [[ "$shell" == *"/zsh" ]]; then
  # Zsh shell
  if [ -f "\$HOME/.zprofile" ]; then
    . "\$HOME/.zprofile"
  fi
  if [ -f "\$HOME/.zshrc" ]; then
    . "\$HOME/.zshrc"
  fi
  
  # Attempt to load common Python version managers
  # pyenv
  if [ -d "\$HOME/.pyenv" ]; then
    export PYENV_ROOT="\$HOME/.pyenv"
    export PATH="\$PYENV_ROOT/bin:\$PATH"
    eval "\$(pyenv init --path 2>/dev/null || true)"
    eval "\$(pyenv init - 2>/dev/null || true)"
  fi
  
  # conda/miniconda
  for conda_path in "\$HOME/miniconda3" "\$HOME/anaconda3" "\$HOME/.conda"; do
    if [ -f "\$conda_path/etc/profile.d/conda.sh" ]; then
      . "\$conda_path/etc/profile.d/conda.sh"
      break
    fi
  done
fi

# Output all environment variables
env
''');

    // Set script permissions
    await Process.run('chmod', ['+x', scriptFile.path]);

    // Execute the script to get environment variables
    final result = await Process.run(shell, [
      '-l', // Run in login mode to ensure all configuration files are loaded
      scriptFile.path
    ], environment: {
      'HOME': homeDir,
      'USER': user,
      'SHELL': shell,
      'TERM': 'xterm-256color',
      'PATH':
          '/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin',
    });

    // Clean up temporary files
    await tempDir.delete(recursive: true);

    if (result.exitCode != 0) {
      Logger.root.warning('Failed to load shell environment: ${result.stderr}');
      return {};
    }

    // Parse environment variables
    final Map<String, String> env = {};
    final lines = result.stdout.toString().split('\n');
    for (final line in lines) {
      final parts = line.split('=');
      if (parts.length >= 2) {
        final key = parts[0];
        final value = parts.sublist(1).join('=');
        env[key] = value;
      }
    }

    Logger.root.info('Loaded shell environment: $env');

    return env;
  } catch (e) {
    Logger.root.severe('Error loading shell environment: $e');
    return {};
  }
}

Future<Map<String, String>> getDefaultEnv() async {
  // If the environment variables are already loaded, return the cached version
  if (_cachedEnv != null) {
    return Map.of(_cachedEnv!);
  }
  final Map<String, String> env = Map.of(Platform.environment);
  if (Platform.isWindows) {
    env['PYTHONIOENCODING'] = 'utf-8';
    env['PYTHONLEGACYWINDOWSSTDIO'] = 'utf-8';
  } else if (Platform.isMacOS || Platform.isLinux) {
    // Mark environment variables as prepared
    env['ENV_PREPARED'] = '1';

    final Map<String, String> shellEnv = await _loadShellEnv();
    if (shellEnv.containsKey('PATH')) {
      final String newPath = shellEnv['PATH']!;
      Logger.root.info('Loaded PATH from shell: $newPath');
      env['PATH'] = newPath;
    } else {
      final String defaultPath = await getDefaultPath();
      Logger.root.info('Using default PATH: $defaultPath');
      env['PATH'] = defaultPath;
    }

    // Merge other environment variables
    shellEnv.forEach((key, value) {
      if (key != 'PATH' && !env.containsKey(key)) {
        env[key] = value;
      }
    });
  }
  Logger.root.info('Default environment: $env');

  // Cache the environment variables
  _cachedEnv = Map.of(env);

  return env;
}

Future<Process> startProcess(
  String command,
  List<String> args,
  Map<String, String> environment,
) async {
  final Map<String, String> env = await getDefaultEnv();
  env.addAll(environment); // Add user-provided environment variables

  return Process.start(
    command,
    args,
    environment: env,
    includeParentEnvironment: true,
    // Windows needs this to run properly; keep other platforms as default (false).
    runInShell: Platform.isWindows,
  );
}

/// Clear the environment variable cache to force reloading next time
void clearEnvironmentCache() {
  _cachedEnv = null;
  Logger.root.info('Environment cache cleared, will reload next time');
}
