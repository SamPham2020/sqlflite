import 'package:flutter/material.dart';
import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'Dog.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // user enter the entries for data
      home: DatabaseDemoController(),
    );
  }
}

class DatabaseDemoController extends StatefulWidget {
  const DatabaseDemoController({super.key});

  @override
  State<DatabaseDemoController> createState() => _DatabaseDemoControllerState();
}

class _DatabaseDemoControllerState extends State<DatabaseDemoController> {
  // define data
  // Database? database;
  late Database database;
  TextEditingController idController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  List<Dog> dogList =[];

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Dog Details: '),
            SizedBox(height: 15,),
            TextField(
              controller: idController,
              decoration: const InputDecoration(
                labelText: 'Enter your id',
                border: OutlineInputBorder(), // Adds a full border box
              ),
            ),
            SizedBox(height: 15,),

            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Enter your name',
                border: OutlineInputBorder(), // Adds a full border box
              ),
            ),
            SizedBox(height: 15,),

            TextField(
              controller: ageController,
              decoration: const InputDecoration(
                labelText: 'Enter your age',
                border: OutlineInputBorder(), // Adds a full border box
              ),
            ),

            SizedBox(height: 15,),

            // have a button to display the value on a listview
            ElevatedButton(onPressed: () {
               _add();

              // use the listview builder to display all dogs

              },
                child: Text('Add')
            ),
            // to prevent crash from column and listview
            Expanded(child: ListView.builder(
              itemCount: dogList.length,

                itemBuilder: (context, index){
                  final Dog dog = dogList[index];

                  return ListTile(
                    title: Text('${dog.name} (Age: ${dog.age}'),

                    subtitle: Text('Id: ${dog.id}') ,

                  );
                })),
          ],
        ),
      ),
    );
  }

  // use the listview builder to display all dogs
  // Widget displayDogs() {
  //   return ListView.builder(
  //     itemCount: dogList.,
  //   );
  // }
  // call a method that helps to connect to the flutter
  // widget and the db for the user to manipulate the data
  // initate the database so when the flutter engine compiles the code
  // in this initilized state
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initDatabase();
  }

  Future<void> _initDatabase() async{
    // create a space on mobile phone
    database = await openDatabase(join(await getDatabasesPath(), 'demo1.db'),
      onCreate: (db, version) {
        return db.execute(
            'create table dogs(id integer primary key autoincrement, name text, age integer)'
        );
      },
      version: 1
    );

    //write a method to refresh this db when user modifies the data
    _refreshDogList();
  }

  Future<void> _refreshDogList() async{
    // create the list and fetch all entries from the table and store to list of map
    final List<Map<String, Object?>> dogMaps = await database.query('dogs');
    setState(() {
      // transform every row and store in the attribute of dog object
      dogList = dogMaps.map((dogMap) {
        return Dog(
            id: dogMap['id'] as int,
            name: dogMap['name'] as String,
            age: dogMap['age'] as int,);
      }).toList();
    });
  }

  // add the dog instance from the user value to database
  Future<void> _add() async {
    final int id = int.tryParse(idController.text) ?? 0;
    final String name = nameController.text;
    final int age = int.tryParse(ageController.text) ?? 0;

    // check for robustness
    // if the name is not empty
    if (name.isNotEmpty && age > 0) {
      // take value and insert to the table
      await database.insert('dogs',
          {'id': id,
            'name': name,
            'age' : age,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    // need to refresh
    _refreshDogList();

    // clear the field the user to write another instance
    _clearFields();
  }
  void _clearFields() {
    idController.clear();
    ageController.clear();
    nameController.clear();
  }


}

class Dog {
// create attributes/column
  final int id;
  final String name;
  final int age;

  Dog({required this.id, required this.name, required this.age});

  // use map function to convert dart object to database object
  // and vice versa
  Map<String, Object?> toMap() {
    return {'id': id, 'name' : name, 'age' : age};
  }

  @override
  String toString() {
    return 'Dog{id: $id, name: $name, age: $age}';
  }


}

