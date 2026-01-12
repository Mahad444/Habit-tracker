import 'package:flutter/material.dart';
import 'package:habit_tracker/providers/habit_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Hello, User",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 5),
              Text(
                "Your daily goals",
                style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.6)),
              ),
              const SizedBox(height: 30),
              
              // Heatmap Section
              Consumer<HabitProvider>(
                builder: (context, provider, child) {
                  // Aggregate data for global heatmap
                  Map<DateTime, int> datasets = {};
                  for (var habit in provider.habits) {
                    habit.events.forEach((key, value) {
                      final parts = key.split('-');
                      final date = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
                      datasets[date] = (datasets[date] ?? 0) + 1;
                    });
                  }
                  
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: HeatMap(
                      startDate: DateTime.now().subtract(const Duration(days: 60)),
                      endDate: DateTime.now(),
                      datasets: datasets,
                      colorMode: ColorMode.opacity,
                      showText: false,
                      scrollable: true,
                      colorsets: {
                        1: Theme.of(context).primaryColor,
                      },
                      onClick: (value) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value.toString())));
                      },
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 30),
              const Text(
                "Today's Habits",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 15),
              
              Expanded(
                child: Consumer<HabitProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (provider.habits.isEmpty) {
                      return const Center(child: Text("No habits added yet."));
                    }
                    
                    return ListView.builder(
                      itemCount: provider.habits.length,
                      itemBuilder: (context, index) {
                        final habit = provider.habits[index];
                        final isCompleted = provider.isHabitCompletedToday(habit);
                        final waterCount = provider.getWaterCountToday(habit);
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: isCompleted && !habit.isWater 
                                ? Border.all(color: Color(habit.colorCode).withOpacity(0.5), width: 1) 
                                : null,
                          ),
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Color(habit.colorCode).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                habit.isWater ? Icons.local_drink : Icons.check_circle_outline, 
                                color: Color(habit.colorCode),
                              ),
                            ),
                            title: Text(habit.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            trailing: habit.isWater
                                ? Container(
                                    width: 80,
                                    height: 30,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(15)
                                    ),
                                    child: Text("${waterCount} cups", style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
                                  )
                                : Checkbox(
                                    value: isCompleted,
                                    activeColor: Color(habit.colorCode),
                                    onChanged: (val) {
                                      provider.toggleHabit(habit, DateTime.now());
                                    },
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                  ),
                            onTap: () {
                              provider.toggleHabit(habit, DateTime.now());
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddHabitDialog(context),
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showAddHabitDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    bool isWater = false;
    int selectedColor = 0xFF2196F3;
    final List<int> colors = [0xFF2196F3, 0xFF4CAF50, 0xFFFF5722, 0xFF9C27B0, 0xFFFFC107, 0xFFE91E63];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Theme.of(context).colorScheme.surface,
              title: const Text("New Habit"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: "Habit Name", 
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text("Track Water?"),
                    subtitle: const Text("Counts daily intake"),
                    value: isWater,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) {
                      setState(() => isWater = val);
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text("Color Theme"),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    children: colors.map((color) {
                      return GestureDetector(
                        onTap: () => setState(() => selectedColor = color),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Color(color),
                            shape: BoxShape.circle,
                            border: selectedColor == color 
                                ? Border.all(color: Colors.white, width: 3) 
                                : null,
                          ),
                        ),
                      );
                    }).toList(),
                  )
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context), 
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.isNotEmpty) {
                      Provider.of<HabitProvider>(context, listen: false)
                          .addHabit(nameController.text, isWater, selectedColor);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
