import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:medical_app_belinda_full/calendar/calendar_page.dart';
import 'package:medical_app_belinda_full/notifications.dart';
import 'package:medical_app_belinda_full/screens/add_medicine.dart';
import 'package:medical_app_belinda_full/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
//import 'package:permission_handler/permission_handler.dart';


import 'auth/auth.dart';

/// Displayed as a profile image if the user doesn't have one.
const placeholderImage =
    'https://upload.wikimedia.org/wikipedia/commons/c/cd/Portrait_Placeholder_Square.png';

/// Profile page shows after sign in or registerationg
class ProfilePage extends StatefulWidget {
  // ignore: public_member_api_docs
  const ProfilePage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final storageRef = FirebaseStorage.instance.ref();
  late User user;
  late TextEditingController controller;
  final phoneController = TextEditingController();
  String? photoURL;
  bool showSaveButton = false;
  bool isLoading = false;
  final ImagePicker _picker = ImagePicker();
  File? _image;


  @override
  void initState() {
    user = auth.currentUser!;
    controller = TextEditingController(text: user.displayName);
    controller.addListener(_onNameChanged);

    auth.userChanges().listen((event) {
      if (event != null && mounted) {
        setState(() {
          user = event;
        });
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    controller.removeListener(_onNameChanged);
    super.dispose();
  }

  void setIsLoading() {
    setState(() {
      isLoading = !isLoading;
    });
  }

  void _onNameChanged() {
    setState(() {
      if (controller.text == user.displayName || controller.text.isEmpty) {
        showSaveButton = false;
      } else {
        showSaveButton = true;
      }
    });
  }

  /// Map User provider data into a list of Provider Ids.
  List get userProviders => user.providerData.map((e) => e.providerId).toList();

  Future updateDisplayName() async {
    await user.updateDisplayName(controller.text);

    setState(() {
      showSaveButton = false;
    });

    // ignore: use_build_context_synchronously
    ScaffoldSnackbar.of(context).show('Name updated');
  }

  _imgFromCamera() async {
    final image =
    await _picker.pickImage(source: ImageSource.camera, imageQuality: 50);

    setState(() {
      _image = File(image!.path);
      uploadProfilePics();
    });
  }

  _imgFromGallery() async {
    final image =
    await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);

    setState(() {
      _image = File(image!.path);
      uploadProfilePics();
    });
  }

  void _showPicker() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Wrap(
              children: <Widget>[
                ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: const Text('Photo Library'),
                    onTap: () {
                      _imgFromGallery();
                      Navigator.of(context).pop();
                    }),
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('Camera'),
                  onTap: () {
                    _imgFromCamera();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
        });
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Image.asset('assets/replace.jpg'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text("Do you want to change the current image?")
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Yes'),
              onPressed: () {
                _image = null;
                Navigator.of(context).pop();
                _showPicker();
              },
            ),
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Padding buildImageContainer() {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Container(
        child: _image == null
            ? Column(
          children: [
            IconButton(
              icon: const Icon(
                Icons.camera_alt_outlined,
              ),
              iconSize: 40,
              onPressed: () {
                _showPicker();
              },
            ),
            const Text('Input your lovely Breakfast here!'),
          ],
        )
            : Stack(children: [
          Image.file(
            File(_image!.path),
          ),
          Positioned(
              top: 5,
              right: 0, //give the values according to your requirement
              child: MaterialButton(
                onPressed: () {
                  _showMyDialog();
                },
                color: const Color.fromRGBO(243, 222, 186, 1),
                // padding: EdgeInsets.all(16),
                shape: const CircleBorder(),
                child: const Icon(
                  Icons.edit,
                  size: 24,
                ),
              ))
        ]),
      ),
    );
  }

  Future<void> uploadProfilePics() async {
    String profilePicUrl = "";
    final profileUrl = storageRef.child("Users/${user.uid}/profilePic.jpg");
    UploadTask uploadProfile = profileUrl.putFile(_image!);
    await uploadProfile.whenComplete(() async => {
      profilePicUrl = await profileUrl.getDownloadURL(),
      await user.updatePhotoURL(profilePicUrl),
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: FocusScope.of(context).unfocus,
      child: Scaffold(
        body: Stack(
          children: [
            Center(
              child: SizedBox(
                width: 400,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            maxRadius: 100,
                            backgroundImage: NetworkImage(
                              user.photoURL ?? placeholderImage,
                            ),
                          ),
                          Positioned.directional(
                            textDirection: Directionality.of(context),
                            end: 0,
                            bottom: 0,
                            child: Material(
                              clipBehavior: Clip.antiAlias,
                              color: Theme.of(context).colorScheme.secondary,
                              borderRadius: BorderRadius.circular(40),
                              child: InkWell(
                                onTap: () async {
                                  _showPicker();
                                },
                                radius: 50,
                                child: const SizedBox(
                                  width: 35,
                                  height: 35,
                                  child: Icon(Icons.edit),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        style: const TextStyle(
                          fontSize: 40,
                        ),
                        textAlign: TextAlign.center,
                        controller: controller,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          alignLabelWithHint: true,
                          label: Center(
                            child: Text(
                              'Click to add a display name',
                            ),
                          ),
                        ),
                      ),
                      Text(
                          user.email ?? user.phoneNumber ?? 'User'
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (userProviders.contains('phone'))
                            const Icon(Icons.phone),
                          if (userProviders.contains('password'))
                            const Icon(Icons.mail),
                          if (userProviders.contains('google.com'))
                            SizedBox(
                              width: 24,
                              child: Image.network(
                                'https://upload.wikimedia.org/wikipedia/commons/0/09/IOS_Google_icon.png',
                              ),
                            ),
                        ],
                      ),
                      // const SizedBox(height: 20),
                      // const SizedBox(height: 20),
                      // TextButton(
                      //   onPressed: () async {
                      //     // Navigator.push(
                      //     //   context,
                      //     //   MaterialPageRoute(
                      //     //       builder: (context) => RealTimeFirebase()),
                      //     // );
                      //   },
                      //   child: const Text('Test Firebase'),
                      // ),
                      // TextButton(
                      //   onPressed: () async {
                      //     Navigator.push(
                      //       context,
                      //       MaterialPageRoute(
                      //           builder: (context) => const AddMedPage()),
                      //     );
                      //   },
                      //   child: const Text('Forms Page'),
                      // ),
                      // TextButton(
                      //   onPressed: ()   {
                      //     // Navigator.push(
                      //     //   context,
                      //     //   MaterialPageRoute(
                      //     //       builder: (context) => const ()),
                      //     // );
                      //   },
                      //   child: const Text('Picker Example'),
                      // ),
                      const Divider(),
                      TextButton(
                        onPressed: _signOut,
                        child: const Text(
                            'Sign out',
                          style: TextStyle(
                            fontSize: 24,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) =>  const CalendarPage()));
                        },
                        child: const Text(
                          'Calendar',
                          style: TextStyle(
                            fontSize: 24,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () async  {
                          //await NotificationService().showNotification(title: "love",body: "hug");
                           NotificationService().zonedScheduleAlarmClockNotification();
                        },
                        child: const Text(
                          'Test notifications',
                          style: TextStyle(
                            fontSize: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned.directional(
              textDirection: Directionality.of(context),
              end: 40,
              top: 40,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: !showSaveButton
                    ? SizedBox(key: UniqueKey())
                    : TextButton(
                  onPressed: isLoading ? null : updateDisplayName,
                  child: const Text('Save changes'),
                ),
              ),
            )
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const AddMedPage()),
            );
          },
          label: const Text('Add Your Prescriptions'),
          icon: const Icon(Icons.add),
        ),
      ),
    );
  }


  /// Example code for sign out.
  Future<void> _signOut() async {
    await auth.signOut();
    await GoogleSignIn().signOut();
  }
}
