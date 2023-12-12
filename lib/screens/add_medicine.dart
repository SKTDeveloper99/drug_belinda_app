import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:medical_app_belinda_full/auth/auth.dart';
import 'package:medical_app_belinda_full/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart' as intl;

class AddMedPage extends StatefulWidget {
  const AddMedPage({super.key});

  @override
  State<AddMedPage> createState() => _AddMedPageState();
}

class _AddMedPageState extends State<AddMedPage> {
  final database = FirebaseDatabase.instance.ref();
  final storageRef = FirebaseStorage.instance.ref();
  late User user;
  late TextEditingController controller;
  final phoneController = TextEditingController();
  String? photoURL;
  bool showSaveButton = false;
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();
  String title = '';
  String description = '';
  DateTime date = DateTime.now();
  double maxValue = 0;
  bool? brushedTeeth = false;
  bool enableFeature = false;
  String drug = "";
  bool textScanning = false;
  XFile? imageFile;
  String scannedText = "The Result will come out!";
  List<String>? scannedTextList;
  List<String>? citiesFuture; // the cities future
  List<String>? areasFuture; // the data for the second drop down
  bool loading = false;
  late DatabaseReference todayDrugRef;
  late DatabaseReference drugListRef;
  bool userInteracts() => imageFile != null;

  @override
  void initState() {
    user = auth.currentUser!;
    // final todayDrugRef = database.child("/users/${user.uid}/medLogs");
    // final drugListRef = database.child("/users/${user.uid}/Drugs");
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
    super.dispose();
  }

  Future<String> uploadDrugPics(String key) async {
    String drugPicUrl = "";
    final drugUrl = storageRef.child("Users/${user.uid}/$key-$title.jpg");
    UploadTask uploaddrug = drugUrl.putFile(File(imageFile!.path));
    await uploaddrug.whenComplete(() async => {
      print("love: ${drugUrl.getDownloadURL()}"),
      drugPicUrl = await drugUrl.getDownloadURL(),
    });
    return drugPicUrl.toString();
  }



  Future updateYourDay() async {
    // ignore: use_build_context_synchronously
    ScaffoldSnackbar.of(context).show('Your Day has been updated');
  }

