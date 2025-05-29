import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../components/layout/main_layout.dart';

/// 测试页面 - 演示如何禁用 TrayNavigation
class FullscreenTestPage extends BasePage {
  const FullscreenTestPage({super.key});

  @override
  bool get showTrayNavigation => false; // 禁用 TrayNavigation
  @override
  Widget buildContent(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.fullscreen,
              size: 100,
              color: Colors.white,
            ),
            const SizedBox(height: 20),
            Text(
              '全屏测试页面',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '此页面已禁用 TrayNavigation',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 40),            ElevatedButton.icon(
              onPressed: () => context.go('/'),
              icon: const Icon(Icons.arrow_back),
              label: const Text('返回'),
            ),
          ],
        ),
      ),
    );
  }
}
