import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/tab_page_scaffold.dart';
import 'widgets/checklist_section.dart';
import 'widgets/settings_section.dart';

/// 전체 탭: 체크리스트(F-04)와 설정·데이터 관리(F-11). **임시 디자인**.
class AllScreen extends StatelessWidget {
  const AllScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const TabPageScaffold(
      title: '전체',
      children: [
        SizedBox(height: HomeLayout.headerToDate),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.pageMargin),
          child: Column(
            children: [
              ChecklistSection(),
              SizedBox(height: 32),
              SettingsSection(),
            ],
          ),
        ),
      ],
    );
  }
}
