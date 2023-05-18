
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

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    final TextEditingController taskNameController = TextEditingController();
    final TextEditingController taskDescController = TextEditingController();
    String taskName0=""  ;
    String taskDesc0 ="" ;
    int taskId = 0 ;

    @override
    void initState()  {
      super.initState();
      taskNameController.addListener((){
        if(taskNameController.text.isEmpty) {
          taskName0 = "";
        } else {
          taskName0 = taskNameController.text;
        }
      });
      taskDescController.addListener((){
        if(taskDescController.text.isEmpty) {
          taskDesc0 = "";
        } else {
          taskDesc0= taskDescController.text;
        }
      });
    }
    Future addTasks({required int taskId0, required String taskName0, required String taskDesc0}) async {
      DocumentReference docRef = await FirebaseFirestore.instance.collection('tasks').add(
        {
          'taskDesc': taskDesc0,
          'taskName': taskName0,
          'taskId' : taskId0,
        },
      );
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
              ),
              const SizedBox(height: 15),
              TextFormField(
                keyboardType: TextInputType.multiline,
                maxLines: null,
                style: const TextStyle(fontSize: 14),
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
                onSaved : (String? taskDescController ){},
              ),
              const SizedBox(height: 15),

            ],
          ),
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey,
          ),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: ()  {
            final String taskName = taskName0;
            final String taskDesc = taskDesc0;
            taskId += 1 ;
            addTasks(taskId0: taskId ,taskName0: taskName, taskDesc0: taskDesc);
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
class UpdateTaskAlertDialog extends StatefulWidget{

  final String  taskName, taskDesc;
  final int taskId ;

  const UpdateTaskAlertDialog(
      {Key? key, required this.taskId, required this.taskName, required this.taskDesc})
      : super(key: key);

  @override
  State<UpdateTaskAlertDialog> createState()  => _UpdateTaskAlertDialogState() ;

}


class _UpdateTaskAlertDialogState extends State<UpdateTaskAlertDialog>{
  factory  _UpdateTaskAlertDialogState() => _UpdateTaskAlertDialogState() ;
  final Stream<QuerySnapshot> _usersStream =
  FirebaseFirestore.instance.collection('tasks').snapshots();


  final TextEditingController taskNameController = TextEditingController();
  final TextEditingController taskDescController = TextEditingController();



  Future _updateTasks(String taskName, String taskDesc) async {
    var collection = FirebaseFirestore.instance.collection('tasks'); // fetch the collection name i.e. tasks
    collection
        .doc(widget.taskId as String?) // ensure the right task is updated by referencing the task id in the method
        .update({'taskName': taskName, 'taskDesc': taskDesc}) // the update method will replace the values in the db, with these new values from the update alert dialog box
        .then( // implement error handling
          (_) => Fluttertoast.showToast(
          msg: "Task updated successfully",
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
      return PopupMenuItem<String>(
        value: 'edit',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Edit',
              style: TextStyle(fontSize: 13.0),
            ),
            ElevatedButton(
              onPressed: () {
                final taskName = taskNameController.text;
                final taskDesc = taskDescController.text;
                _updateTasks(taskName, taskDesc);
                Navigator.of(context, rootNavigator: true).pop();
              },
              child: const Text('Update'),
            ),
               StreamBuilder<QuerySnapshot>(
                  stream: _usersStream,
                  builder: (context, snapshot){
                snapshot.data!.docs.map((DocumentSnapshot document) {
                  Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                  }
                  );
                  }
                  ),
          ],
        ),
        onTap: () {
          int taskId = data['taskId'];
          String taskName = data['taskName'];
          String taskDesc = data['taskDesc'];

          showDialog(
            context: context,
            builder: (context) =>
                UpdateTaskAlertDialog(
                  taskId: taskId,
                  taskName: taskName,
                  taskDesc: taskDesc,
                ),
          );
        },
      );
    };
  }

