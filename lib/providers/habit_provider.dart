import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:intl/intl.dart';

class HabitProvider extends ChangeNotifier {
  Box<Habit>? _habitBox;

  List<Habit> get habits => _habitBox?.values.toList() ?? [];

  bool get isLoading => _habitBox == null;

  // Initialize Hive box
  Future<void> init() async {
    if (!Hive.isAdapterRegistered(0)) {
       Hive.registerAdapter(HabitAdapter());
    }
    _habitBox = await Hive.openBox<Habit>('habits');
    
    // Seed default habits if empty for demo purposes
    if (_habitBox!.isEmpty) {
      await addHabit("Drink Water", true, 0xFF2196F3);
      await addHabit("Read 30 mins", false, 0xFF4CAF50);
      await addHabit("Exercise", false, 0xFFFF5722);
    }
    
    notifyListeners();
  }

  Future<void> addHabit(String name, bool isWater, int color) async {
    final newHabit = Habit(name: name, isWater: isWater, colorCode: color);
    await _habitBox!.add(newHabit);
    notifyListeners();
  }

  Future<void> toggleHabit(Habit habit, DateTime date) async {
    final String dateStr = DateFormat('yyyy-MM-dd').format(date);
    
    if (habit.isWater) {
      // For water, increment count
      int current = habit.events[dateStr] ?? 0;
      habit.events[dateStr] = current + 1;
    } else {
      // For chores, toggle
      if (habit.events.containsKey(dateStr) && habit.events[dateStr]! > 0) {
        habit.events.remove(dateStr);
      } else {
        habit.events[dateStr] = 1;
      }
    }
    await habit.save();
    notifyListeners();
  }
  
  bool isHabitCompletedToday(Habit habit) {
    final String dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return habit.events.containsKey(dateStr) && habit.events[dateStr]! > 0;
  }
  
  int getWaterCountToday(Habit habit) {
     final String dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
     return habit.events[dateStr] ?? 0;
  }
}
