import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:to_do_list_app/api/apis.dart';
import 'package:to_do_list_app/helper/global.dart';
import 'package:to_do_list_app/screens/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _image;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _image = '';
  }

  @override
  Widget build(BuildContext context) {
    initMediaQuery(context);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.cyan.withOpacity(0.5),
        elevation: 0,
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: FloatingActionButton.extended(
          backgroundColor: Colors.red,
          onPressed: () async {
            await APIs.auth.signOut().then((value) async {
              await GoogleSignIn().signOut().then((_) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LoginScreen(() {
                      Navigator.pop(context);
                    }),
                  ),
                );
              });
            });
          },
          icon: const Icon(Icons.logout),
          label: const Text('Logout'),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: APIs.user != null
            ? APIs.firestore.collection('users').doc(APIs.user!.uid).snapshots()
            : null,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              snapshot.connectionState == ConnectionState.none) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('User data not found'));
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;
          final String name = userData['name'] ?? 'No Name';
          final String email = userData['email'] ?? 'No Email';
          final String about = userData['about'] ?? 'No About Information';
          final String imageUrl = userData['image'] ?? '';

          // Initialize controllers with the user data
          _nameController.text = name;
          _aboutController.text = about;

          return SingleChildScrollView(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.teal.withOpacity(0.5), Colors.blue.shade300],

                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: mq.height * 0.03, horizontal: mq.width*0.02),
                        child: Column(
                          children: [
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                CircleAvatar(
                                  radius: 75,
                                  backgroundImage: imageUrl.isNotEmpty
                                      ? NetworkImage(imageUrl)
                                      : const AssetImage('assets/images/default_profile.png') as ImageProvider,
                                  backgroundColor: Colors.grey[300],
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: -10,
                                  child: MaterialButton(
                                    elevation: 5,
                                    onPressed: () {
                                      _showBottomSheet();
                                    },
                                    shape: const CircleBorder(),
                                    color: Colors.white,
                                    child: const Icon(Icons.edit, color: Colors.blue),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: mq.height * 0.02),
                            Text(
                              name,
                              style: TextStyle(
                                fontSize: mq.width * 0.04,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: mq.height * 0.01),
                            Text(
                              email,
                              style: TextStyle(
                                fontSize: mq.width * 0.03,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: mq.height * 0.04),
                    Card(
                      // margin: EdgeInsets.symmetric(horizontal: mq.width * 0.01),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 4,
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: mq.height*0.015, horizontal: mq.width*0.02),
                        child: Column(
                          children: [
                            Text(
                              'About Me',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: mq.height * 0.015),
                            Text(
                              _aboutController.text,
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: mq.height * 0.02),
                            ElevatedButton(
                              onPressed: () {
                                _showEditProfileDialog();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: custom_green,
                                minimumSize: Size(mq.width * 0.5, 50),
                                shape: const StadiumBorder(),
                              ),
                              child: const Text(
                                'Edit Profile',
                                style: TextStyle(color: Colors.white, fontSize: 16),
                              ),
                            ),
                            SizedBox(height: mq.height * 0.007),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: mq.height * 0.05),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showEditProfileDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Profile'),
          content: SizedBox(
            width: double.maxFinite,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _aboutController,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'About'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter about information';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  APIs.updateUserInfo(
                    _nameController.text, // This line is retained for consistency but will not be used
                    _aboutController.text,
                  ).then((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Profile Updated Successfully')),
                    );
                    Navigator.of(context).pop();
                  }).catchError((e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to update profile: $e')),
                    );
                  });
                }
              },
              child: Text('Update Profile', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: custom_green),
            ),
          ],
        );
      },
    );
  }

  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      builder: (_) {
        return ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: mq.height * 0.3,
          ),
          child: ListView(
            padding: EdgeInsets.symmetric(vertical: mq.height * 0.02),
            children: [
              Center(
                child: const Text(
                  'Pick Profile Picture',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                ),
              ),
              SizedBox(height: mq.height * 0.02),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: const CircleBorder(),
                      fixedSize: Size(mq.width * 0.3, mq.height * 0.15),
                    ),
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                      if (image != null) {
                        setState(() {
                          _image = image.path;
                        });
                        Navigator.pop(context);
                      }
                    },
                    child: Image.asset('assets/images/add_image.png'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: const CircleBorder(),
                      fixedSize: Size(mq.width * 0.3, mq.height * 0.15),
                    ),
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      final XFile? image = await picker.pickImage(source: ImageSource.camera);
                      if (image != null) {
                        setState(() {
                          _image = image.path;
                        });
                        Navigator.pop(context);
                      }
                    },
                    child: Image.asset('assets/images/camera.png'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}