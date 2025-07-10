import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pp_kits/pp_kits.dart';

void main() {
  getPublicIp().then((ip) {
    Logger.log('网络: 获取到公网IP: $ip');
  }).catchError((e) {
    Logger.log('网络: 获取公网IP失败: $e');
  });
  runApp(const MainApp());
}

/// IP监听器
Timer? _ipCheckTimer;
var publicIP = '';

Future<String> getPublicIp() async {
  if (publicIP.isValidIP()) {
    Logger.log('网络: 已获取公网IP，跳过获取');
    return publicIP;
  }

  Logger.log('网络: 开始获取公网IP......');
  final apiEndpoints = [
    'https://api.ipify.org',
    'https://ifconfig.me/ip',
    'https://icanhazip.com',
    'https://checkip.amazonaws.com'
  ];

  final completer = Completer<String>();
  final timeout = Timer(const Duration(seconds: 60), () {
    if (!completer.isCompleted) {
      Logger.log('网络: 获取公网IP超时');
      completer.complete('');
    }
  });

  final futures = apiEndpoints.map((endpoint) async {
    try {
      Logger.log('网络: 获取IP源> $endpoint');
      final response = await Dio().get(endpoint);
      if (response.statusCode == 200) {
        final ip = response.data.toString().trim();
        if (ip.isValidIP() && !completer.isCompleted) {
          publicIP = ip;
          _ipCheckTimer?.cancel();
          _ipCheckTimer = null;
          Logger.log('网络: 成功获取公网IP: $publicIP');
          completer.complete(ip);
        }
      }
    } catch (e) {
      Logger.log('获取公网IP失败 $endpoint: $e');
    }
  }).toList();

  await Future.wait(futures);
  timeout.cancel();

  final result = await completer.future;
  Logger.log('网络: 当前公共IP>$result');
  return result;
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Hello World!'),
        ),
      ),
    );
  }
}
