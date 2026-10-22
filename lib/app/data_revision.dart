import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 저장소의 데이터가 바뀌었음을 알리는 번호. 목록 provider들이 이 값을 보고 다시 불러온다.
/// 기록·인물·체크리스트 등을 바꾼 뒤에 [bump]를 부른다.
class DataRevision extends Notifier<int> {
  @override
  int build() => 0;

  void bump() => state++;
}

final dataRevisionProvider = NotifierProvider<DataRevision, int>(
  DataRevision.new,
);
