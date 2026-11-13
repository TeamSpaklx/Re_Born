import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reborn_app/app/app.dart';
import 'package:reborn_app/app/router.dart';
import 'package:reborn_app/features/auth/presentation/auth_screen.dart';
import 'package:reborn_app/features/home/presentation/today_screen.dart';

void main() {
  testWidgets('로그인 목업은 입력을 검증하고 샘플 홈으로 이동한다', (tester) async {
    tester.view.physicalSize = const Size(402, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [initialLocationProvider.overrideWithValue(AppRoutes.auth)],
        child: const RebornApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(AuthScreen), findsOneWidget);

    await tester.tap(find.text('이미 계정이 있나요? 로그인'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), 'invalid');
    await tester.enterText(find.byType(TextField).at(1), 'password123');
    await tester.tap(find.text('로그인'));
    await tester.pumpAndSettle();
    expect(find.text('이메일 주소를 확인해 주세요.'), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(0), 'demo@example.com');
    await tester.tap(find.text('로그인'));
    await tester.pumpAndSettle();
    expect(find.byType(TodayScreen), findsOneWidget);
  });
}
