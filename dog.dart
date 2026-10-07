import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Dog {
  // create attributes/column
  final int id;
  final String name;
  final int age;

  Dog({required this.id, required this.name, required this.age});
  // use map function to convert dart object to database object
  // and vice versa

  Map<String, Object?> toMap() {
    // take attribute store to data base
    return {'id': id, 'name' : name, 'age' : age};
  }

  // Convert a Dog into a Map. The keys must correspond to the column names in the database.
  // Map<String, dynamic> toMap() {
  //   return {
  //     if (id != null) 'id': id,
  //     'name': name,
  //     'age': age,
  //   };
  // }

  // Implement toString to make it easier to see logs
  @override
  String toString() {
    return 'Dog{id: $id, name: $name, age: $age}';
  }
  void main() async {
    // when I start my app, I want the database to connect
    // seamlessly for manipulating
    // flutter widget must be binding to DB for data transaction
    WidgetsFlutterBinding.ensureInitialized();

    // Database come from package sqlflite
    // create table on phone database
    Future<Database> getDatabase() async {
      // join  will connect database to the real emulator storage
      return openDatabase(join(await getDatabasesPath(), 'dog_database.db'),
        onCreate: (db, version) {
          return db.execute(
            'create tale dogs(id integer primary key, name text, age integer)'
          );
        }, version:1
      );
    }


    // open the database
    final Database database = await getDatabase();

    // create a dog and add it to the database

    // let's write a method to insert the Dog instance to the row
    // need constructor that will add constructor in the database
    Future<void> insertDog(Dog dog, Database db) async{
        await db.insert('dogs', dog.toMap(),
          // this line wil solve the problem if the user makes
          // the error with the primary key
          conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    // method to display the values from the dog table
    // use list to fetch row by row from database and store to map
    Future<List<Dog>> getDogs(Database db) async {
      // convert data base to the dog objects
      final List<Map<String, Object?>> dogMaps = await db.query('dogs');
      //mapping/tranform to element something
      return dogMaps.map((dog) {
        return Dog(
          id: dog['id'] as int,
          name: dog['name'] as String,
          age: dog['age'] as int,
        );
      }).toList();

      // Convert the list of each dog's fields into a list of `Dog` objects.
      //   return [
      //     for (final {'id': id as int, 'name': name as String, 'age': age as int}
      //     in dogMaps)
      //       Dog(id: id, name: name, age: age),
      //   ];
    }

    // method to update a dog instance on the database
    Future<void> updateDog(Dog dog, Database db) async {
      await db.update('dogs', toMap(),
        where: 'id = ?',
          whereArgs: [dog.id]
      );
    }

    // deletee method
    Future<void> deleteDog(int id, Database db) async{
      await db.delete('dogs',
        where: 'id:?',
          whereArgs: [id]
      );
    }

    // create the first instance of a dog
    var fido = Dog(id: 1, name: 'Fido', age: 12);
    await insertDog(fido, database);

    // display the database
    print(await getDogs(database));

    // update fido age
    fido = Dog(id: fido.id, name: fido.name, age: fido.age+3);
    await updateDog(fido, database);

    // display the db
    print(await getDogs(database));

    // delete the fido
    await deleteDog(fido.id, database);

    print(await getDogs(database));


    List<Dog> dogList = [
      Dog(id: 2, name: 'Fido2', age: 12),
      Dog(id: 3, name: 'Fido3', age: 12),
      Dog(id: 4, name: 'Fido4', age: 12),
      Dog(id: 5, name: 'Fido5', age: 12),
      Dog(id: 6, name: 'Fido6', age: 12),

    ];

    // create a method to inset a container of dogLists
    Future<void> insertDogs(dogList, Database db) async{
      for (Dog dog in dogList) {
        db.insert('dogs', dog.toMap(),
          // this line wil solve the problem if the user makes
          // the error with the primary key
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    };
  }
}
