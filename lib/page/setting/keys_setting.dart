import 'dart:convert';

import 'package:qubase_mcp/components/widgets/base.dart';
import 'package:qubase_mcp/llm/llm_factory.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../provider/settings_provider.dart';
import '../../provider/provider_manager.dart';
import 'package:qubase_mcp/generated/app_localizations.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:qubase_mcp/page/layout/widgets/llm_icon.dart';

class KeysSettings extends StatefulWidget {
  const KeysSettings({super.key});

  @override
  State<KeysSettings> createState() => _KeysSettingsState();
}

class _KeysSettingsState extends State<KeysSettings> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  int _selectedProvider = 0;
  bool _hasChanges = false;

  final List<KeySettingControllers> _controllers = [];

  
  final List<KeysSetting> _llmApiConfigs = [];

  @override
  void initState() {
    super.initState();

    _loadSettings();

    // Initialize controllers
    for (var config in _llmApiConfigs) {
      _controllers.add(KeySettingControllers(
        keyController: TextEditingController(),
        endpointController: TextEditingController(),
        apiStyleController: config.apiStyle ?? 'openai',
        providerNameController:
            TextEditingController(text: config.providerName ?? ''),
        providerId: config.providerId ?? '',
        custom: config.custom,
        models: config.models ?? [],
        enabledModels: config.enabledModels ?? [],
        icon: config.icon ?? '',
      ));
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final apiSettings = await settings.loadSettings();
    print("apiSettings: ${jsonEncode(apiSettings)}");

    // Clear existing list
    setState(() {
      _llmApiConfigs.clear();
      _controllers.clear();
    });

    // Add all loaded settings
    for (var apiSetting in apiSettings) {
      setState(() {
        _llmApiConfigs.add(apiSetting);
        // 为每个配置添加一个控制器
        _controllers.add(KeySettingControllers(
          keyController: TextEditingController(text: apiSetting.apiKey),
          endpointController:
              TextEditingController(text: apiSetting.apiEndpoint),
          apiStyleController: apiSetting.apiStyle ?? 'openai',
          providerNameController:
              TextEditingController(text: apiSetting.providerName ?? ''),
          providerId: apiSetting.providerId ?? '',
          custom: apiSetting.custom,
          models: apiSetting.models ?? [],
          enabledModels: apiSetting.enabledModels ?? [],
          icon: apiSetting.icon ?? '',
        ));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Form(
            key: _formKey,
            onChanged: () {
              if (!_hasChanges) {
                setState(() {
                  _hasChanges = true;
                });
              }
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 左侧提供商列表
                SizedBox(
                  width: 180, // 固定左侧宽度为180像素
                  child: Card(
                    elevation: 0,
                    color: Theme.of(context).colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color:
                            Theme.of(context).colorScheme.outline.withAlpha(26),
                      ),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            itemExtent: 48.0,
                            itemCount: _llmApiConfigs.length,
                            itemBuilder: (context, index) {
                              final config = _llmApiConfigs[index];
                              return _buildProviderListTile(index, config);
                            },
                          ),
                        ),
                        Divider(
                          color: Theme.of(context)
                              .colorScheme
                              .outline
                              .withAlpha(26),
                          height: 1,
                        ),
                        // 添加自定义提供商按钮
                        SizedBox(
                          height: 40,
                          child: ListTile(
                            dense: true,
                            title: Row(
                              children: [
                                Icon(
                                  CupertinoIcons.add_circled,
                                  size: 18,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  l10n.addServer,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                            onTap: () {
                              _showAddProviderDialog();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // 右侧配置表单
                Expanded(
                  flex: 1, // 右侧占据剩余空间
                  child: Column(
                    children: [
                      Expanded(
                        child: Card(
                          elevation: 0,
                          margin: EdgeInsets.zero,
                          color: Theme.of(context).colorScheme.surface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: Theme.of(context)
                                  .colorScheme
                                  .outline
                                  .withAlpha(26),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: _buildProviderConfigForm(_selectedProvider),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // 保存按钮
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveSettings,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _hasChanges
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.surfaceContainerHighest,
                            foregroundColor: _hasChanges
                                ? Theme.of(context).colorScheme.onPrimary
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: _hasChanges ? 0 : 0,
                            padding: EdgeInsets.zero,
                          ),
                          child: _isLoading
                              ? const CupertinoActivityIndicator()
                              : CText(text: l10n.saveSettings),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showAddProviderDialog() async {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController providerController =
            TextEditingController();
        return AlertDialog(
          title: Text('Add Provider'),
          content: TextField(
            controller: providerController,
            decoration: InputDecoration(
              hintText: 'Enter provider name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final providerName = providerController.text.trim();
                if (providerName.isNotEmpty) {
                  setState(() {
                    String providerId = Uuid().v4();
                    _llmApiConfigs.add(KeysSetting(
                      providerName: providerName,
                      providerId: providerId,
                      apiKey: '',
                      apiEndpoint: '',
                      apiStyle: 'openai',
                      custom: true,
                      models: [],
                      enabledModels: [],
                      icon: '',
                    ));
                    _controllers.add(KeySettingControllers(
                      keyController: TextEditingController(),
                      endpointController: TextEditingController(),
                      providerNameController:
                          TextEditingController(text: providerName),
                      providerId: providerId,
                      custom: true,
                      models: [],
                      enabledModels: [],
                      icon: '',
                    ));
                  });
                }
                Navigator.pop(context);
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAddModelDialog() async {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController modelController = TextEditingController();
        return AlertDialog(
          title: Text('Add Model'),
          content: TextField(
            controller: modelController,
            decoration: InputDecoration(
              hintText: 'Model Name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final modelName = modelController.text.trim();
                if (modelName.isNotEmpty) {
                  setState(() {
                    if (_controllers.isNotEmpty) {
                      // 将模型添加到当前选中的提供商
                      final controller = _controllers[_selectedProvider];
                      if (!controller.models.contains(modelName)) {
                        controller.models.add(modelName);
                        controller.enabledModels.add(modelName);
                        _hasChanges = true;
                      }
                    }
                  });
                }
                Navigator.pop(context);
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProviderListTile(int index, KeysSetting config) {
    final isSelected = _selectedProvider == index;

    return ListTile(
      dense: true,
      visualDensity: VisualDensity.compact,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 0),
      selected: isSelected,
      selectedTileColor:
          Theme.of(context).colorScheme.primary.withOpacity(0.12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      leading: LlmIcon(icon: config.icon),
      title: Text(
        config.providerName ?? '',
        style: TextStyle(
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurface,
        ),
      ),
      onTap: () {
        setState(() {
          _selectedProvider = index;
        });
      },
    );
  }

  Widget _buildProviderConfigForm(int index) {
    // 安全检查：确保索引有效且数组不为空
    if (_llmApiConfigs.isEmpty ||
        _controllers.isEmpty ||
        index < 0 ||
        index >= _llmApiConfigs.length ||
        index >= _controllers.length) {
      // 返回一个空白界面或提示信息
      return Center(
        child: Text(
          'No API configuration available',
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      );
    }

    final config = _llmApiConfigs[index];
    final controllers = _controllers[index];
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 提供商标题
          Row(
            children: [
              LlmIcon(icon: config.icon),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  config.providerName ?? '',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              if (config.custom)
                IconButton(
                  icon: const Icon(CupertinoIcons.delete, size: 18),
                  color: Colors.red,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    setState(() {
                      _llmApiConfigs.removeAt(_selectedProvider);
                      _controllers.removeAt(_selectedProvider);
                      if (_selectedProvider >= _llmApiConfigs.length) {
                        _selectedProvider = _llmApiConfigs.length - 1;
                      }
                      _hasChanges = true;
                    });
                  },
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Provider Name
          Text(
            'Provider Name',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          TextFormField(
            controller: controllers.providerNameController,
            decoration: InputDecoration(
              hintText: 'Enter provider name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withAlpha(51),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withAlpha(51),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              isDense: true,
            ),
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter provider name';
              }
              if (value.length > 50) {
                return 'Name cannot exceed 50 characters';
              }
              return null;
            },
            maxLength: 50,
            buildCounter: (context,
                {required currentLength, required isFocused, maxLength}) {
              return null; // 隐藏字符计数器
            },
          ),
          const SizedBox(height: 12),

          // API 风格
          if (config.custom) ...[
            Text(
              'API 风格',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            DropdownButtonFormField<String>(
              value: controllers.apiStyleController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.outline.withAlpha(51),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.outline.withAlpha(51),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                isDense: true,
              ),
              isDense: true,
              icon: Icon(
                CupertinoIcons.chevron_down,
                size: 16,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              items: [
                DropdownMenuItem(
                  value: 'openai',
                  child: Text(
                    'OpenAI',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                DropdownMenuItem(
                  value: 'claude',
                  child: Text(
                    'Claude',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    controllers.apiStyleController = value;
                  });
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select API style';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
          ],

          // API URL
          Text(
            'API URL',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          TextFormField(
            controller: controllers.endpointController,
            decoration: InputDecoration(
              hintText: l10n.enterApiEndpoint,
              hintStyle: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withAlpha(102),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withAlpha(51),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withAlpha(51),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              isDense: true,
            ),
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),

          // API Key
          Text(
            'API Key',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          TextFormField(
            controller: controllers.keyController,
            obscureText: true,
            decoration: InputDecoration(
              hintText: l10n.enterApiKey(config.providerName ?? ''),
              hintStyle: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withAlpha(102),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withAlpha(51),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withAlpha(51),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              isDense: true,
              suffixIcon: IconButton(
                icon: const Icon(CupertinoIcons.eye_slash, size: 16),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  // 切换密码可见性
                },
              ),
            ),
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            validator: (value) {
              if (value != null && value.isNotEmpty && value.length < 10) {
                return l10n.apiKeyValidation;
              }
              return null;
            },
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Text(
                l10n.modelList,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Spacer(),
              // add custom model
              OutlinedButton.icon(
                icon: const Icon(Icons.add_circle_outline, size: 14),
                label: Text(
                  "Add",
                  style: const TextStyle(fontSize: 12),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.primary,
                  side:
                      BorderSide(color: Theme.of(context).colorScheme.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                  minimumSize: const Size(0, 30),
                ),
                onPressed: () {
                  _showAddModelDialog();
                },
              ),
              const SizedBox(width: 8),

              // fetch models
              OutlinedButton.icon(
                icon: const Icon(CupertinoIcons.checkmark_seal, size: 14),
                label: Text(
                  "Fetch",
                  style: const TextStyle(fontSize: 12),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.primary,
                  side:
                      BorderSide(color: Theme.of(context).colorScheme.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                  minimumSize: const Size(0, 30),
                ),
                onPressed: () async {
                  var provider =
                      LLMFactoryHelper.providerMap[controllers.providerId];

                  provider ??=
                      LLMProvider.values.byName(controllers.apiStyleController);

                  final llm = LLMFactory.create(provider,
                      apiKey: controllers.keyController.text,
                      baseUrl: controllers.endpointController.text);

                  final models = await llm.models();
                  setState(() {
                    controllers.models.addAll(models);
                    if (controllers.enabledModels.isEmpty) {
                      controllers.enabledModels.addAll(models);
                    } else {
                      // 确保enabledModels按照models中的顺序排序
                      controllers.enabledModels.sort((a, b) =>
                          controllers.models.indexOf(a) -
                          controllers.models.indexOf(b));
                    }
                    // 设置变更标志
                    _hasChanges = true;
                  });
                },
              ),
            ],
          ),

          // 模型列表

          const SizedBox(height: 12),
          // 模型列表，直接显示所有模型
          ...controllers.models.map((model) => _buildModelListItem(
              model, controllers.enabledModels.contains(model))),
          const SizedBox(height: 8), // 底部留一些空间
        ],
      ),
    );
  }

  Widget _buildModelListItem(String modelName, bool isEnabled) {
    if (_selectedProvider < 0 || _selectedProvider >= _controllers.length) {
      return const SizedBox(); // 防止索引错误
    }

    final controllers = _controllers[_selectedProvider];
    // 检查模型是否在启用列表中
    bool modelEnabled = controllers.enabledModels.contains(modelName);

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withAlpha(26),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              modelName,
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          // delete model
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            margin: const EdgeInsets.only(right: 12),
            child: IconButton(
              icon: const Icon(CupertinoIcons.delete, size: 14),
              color: Colors.red,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () {
                setState(() {
                  // 从两个列表中删除模型
                  controllers.models.remove(modelName);
                  controllers.enabledModels.remove(modelName);
                  // 设置变更标志
                  _hasChanges = true;
                });
              },
            ),
          ),
          SizedBox(
            width: 50,
            child: FlutterSwitch(
              width: 50.0,
              height: 24.0,
              value: modelEnabled,
              onToggle: (val) {
                setState(() {
                  // 更新模型启用状态
                  if (val) {
                    // 启用模型
                    if (!controllers.enabledModels.contains(modelName)) {
                      controllers.enabledModels.add(modelName);
                      // 确保enabledModels按照models中的顺序排序
                      controllers.enabledModels.sort((a, b) =>
                          controllers.models.indexOf(a) -
                          controllers.models.indexOf(b));
                    }
                  } else {
                    // 禁用模型
                    controllers.enabledModels.remove(modelName);
                  }
                  // 设置变更标志
                  _hasChanges = true;
                });
              },
              toggleSize: 18.0,
              activeColor: Colors.blue,
              inactiveColor: Colors.grey[300]!,
              activeToggleColor: Colors.white,
              inactiveToggleColor: Colors.grey[500]!,
              showOnOff: true,
              activeText: "ON",
              inactiveText: "OFF",
              valueFontSize: 9.0,
              activeTextColor: Colors.white,
              inactiveTextColor: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveSettings() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final settings = ProviderManager.settingsProvider;

        await settings.updateApiSettings(
            apiSettings: _controllers
                .map((e) => KeysSetting(
                      providerId: e.providerId,
                      providerName: e.providerNameController.text,
                      apiKey: e.keyController.text,
                      apiEndpoint: e.endpointController.text,
                      apiStyle: e.apiStyleController,
                      custom: e.custom,
                      models: e.models,
                      enabledModels: e.enabledModels,
                      icon: e.icon,
                    ))
                .toList());

        // 重置变更状态
        if (mounted) {
          setState(() {
            _hasChanges = false;
          });
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.saveSuccess),
              backgroundColor: Colors.green,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }
}

class KeySettingControllers {
  TextEditingController keyController;
  TextEditingController endpointController;
  String apiStyleController;
  TextEditingController providerNameController;
  List<String> models = [];
  List<String> enabledModels = [];
  String providerId;
  bool custom = false;
  String icon = '';
  KeySettingControllers({
    required this.keyController,
    required this.endpointController,
    this.apiStyleController = 'openai',
    required this.providerNameController,
    this.providerId = '',
    this.custom = false,
    this.icon = '',
    List<String>? models,
    List<String>? enabledModels,
  }) {
    this.models = models ?? [];
    this.enabledModels = enabledModels ?? [];
  }

  void dispose() {
    keyController.dispose();
    endpointController.dispose();
    providerNameController.dispose();
  }
}

