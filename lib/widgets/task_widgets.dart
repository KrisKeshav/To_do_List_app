import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:to_do_list_app/helper/global.dart';

class TaskWidget extends StatefulWidget {
  final String task;
  final String details;
  final DateTime dueDate;
  final TimeOfDay dueTime;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TaskWidget({
    Key? key,
    required this.task,
    required this.details,
    required this.dueDate,
    required this.dueTime,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  State<TaskWidget> createState() => _TaskWidgetState();
}

class _TaskWidgetState extends State<TaskWidget> {
  bool isDone = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: mq.width * 0.04, vertical: mq.height * 0.01),
      child: Slidable(
        startActionPane: ActionPane(
          motion: const StretchMotion(),
          children: [
            SlidableAction(
              onPressed: (context) {
                widget.onEdit(); // This now opens the edit dialog
              },
              icon: Icons.edit,
              label: 'Edit',
              backgroundColor: Colors.blue,
            ),

            SlidableAction(
              onPressed: (context) {
                widget.onDelete(); // Delete the task
              },
              icon: Icons.delete,
              label: 'Delete',
              backgroundColor: Colors.red,
            ),
          ],
        ),
        child: Container(
          padding: EdgeInsets.all(mq.width * 0.04),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black26.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    isDone = !isDone;
                  });
                },
                child: Container(
                  height: mq.width * 0.08,
                  width: mq.width * 0.08,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDone
                        ? Colors.greenAccent
                        : Colors.cyan.withOpacity(0.5),
                  ),
                  child: Center(
                    child: Icon(
                      isDone ? Icons.check : Icons.circle_outlined,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(width: mq.width * 0.04),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.task,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        decoration: isDone
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    SizedBox(height: mq.height * 0.005),
                    Text(
                      widget.details,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                    SizedBox(height: mq.height * 0.01),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Due: ${widget.dueDate.day}/${widget.dueDate.month}/${widget.dueDate.year}',
                          style: TextStyle(
                            color: Colors.pinkAccent.withOpacity(0.5),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          widget.dueTime.format(context),
                          style: TextStyle(
                              color: custom_green,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}