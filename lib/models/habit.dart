import 'package:hive/hive.dart';

part 'habit.g.dart';

@HiveType(typeId: 0)
class Habit extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  bool isWater;

  @HiveField(2)
  Map<String, int> events;

  @HiveField(3)
  int colorCode;

  Habit({
    required this.name,
    this.isWater = false,
    required this.colorCode,
  }) : events = {};
}
