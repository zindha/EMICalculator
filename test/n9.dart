import "dart:io";
import "package:flutter_test/flutter_test.dart";
import "package:hive_flutter/hive_flutter.dart";

void main() {
  late Directory dir;
  setUpAll(() async {
    dir = Directory.systemTemp.createTempSync("n9_");
    Hive.init(dir.path);
    await Hive.openBox("test_box");
  });
  tearDownAll(() async {
    await Hive.close();
    dir.deleteSync(recursive: true);
  });

  setUp(() async {
    // Does setUp run outside FakeAsync?
    final box = Hive.box("test_box");
    await box.put("k", "from-setUp");
  });

  testWidgets("test", (tester) async {
    final box = Hive.box("test_box");
    final val = box.get("k");  // sync read
    expect(val, "from-setUp");
  });
}
