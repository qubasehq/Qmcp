import 'package:flutter/material.dart';
import 'package:qubase_mcp/llm/model.dart' as llm_model;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ChatModelProvider extends ChangeNotifier {
  static final ChatModelProvider _instance = ChatModelProvider._internal();
  factory ChatModelProvider() => _instance;
  ChatModelProvider._internal() {
    _loadSavedModel();
  }

  final List<llm_model.Model> _availableModels = [];

  List<llm_model.Model> get availableModels => _availableModels;

  List<llm_model.Model> getModels() {
    return _availableModels;
  }

  // Get the currently selected model
  static const String _modelKey = 'current_model';
  llm_model.Model _currentModel = llm_model.Model(
      name: "gpt-4o-mini",
      label: "GPT-4o-mini",
      providerId: "openai",
      icon: "openai",
      providerName: "OpenAI",
      apiStyle: "openai");

  llm_model.Model get currentModel => _currentModel;

  set currentModel(llm_model.Model model) {
    _currentModel = model;
    _saveSavedModel();
    notifyListeners();
  }

  Future<void> _loadSavedModel() async {
    final prefs = await SharedPreferences.getInstance();
    final modelName = prefs.getString(_modelKey) ?? "";
    if (modelName.isNotEmpty) {
      _currentModel = llm_model.Model.fromJson(jsonDecode(modelName));
    }
    notifyListeners();
  }

  Future<void> _saveSavedModel() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_modelKey, _currentModel.toString());
  }
}

