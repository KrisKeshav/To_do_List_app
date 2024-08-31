import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:to_do_list_app/helper/global.dart';
import 'package:to_do_list_app/screens/profile_screen.dart';
import 'package:to_do_list_app/widgets/task_widgets.dart';
import 'package:to_do_list_app/api/apis.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isSearching = false;
  String _searchQuery = '';
  Stream<QuerySnapshot>? _tasksStream;

  @override
  void initState() {
    super.initState();
    _tasksStream = APIs.firestore
        .collection('users')
        .doc(APIs.auth.currentUser!.uid)
        .collection('notes')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyan.withOpacity(0.4),
        leading: const Icon(CupertinoIcons.home),
        title: _isSearching
            ? TextField(
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: 'Search your task',
          ),
          autofocus: true,
          style: const TextStyle(fontSize: 17, letterSpacing: 0.5),
          onChanged: (value) {
            setState(() {
              _searchQuery = value.toLowerCase();
            });
          },
        )
            : const Text('My To Do List'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                _searchQuery = '';
              });
            },
            icon: Icon(_isSearching ? Icons.clear : Icons.search),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ProfileScreen(),
                ),
              );
            },
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      backgroundColor: bgColors,
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: _tasksStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text('No tasks found.'));
            }

            final tasks = snapshot.data!.docs
                .where((doc) => (doc['task title'] as String)
                .toLowerCase()
                .contains(_searchQuery))
                .toList();

            // Sort tasks by due date in ascending order
            tasks.sort((a, b) {
              final dateA = (a['time'] as Timestamp).toDate();
              final dateB = (b['time'] as Timestamp).toDate();
              return dateA.compareTo(dateB);
            });

            return ListView(
              padding: EdgeInsets.only(top: mq.height * 0.02),
              physics: const BouncingScrollPhysics(),
              children: tasks.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return TaskWidget(
                  task: data['task title'],
                  details: data['details'],
                  dueDate: (data['time'] as Timestamp).toDate(),
                  dueTime: TimeOfDay.fromDateTime((data['time'] as Timestamp).toDate()),
                  onEdit: () => _editTask(doc.id, data),
                  onDelete: () => _deleteTask(doc.id),
                );
              }).toList(),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF53DBD9),
        onPressed: _showAddTaskDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddTaskDialog() {
    final TextEditingController taskController = TextEditingController();
    final TextEditingController detailsController = TextEditingController();
    DateTime? dueDate;
    TimeOfDay? dueTime;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add New Task'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: taskController,
                  decoration: const InputDecoration(labelText: 'Task'),
                ),
                TextField(
                  controller: detailsController,
                  decoration: const InputDecoration(labelText: 'Details'),
                ),
                ListTile(
                  title: Text(
                    dueDate != null
                        ? 'Due Date: ${dueDate!.day}/${dueDate!.month}/${dueDate!.year}'
                        : 'Due Date',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      final selectedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (selectedDate != null) {
                        setState(() {
                          dueDate = selectedDate;
                        });
                      }
                    },
                  ),
                ),
                ListTile(
                  title: Text(
                    dueTime != null
                        ? 'Due Time: ${dueTime!.format(context)}'
                        : 'Due Time',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.access_time),
                    onPressed: () async {
                      final selectedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (selectedTime != null) {
                        setState(() {
                          dueTime = selectedTime;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (taskController.text.isNotEmpty &&
                    dueDate != null &&
                    dueTime != null) {
                  await APIs().addTask(
                    taskController.text,
                    detailsController.text,
                    DateTime(
                      dueDate!.year,
                      dueDate!.month,
                      dueDate!.day,
                      dueTime!.hour,
                      dueTime!.minute,
                    ),
                  );
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _editTask(String taskId, Map<String, dynamic> task) {
    final TextEditingController taskController = TextEditingController(text: task['task title']);
    final TextEditingController detailsController = TextEditingController(text: task['details']);
    DateTime? dueDate = (task['time'] as Timestamp).toDate();
    TimeOfDay? dueTime = TimeOfDay.fromDateTime(dueDate!);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Task'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: taskController,
                  decoration: const InputDecoration(labelText: 'Task'),
                ),
                TextField(
                  controller: detailsController,
                  decoration: const InputDecoration(labelText: 'Details'),
                ),
                ListTile(
                  title: Text(
                    dueDate != null
                        ? 'Due Date: ${dueDate!.day}/${dueDate!.month}/${dueDate!.year}'
                        : 'Due Date',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      final selectedDate = await showDatePicker(
                        context: context,
                        initialDate: dueDate ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (selectedDate != null) {
                        setState(() {
                          dueDate = selectedDate;
                        });
                      }
                    },
                  ),
                ),
                ListTile(
                  title: Text(
                    dueTime != null
                        ? 'Due Time: ${dueTime!.format(context)}'
                        : 'Due Time',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.access_time),
                    onPressed: () async {
                      final selectedTime = await showTimePicker(
                        context: context,
                        initialTime: dueTime ?? TimeOfDay.now(),
                      );
                      if (selectedTime != null) {
                        setState(() {
                          dueTime = selectedTime;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (taskController.text.isNotEmpty &&
                    dueDate != null &&
                    dueTime != null) {
                  await APIs.firestore
                      .collection('users')
                      .doc(APIs.auth.currentUser!.uid)
                      .collection('notes')
                      .doc(taskId)
                      .update({
                    'task title': taskController.text,
                    'details': detailsController.text,
                    'time': DateTime(
                      dueDate!.year,
                      dueDate!.month,
                      dueDate!.day,
                      dueTime!.hour,
                      dueTime!.minute,
                    ),
                  });
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }


  void _deleteTask(String taskId) async {
    await APIs.firestore
        .collection('users')
        .doc(APIs.auth.currentUser!.uid)
        .collection('notes')
        .doc(taskId)
        .delete();
  }
}
