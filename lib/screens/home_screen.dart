
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import 'task_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Task Manager'),
            actions: [
              // Search button
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  _showSearchDialog(context, taskProvider);
                },
              ),
              // Filter toggle
              IconButton(
                icon: Icon(
                  taskProvider.showPendingOnly
                      ? Icons.check_box_outline_blank
                      : Icons.all_inclusive,
                ),
                onPressed: () {
                  taskProvider.toggleShowPendingOnly();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        taskProvider.showPendingOnly
                            ? 'Showing pending tasks only'
                            : 'Showing all tasks',
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ),
          body: _buildTaskList(context, taskProvider),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TaskDetailScreen(),
                ),
              );
            },
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildTaskList(BuildContext context, TaskProvider taskProvider) {
    final tasks = taskProvider.tasks;
    
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.assignment_outlined, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              taskProvider.searchQuery.isNotEmpty
                  ? 'No tasks match your search'
                  : taskProvider.showPendingOnly
                      ? 'No pending tasks'
                      : 'No tasks yet',
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            if (taskProvider.searchQuery.isEmpty && !taskProvider.showPendingOnly)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Tap the + button to add a new task',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return _buildTaskItem(context, taskProvider, task);
      },
    );
  }

  Widget _buildTaskItem(
    BuildContext context,
    TaskProvider taskProvider,
    Task task,
  ) {
    final dateFormat = DateFormat('MMM d, yyyy');
    final textStyle = task.status == 1
        ? const TextStyle(
            decoration: TextDecoration.lineThrough,
            color: Colors.grey,
          )
        : null;

    return Dismissible(
      key: Key(task.id.toString()),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirm Delete'),
              content: const Text('Are you sure you want to delete this task?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction) {
        taskProvider.deleteTask(task.id!);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Task "${task.title}" deleted'),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: ListTile(
          leading: Checkbox(
            value: task.status == 1,
            onChanged: (bool? value) {
              taskProvider.toggleTaskStatus(task);
            },
          ),
          title: Text(
            task.title,
            style: textStyle,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (task.description.isNotEmpty) 
                Text(
                  task.description,
                  style: textStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              Text(
                'Due: ${dateFormat.format(task.dueDate)}',
                style: TextStyle(
                  color: task.status == 0 && task.dueDate.isBefore(DateTime.now())
                      ? Colors.red
                      : Colors.grey,
                ),
              ),
            ],
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TaskDetailScreen(taskId: task.id),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showSearchDialog(BuildContext context, TaskProvider taskProvider) {
    final searchController = TextEditingController(text: taskProvider.searchQuery);
    
    showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Search Tasks'),
      content: SizedBox(
        width: double.maxFinite, 
        child: TextField(
          controller: searchController,
          decoration: const InputDecoration(
            hintText: 'Enter search term...',
            prefixIcon: Icon(Icons.search),
          ),
          autofocus: true,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            taskProvider.setSearchQuery('');
          },
          child: const Text('CLEAR'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            taskProvider.setSearchQuery(searchController.text);
          },
          child: const Text('SEARCH'),
        ),
      ],
      contentPadding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
    ),
  );
  }
}