import 'package:flutter/material.dart';

import '../../../../shared/widgets/empty_state.dart';

/// 홈 데이터를 불러오지 못했을 때: 문구 + "다시 시도" (docs/FRONTEND.md 4장).
class HomeErrorView extends StatelessWidget {
  const HomeErrorView({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(child: ErrorState(onRetry: onRetry));
  }
}
