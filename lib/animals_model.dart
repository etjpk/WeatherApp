import 'package:cloud_firestore/cloud_firestore.dart';

class Animal {
  String id; //id of the document inside firestore's db
  String name; // name of the animal
  int number_of_legs; // number of legs the animal has
  DateTime creation_date; // when the document was added to the db

  Animal({
    this.id = '',
    required this.name,
    required this.number_of_legs,
    required this.creation_date,
  });
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'nubmer_of_legs': number_of_legs,
    'creation_date': creation_date,
  };

  static Animal fromJson(Map<String, dynamic> json) => Animal(
    id: json['id'],
    name: json['name'],
    number_of_legs: json['nubmer_of_legs'],
    creation_date: (json['creation_date'] as Timestamp)
        .toDate(), // import 'package:cloud_firestore/cloud_firestore.dart';
  );
}
