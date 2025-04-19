import 'dart:io' as io;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import "package:qubase_mcp/llm/model.dart";
import 'package:file_picker/file_picker.dart';

File platformFileToFile(PlatformFile platformFile) {
  final fileType =
      lookupMimeType(platformFile.name) ?? platformFile.extension ?? '';

  if (fileType.startsWith('image/')) {
    List<int> fileBytes;
    if (platformFile.bytes != null) {
      fileBytes = platformFile.bytes!;
    } else {
      fileBytes = io.File(platformFile.path!).readAsBytesSync();
    }

    return File(
      name: platformFile.name,
      path: platformFile.path,
      size: platformFile.size,
      fileType: fileType,
      fileContent: base64Encode(fileBytes),
      // fileContent: "data:$fileType;base64,${base64Encode(fileBytes)}",
    );
  }

  debugPrint('fileType: $fileType');

  // Check if it's a text type file
  bool isTextFile = fileType.startsWith('text/') ||
      fileType.startsWith('application/') &&
          (fileType.contains('json') ||
              fileType.contains('javascript') ||
              fileType.contains('xml') ||
              fileType.contains('yaml') ||
              fileType.contains('x-yaml') ||
              fileType.contains('toml') ||
              fileType.contains('markdown') ||
              fileType.contains('x-httpd-php') ||
              fileType.contains('x-sh') ||
              fileType.contains('x-python'));

  if (isTextFile) {
    List<int> fileBytes;
    if (platformFile.bytes != null) {
      fileBytes = platformFile.bytes!;
    } else {
      fileBytes = io.File(platformFile.path!).readAsBytesSync();
    }
    return File(
      name: platformFile.name,
      path: platformFile.path,
      size: platformFile.size,
      fileType: fileType,
      fileContent: utf8.decode(fileBytes),
    );
  }

  return File(
    name: platformFile.name,
    path: platformFile.path,
    size: platformFile.size,
    fileType: fileType,
    fileContent: '',
  );
}

bool isTextFile(String fileType) {
  return fileType.startsWith('text/') ||
      fileType.startsWith('application/') &&
          (fileType.contains('json') ||
              fileType.contains('javascript') ||
              fileType.contains('xml') ||
              fileType.contains('yaml') ||
              fileType.contains('x-yaml') ||
              fileType.contains('toml') ||
              fileType.contains('markdown') ||
              fileType.contains('x-httpd-php') ||
              fileType.contains('x-sh') ||
              fileType.contains('x-python'));
}

bool isImageFile(String fileType) {
  return fileType.startsWith('image/');
}