  @override
  Widget build(BuildContext context) {
    //print("love 1: ${scannedTextList.toString()}");
    final todayDrugRef = database.child("/users/${user.uid}/medLogs");
    final drugListRef = database.child("/users/${user.uid}/Drugs");
    var key = database.push().key;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Form widgets'),
      ),
      body: Form(
        key: _formKey,
        child: Scrollbar(
          child: Align(
            alignment: Alignment.topCenter,
            child: Card(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ...[
                        _FormDatePicker(
                          date: date,
                          onChanged: (value) {
                            setState(() {
                              date = value;
                            });
                          },
                        ),
                        TextFormField(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            filled: true,
                            hintText: 'Enter your Drug Description...',
                            labelText: 'Drug Info',
                          ),
                          onChanged: (value) {
                            description = value;
                          },
                          maxLines: 5,
                        ),
                        Center(
                          child: SingleChildScrollView(
                            child: Container(
                                margin: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    if (textScanning) const CircularProgressIndicator(),
                                    if (!textScanning && imageFile == null)
                                      Container(
                                        width: 300,
                                        height: 300,
                                        color: Colors.grey[300]!,
                                      ),
                                    if (imageFile != null) Image.file(File(imageFile!.path)),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                            margin: const EdgeInsets.symmetric(horizontal: 5),
                                            padding: const EdgeInsets.only(top: 10),
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.white,
                                                foregroundColor: Colors.grey,
                                                shadowColor: Colors.grey[400],
                                                elevation: 10,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(8.0)),
                                              ),
                                              onPressed: () {
                                                getImage(ImageSource.gallery);
                                              },
                                              child: Container(
                                                margin: const EdgeInsets.symmetric(
                                                    vertical: 5, horizontal: 5),
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    const Icon(
                                                      Icons.image,
                                                      size: 30,
                                                    ),
                                                    Text(
                                                      "Gallery",
                                                      style: TextStyle(
                                                          fontSize: 13, color: Colors.grey[600]),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            )),
                                        Container(
                                            margin: const EdgeInsets.symmetric(horizontal: 5),
                                            padding: const EdgeInsets.only(top: 10),
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.white,
                                                foregroundColor: Colors.grey,
                                                shadowColor: Colors.grey[400],
                                                elevation: 10,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(8.0)),
                                              ),
                                              onPressed: () {
                                                getImage(ImageSource.camera);
                                              },
                                              child: Container(
                                                margin: const EdgeInsets.symmetric(
                                                    vertical: 5, horizontal: 5),
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    const Icon(
                                                      Icons.camera_alt,
                                                      size: 30,
                                                    ),
                                                    Text(
                                                      "Camera",
                                                      style: TextStyle(
                                                          fontSize: 13, color: Colors.grey[600]),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            )),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    if (scannedTextList == null)
                                      const DropdownMenu(
                                        onSelected: null,
                                        dropdownMenuEntries: [],
                                      ),
                                    if (scannedTextList != null)
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          const Text("Please Select the name of This Drug"),
                                          DropdownMenu<String>(
                                            initialSelection: scannedTextList?.first,
                                            onSelected: (String? value) {
                                              // This is called when the user selects an item.
                                              setState(() {
                                                scannedTextList?.first = value!;
                                                title = value!;
                                              });
                                            },
                                            dropdownMenuEntries: scannedTextList!.map<DropdownMenuEntry<String>>((String value) {
                                              return DropdownMenuEntry<String>(
                                                  value: value,
                                                  label: value

                                              );
                                            }).toList(),
                                          ),
                                        ],
                                      )
                                  ],
                                )),
                          ),
                        ),
                        ElevatedButton(
                          child: const Text("Update your Drug Now!"),
                          onPressed: !userInteracts() ? null : () async {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                });
                            final drugInput = <String, dynamic>{
                              "date": date.millisecondsSinceEpoch,
                              "title": title,
                              "description": description,
                              "medPicURL": await uploadDrugPics(key!),
                              "medURL": "https://www.drugs.com/$title.html",
                            };
                            final drugListInput = <String, dynamic> {
                              title: true,
                            };
                            todayDrugRef
                                .child(key!)
                                .set(drugInput)
                                .then((_) => print('Drug has been posted'))
                                .catchError((error) => print("You got error on $error"));
                            drugListRef
                                .child(key!)
                                .set(drugListInput)
                                .then((_) => print('Drug List has been posted'))
                                .catchError((error) => print("You got error on $error"));
                            await FirebaseFirestore.instance
                                .collection("BeHealthyAppUsers")
                                .doc(user.uid)
                                .set({
                                  "drugsUsing": FieldValue.arrayUnion([title]),
                                },
                                SetOptions(merge: true)
                            );
                            if (context.mounted) {
                              Navigator.popUntil(context, (route) => route.isFirst);
                            }
                            updateYourDay();
                          },
                        ),
                      ].expand(
                            (widget) => [
                          widget,
                          const SizedBox(
                            height: 24,
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void getImage(ImageSource source) async {
    try {
      final pickedImage = await ImagePicker().pickImage(source: source);
      if (pickedImage != null) {
        textScanning = true;
        imageFile = pickedImage;
        getRecognisedText(pickedImage);
        setState(() {
          //userInteracts() => true;
        });
      }
    } catch (e) {
      textScanning = false;
      imageFile = null;
      scannedText = "Error occured while scanning";
      setState(() {});
    }
  }

  void getRecognisedText(XFile image) async {
    List<String> love = [];
    final inputImage = InputImage.fromFilePath(image.path);
    final textDetector = TextRecognizer(script: TextRecognitionScript.latin);
    RecognizedText recognisedText = await textDetector.processImage(inputImage);
    await textDetector.close();
    scannedText = "";
    scannedTextList = [];
    for (TextBlock block in recognisedText.blocks) {
      for (TextLine line in block.lines) {
        scannedText = "$scannedText${line.text}\n";
        love.add(line.text);
      }
    }
    textScanning = false;
    setState(() {
      scannedTextList = love;
    });
  }

}

class _FormDatePicker extends StatefulWidget {
  final DateTime date;
  final ValueChanged<DateTime> onChanged;

  const _FormDatePicker({
    required this.date,
    required this.onChanged,
  });

  @override
  State<_FormDatePicker> createState() => _FormDatePickerState();
}

class _FormDatePickerState extends State<_FormDatePicker> {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              'Date',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Text(
              intl.DateFormat.yMd().format(widget.date),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        TextButton(
          child: const Text('Edit'),
          onPressed: () async {
            var newDate = await showDatePicker(
              context: context,
              initialDate: widget.date,
              firstDate: DateTime(1900),
              lastDate: DateTime(2100),
            );

            // Don't change the date if the date picker returns null.
            if (newDate == null) {
              return;
            }
            widget.onChanged(newDate);
          },
        )
      ],
    );
  }
}


