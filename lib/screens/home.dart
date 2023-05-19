import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:todolistv2/constraints/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Home extends StatelessWidget{
  const Home({super.key});


  @override
  Widget build(BuildContext context){
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
        child: const DisplayTasks() ,
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
                onPressed: () {
                },
              ),
              IconButton(
                icon: const Icon(CupertinoIcons.tag),
                onPressed: () {

                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: (){showDialog(
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


    Future<void> addTask({required String taskName, required String taskDesc}) async {
      try {
      await FirebaseFirestore.instance.collection('tasks').add({
          'taskName': taskName,
          'taskDesc': taskDesc,
          // Additional task properties, if any
        });
        print('Task added successfully');
      } catch (e) {
        print('Error adding task: $e');
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

                  icon: const Icon(CupertinoIcons.square_list, color: Colors.brown),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onSaved : (String? taskNameController){},
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
                  icon: const Icon(CupertinoIcons.bubble_left_bubble_right, color: Colors.brown),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onSaved : (String? taskDescController){},
              ),
              const SizedBox(height: 15),

            ],
          ),
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey,
          ),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: ()  {
            final String taskName0 = taskNameController.text;
            final String taskDesc0 = taskDescController.text;
            addTask(taskName: taskName0, taskDesc: taskDesc0);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class AddTaskAlertDialog extends StatefulWidget{
  const AddTaskAlertDialog({super.key});

  @override
  State<AddTaskAlertDialog > createState() => _AddTaskAlertDialogState();



  }

class DisplayTasks extends StatefulWidget {
  const DisplayTasks({super.key});
  @override
  State<DisplayTasks> createState() => _DisplayTasksState();
}

class _DisplayTasksState extends State<DisplayTasks>{
  final Stream<QuerySnapshot> _usersStream =
  FirebaseFirestore.instance.collection('tasks').snapshots();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10.0),
      child: StreamBuilder<QuerySnapshot>(
        stream: _usersStream,
        builder: (context, snapshot){
          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
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

                child: ListTile (
                  title: Text(data['taskName']),
                  subtitle: Text(data['taskDesc']),
                  isThreeLine: true,
                  trailing: const Icon(Icons.more_vert),
                  onTap:() {showDialog(
                    context: context,
                    builder: (context) => const UpdateTaskAlertDialog(taskId: '', taskName: '', taskDesc: ''),
                  );
              },

              ),
              );
            }).toList()
            .cast(),

          );
        },
      ),
    );

  }
}
class UpdateTaskAlertDialog extends StatefulWidget {
  final String taskId, taskName, taskDesc;

  const UpdateTaskAlertDialog(
      {Key? key, required this.taskId, required this.taskName, required this.taskDesc})
      : super(key: key);

  @override
  State<UpdateTaskAlertDialog> createState() => _UpdateTaskAlertDialogState();
}


class _UpdateTaskAlertDialogState extends State<UpdateTaskAlertDialog> {
  late TextEditingController taskNameController = TextEditingController();
  late TextEditingController taskDescController = TextEditingController();
  String taskName = "" ;
  String taskDesc = "" ;
  late Map<String, dynamic> data ;

  @override
  void initState(){
    super.initState();
    taskNameController = TextEditingController(text : taskName) ;
    taskDescController = TextEditingController(text: taskDesc) ;
  }
  factory _UpdateTaskAlertDialogState() => _UpdateTaskAlertDialogState();

  void fetchTaskData(String taskId) async {
    DocumentSnapshot taskSnapshot = await FirebaseFirestore.instance
        .collection('tasks')
        .doc(taskId)
        .get();
     data = taskSnapshot.data() as Map<String, dynamic>;
  }



  //taskNameController.text = widget.taskName;
  //taskDescController.text = widget.taskDesc;

  @override
  Widget build(BuildContext context) {
    return PopupMenuItem( //pop up menu item has two values: edit and delete
      value: 'edit', //when value is edit, proceed to change the string values
      child: const Text(
        'Edit',
        style: TextStyle(fontSize: 13.0),
      ),
      onTap: () {
        String taskId = (data['taskId']);
        String taskName = (data['taskName']);
        String taskDesc = (data['taskDesc']);

        Future.delayed(
          const Duration(seconds: 0),
              () =>
              showDialog( //opens an alert dialog box with the strings already populated
                context: context,
                builder: (context) =>
                    UpdateTaskAlertDialog(
                        taskId: taskId, taskName: taskName, taskDesc: taskDesc),
              ),
        );
        ElevatedButton(
          onPressed: () {
            final taskName = taskNameController.text;
            final taskDesc = taskDescController.text;
            _updateTasks(taskName, taskDesc) ;
            Navigator.of(context, rootNavigator: true).pop();
          },
          child: const Text('Update'),
        );

      },
    );
  }
  Future _updateTasks(String taskName, String taskDesc) async {

    var collection = FirebaseFirestore.instance.collection(
        'tasks'); // fetch the collection name i.e. tasks
    collection
        .doc(widget.taskId ) // ensure the right task is updated by referencing the task id in the method
        .update({
      'taskName': taskName,
      'taskDesc': taskDesc
    }) // the update method will replace the values in the db, with these new values from the update alert dialog box
        .then( // implement error handling
          (_) =>
          Fluttertoast.showToast(
              msg: "Task updated successfully",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.SNACKBAR,
              backgroundColor: Colors.black54,
              textColor: Colors.white,
              fontSize: 14.0),
    )
        .catchError(
          (error) =>
          Fluttertoast.showToast(
              msg: "Failed: $error",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.SNACKBAR,
              backgroundColor: Colors.black54,
              textColor: Colors.white,
              fontSize: 14.0),
    );
  }
}

/*class _DeleteTaskDialogState extends State<DeleteTaskDialog>{

  Future _deleteTasks() async {
    var collection = FirebaseFirestore.instance.collection('tasks'); // fetch the collection name i.e. tasks
    collection
        .doc(widget.taskId) // ensure the right task is deleted by passing the task id to the method
        .delete() // delete method removes the task entry in the collection
        .then( // implement error handling
          (_) => Fluttertoast.showToast(
          msg: "Task deleted successfully",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.SNACKBAR,
          backgroundColor: Colors.black54,
          textColor: Colors.white,
          fontSize: 14.0),
    )
        .catchError(
          (error) => Fluttertoast.showToast(
          msg: "Failed: $error",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.SNACKBAR,
          backgroundColor: Colors.black54,
          textColor: Colors.white,
          fontSize: 14.0),
    );
  }
  @override
  Widget build(BuildContext context) {
    return PopupMenuItem(
      value: 'delete',
      child: const Text(
        'Delete',
        style: TextStyle(fontSize: 13.0),
      ),
      onTap: (){
        String taskId = (data['id']);
        String taskName = (data['taskName']);
        Future.delayed(
          const Duration(seconds: 0),
              () => showDialog(
            context: context,
            builder: (context) => DeleteTaskDialog(taskId: taskId, taskName:taskName),
          ),
        );
      },
    );
  }

}
class DeleteTaskDialog extends StatefulWidget{
  const DeleteTaskDialog({super.key});

  @override
  State<DeleteTaskDialog> createState() => _DeleteTaskDialogState() ;
}
*/
