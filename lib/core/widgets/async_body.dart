import 'package:flutter/material.dart';

import 'empty_state.dart';

/// Hiển thị vòng xoay khi đang tải, thông báo khi lỗi, nội dung khi xong.
/// Giúp các màn hình không phải lặp lại FutureBuilder.
class AsyncBody<T> extends StatelessWidget {
  const AsyncBody({super.key, required this.future, required this.builder});

  final Future<T> future;
  final Widget Function(BuildContext context, T data) builder;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return _Background(
            child: const Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return _Background(
            child: EmptyState(
              icon: Icons.error_outline,
              message: 'Không tải được dữ liệu.\n${snapshot.error}',
              actionLabel: Navigator.of(context).canPop() ? 'Quay lại' : null,
              onAction: () => Navigator.of(context).maybePop(),
            ),
          );
        }
        return builder(context, snapshot.data as T);
      },
    );
  }
}

/// Nền giống Scaffold để màn hình không bị đen khi đang tải.
class _Background extends StatelessWidget {
  const _Background({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(child: child),
    );
  }
}
