import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:to_do_list_app/helper/note.dart';
import 'package:to_do_list_app/models/app_user.dart';
import 'package:uuid/uuid.dart';

class APIs {
  static FirebaseAuth auth = FirebaseAuth.instance;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  // static final user = FirebaseAuth.instance.currentUser;
  static late AppUser me;

  static User? get user => auth.currentUser;

  static Future<bool> userExists() async {
    final currentUser = user;
    if (currentUser == null) {
      return false;
    }
    return (await firestore.collection('users').doc(currentUser.uid).get()).exists;
  }

  static Future<void> getSelfInfo() async {
    final currentUser = user;
    if (currentUser == null) {
      throw Exception('User not logged in');
    }
    await firestore.collection('users').doc(currentUser.uid).get().then((user) async {
      if (user.exists) {
        me = AppUser.fromJson(user.data()!);
      } else {
        await createUser(name: '').then((value) => getSelfInfo());
      }
    });
  }

  static Future<void> createUser({required String name}) async {
    final currentUser = user;
    if (currentUser == null) {
      throw Exception('User not logged in');
    }
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final chatUser = AppUser(
        about: "Hey there, I'm using my To Do List App!",
        createdAt: time,
        email: currentUser.email.toString(),
        id: currentUser.uid,
        image: currentUser.photoURL.toString(),
        name: currentUser.displayName.toString(),
        pushToken: ''
    );
    return await firestore.collection('users').doc(currentUser.uid).set(chatUser.toJson());
  }

  static Future<void> updateUserInfo(String name, String about) async {
    try {
      if (user == null) return;
      await firestore.collection('users').doc(user!.uid).update({
        'name': name,
        'about': about,
      });
    } catch (e) {
      print('Failed to update user info: $e');
      throw e;
    }
  }

  static Future<void> logout() async {
    try {
      await auth.signOut();
    } catch (e) {
      print("Error signing out: $e");
    }
  }

  Future<void> addTask(String task, String details, DateTime time) async {
    try {
      var uuid = const Uuid().v4();
      await firestore.collection('users')
          .doc(auth.currentUser!.uid)
          .collection('notes')
          .doc(uuid).set({
        'id': uuid,
        'details': details,
        'isDon': false,
        'time': time,
        'task title': task,
      });
    } catch (e) {
      print("Error adding note: $e");
    }
  }


  List<Task> getNotes(AsyncSnapshot snapshot) {
    try {
      final notesList = snapshot.data.docs.map<Task>((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Task(
          id: doc.id, // Use Firestore document ID as the 'id'
          details: data['details'] ?? '',
          time: (data['time'] as Timestamp).toDate(),
          task: data['task title'] ?? '',
        );
      }).toList();
      return notesList;
    } catch (e) {
      print("Error parsing notes: $e");
      return [];
    }
  }

  static Stream<QuerySnapshot> stream() {
    return firestore.collection('users').doc(auth.currentUser!.uid).collection('notes').snapshots();
  }

  Future<bool> isdone(String uuid, bool isDon) async {
    try {
      await firestore.collection('users')
          .doc(auth.currentUser!.uid)
          .collection('notes')
          .doc(uuid).update({'isDon': isDon});
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }
}