import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 사용자에게 그대로 보여 줘도 안전한 문구를 담은 앱 예외. 이 예외의 [message]만 오류 기록에 남는다.
class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// 오류 기록 한 건. **기록 본문·인물 이름이 들어가지 않도록** 오류 종류와 호출 스택만 남긴다
/// (SPEC F-12·6.8: 본문과 인물 이름은 어디에도 보내지 않는다).
class AppErrorEntry {
  const AppErrorEntry({
    required this.time,
    required this.type,
    required this.where,
    required this.stack,
    this.safeMessage,
  });

  final DateTime time;

  /// 오류 클래스 이름 (예: `StateError`).
  final String type;

  /// 어디서 났는지(예: `flutter`, `save-entry`).
  final String where;

  /// [AppException]일 때만 있는 안전한 문구.
  final String? safeMessage;

  /// 호출 스택 앞부분.
  final String stack;
}

/// 앱 안에서만 쓰는 오류 기록 (P-11, F-12의 "앱 내부 오류 처리"). 최근 [maxEntries]건만 메모리에 둔다.
/// 외부 분석 도구로는 보내지 않는다(확장 기능). 나중에 보낸다면 이 기록(본문 없음)만 보낸다.
class AppErrorLog {
  AppErrorLog({DateTime Function()? clock}) : _clock = clock ?? DateTime.now;

  static const maxEntries = 50;
  static const _stackLines = 8;

  final DateTime Function() _clock;
  final List<AppErrorEntry> _entries = [];

  List<AppErrorEntry> get entries => List.unmodifiable(_entries);

  /// 오류를 기록한다. 오류 메시지에는 사용자가 쓴 글이 섞일 수 있어서 [AppException]이 아니면 버린다.
  void record(Object error, StackTrace? stack, {String where = 'app'}) {
    final lines = (stack ?? StackTrace.empty)
        .toString()
        .split('\n')
        .where((l) => l.trim().isNotEmpty)
        .take(_stackLines)
        .join('\n');
    _entries.add(
      AppErrorEntry(
        time: _clock(),
        type: error.runtimeType.toString(),
        where: where,
        safeMessage: error is AppException ? error.message : null,
        stack: lines,
      ),
    );
    if (_entries.length > maxEntries) _entries.removeAt(0);
  }
}

final appErrorLogProvider = Provider<AppErrorLog>((ref) => AppErrorLog());
