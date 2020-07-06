import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:firedart/firedart.dart';

final repo = TestRepo();

void main() {
  Firestore.initialize('project-422424978958');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Row(
        children: <Widget>[
          Expanded(
            child: FutureBuilder<List<TestData>>(
              future: repo.getAllSubjects,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    itemBuilder: (context, index) => ListTile(
                      title: Text(
                        snapshot.data.elementAt(index).name ?? '',
                      ),
                      subtitle: Text('${snapshot.data.elementAt(index).id}'),
                    ),
                    itemCount: snapshot.data.length,
                  );
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<List<TestData>>(
              stream: repo.subjectsStream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    itemBuilder: (context, index) => ListTile(
                      title: Text(
                        snapshot.data.elementAt(index).name ?? '',
                      ),
                      subtitle: Text('${snapshot.data.elementAt(index).id}'),
                    ),
                    itemCount: snapshot.data.length,
                  );
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class TestRepo {
  const TestRepo();

  Future<List<TestData>> get getAllSubjects async {
    final collection = _getCollection();
    final snapshot = await collection.get(); // At this point the memory leaks

    return snapshot.map<TestData>((s) => TestData.fromMap(s.map)).toList() ??
        <TestData>[];
  }

  Stream<List<TestData>> get subjectsStream =>
      _getCollection().stream.asyncMap<List<TestData>>(
        (q) async {
          return q.map<TestData>((s) => TestData.fromMap(s.map)).toList();
        },
      );

  CollectionReference _getCollection({bool nestedCollections = false}) {
    if (nestedCollections) {
      return Firestore.instance
          .collection('nested_layer_1')
          .document('nl1d')
          .collection('nested_layer_2');
    } else {
      return Firestore.instance.collection('layer_1');
    }
  }
}

class TestData {
  final int id;
  final String name;

  TestData(this.id, this.name);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  static TestData fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return TestData(
      map['id'],
      map['name'],
    );
  }

  String toJson() => json.encode(toMap());

  static TestData fromJson(String source) => fromMap(json.decode(source));
}
