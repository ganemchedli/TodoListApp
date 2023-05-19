import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:todolistv2/constraints/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: tdBg,
        centerTitle: true,
        title: const Text("To-Do List"),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(CupertinoIcons.calendar),
          ),
        ],
      ),
      body: Container(
        child: const DisplayTasks(),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 4.0,
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          height: kBottomNavigationBarHeight,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              IconButton(
                icon: const Icon(CupertinoIcons.calendar),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(CupertinoIcons.tag),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return const AddTaskAlertDialog();
            },
          );
        },
        child: const Icon(CupertinoIcons.add),
      ),
    );
  }
}

class _AddTaskAlertDialogState extends State<AddTaskAlertDialog> {
  bool isWidgetVisible = true; // Initial visibility state
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    final TextEditingController taskNameController = TextEditingController();
    final TextEditingController taskDescController = TextEditingController();

    Future<void> addTask(
        {required String taskName, required String taskDesc}) async {
      try {
        DocumentReference docRef =
            await FirebaseFirestore.instance.collection('tasks').add({
          'taskName': taskName,
          'taskDesc': taskDesc,
          // Additional task properties, if any
        });
        String docId = docRef.id;

        await docRef.update({'taskId': docId});
        // Save the generated ID in Firestore
      } catch (e) {
        //print('Error adding task: $e');
      }
    }

    return AlertDialog(
      scrollable: true,
      title: const Text(
        'New Task',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16, color: Colors.brown),
      ),
      content: SizedBox(
        height: height * 0.35,
        width: width,
        child: Form(
          child: Column(
            children: <Widget>[
              TextFormField(
                style: const TextStyle(fontSize: 14),
                controller: taskNameController,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  hintText: 'Task',
                  hintStyle: const TextStyle(fontSize: 14),
                  icon: const Icon(CupertinoIcons.square_list,
                      color: Colors.brown),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onSaved: (String? taskNameController) {},
              ),
              const SizedBox(height: 15),
              TextFormField(
                keyboardType: TextInputType.multiline,
                maxLines: null,
                style: const TextStyle(fontSize: 14),
                controller: taskDescController,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  hintText: 'Description',
                  hintStyle: const TextStyle(fontSize: 14),
                  icon: const Icon(CupertinoIcons.bubble_left_bubble_right,
                      color: Colors.brown),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onSaved: (String? taskDescController) {},
              ),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey,

          ),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final String taskName0 = taskNameController.text;
            final String taskDesc0 = taskDescController.text;
            addTask(taskName: taskName0, taskDesc: taskDesc0);
            Navigator.of(context).pop();
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class AddTaskAlertDialog extends StatefulWidget {
  const AddTaskAlertDialog({super.key});

  @override
  State<AddTaskAlertDialog> createState() => _AddTaskAlertDialogState();
}



class DisplayTasks extends StatelessWidget {
  const DisplayTasks({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('tasks').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        List<Task> tasks = snapshot.data!.docs.map((doc) {
          return Task(
            taskId: doc.id,
            taskName: doc['taskName'],
            taskDesc: doc['taskDesc'],
          );
        }).toList();

        return ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.0),
                color: Colors.white,
                boxShadow: const [
                  BoxShadow(
                    color: tdBg,
                    blurRadius: 5.0,
                    offset: Offset(0, 5), // shadow direction: bottom right
                  ),
                ],
              ),
              height: 100,
              margin: const EdgeInsets.only(bottom: 15.0),

              child: ListTile(
                title: Text(tasks[index].taskName),
                subtitle: Text(tasks[index].taskDesc),
                trailing: const Icon(Icons.more_vert),
                onTap: () {
                  Provider.of<TaskProvider>(context, listen: false)
                      .setTaskId(tasks[index].taskId);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UpdateTaskAlertDialog(),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

class Task {
  final String taskId;
  final String taskName;
  final String taskDesc;

  Task({
    required this.taskId,
    required this.taskName,
    required this.taskDesc,
  });
}

class TaskProvider with ChangeNotifier {
  late String taskId;

  void setTaskId(String id) {
    taskId = id;
    notifyListeners();
  }
  Future<void> deleteTask(String taskId) async {
    try {
      await FirebaseFirestore.instance
          .collection('tasks')
          .doc(taskId)
          .delete();

    } catch (e) {
        print("error") ;
    }
  }
}

class UpdateTaskAlertDialog extends StatefulWidget {
  const UpdateTaskAlertDialog({super.key});

  @override
  State<UpdateTaskAlertDialog> createState() => _UpdateTaskAlertDialogState();
}

class _UpdateTaskAlertDialogState extends State<UpdateTaskAlertDialog> {
  late TextEditingController taskNameController;
  late TextEditingController taskDescController;

  @override
  void initState() {
    super.initState();
    taskNameController = TextEditingController();
    taskDescController = TextEditingController();
  }

  @override
  void dispose() {
    taskNameController.dispose();
    taskDescController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String taskId = Provider.of<TaskProvider>(context).taskId;
    final provider = Provider.of<TaskProvider>(context, listen: false);
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Material(
      // Wrap the PopupMenuItem with Material
      child: AlertDialog(
        scrollable: true,
        title: const Text(
          'Update Task',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.brown),
        ),
        content: SizedBox(
            height: height * 0.35,
            width: width,
            child: Form(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    style: const TextStyle(fontSize: 14),
                    controller: taskNameController,
                    decoration: const InputDecoration(labelText: 'Task Name'),
                  ),
                  TextFormField(
                    controller: taskDescController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    style: const TextStyle(fontSize: 14),
                    decoration:
                        const InputDecoration(labelText: 'Task Description'),
                  ),
                ],
              ),
            )),
        actions: [
          ElevatedButton(
            onPressed: () {
              String updatedTaskName = taskNameController.text;
              String updatedTaskDesc = taskDescController.text;
              String upTaskId = taskId;
              updateTask(upTaskId, updatedTaskName, updatedTaskDesc);
              Navigator.of(context).pop();
            },
            child: const Text('Update'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.deleteTask(taskId);
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> updateTask(
      String taskId, String taskName, String taskDesc) async {
    try {
      await FirebaseFirestore.instance.collection('tasks').doc(taskId).update({
        'taskName': taskName,
        'taskDesc': taskDesc,
      });
      //print('Task updated successfully');
    } catch (e) {
      //print('Failed to update task: $e');
    }
  }
}


