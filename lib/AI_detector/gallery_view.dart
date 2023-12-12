import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';



class GalleryView extends StatefulWidget {
  GalleryView(
      {Key? key,
        required this.title,
        required this.textBlock,
        this.text,
        required this.onImage,
        required this.onDetectorViewModeChanged})
      : super(key: key);

  final String title;
  final List<String> textBlock;
  final String? text;
  final Function(InputImage inputImage) onImage;
  final Function()? onDetectorViewModeChanged;

  @override
  State<GalleryView> createState() => _GalleryViewState();
}

class _GalleryViewState extends State<GalleryView> {
  File? _image;
  String? _path;
  ImagePicker? _imagePicker;
  String title = "";

  @override
  void initState() {
    super.initState();

    _imagePicker = ImagePicker();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          // actions: [
          //   Padding(
          //     padding: const EdgeInsets.only(right: 20.0),
          //     child: GestureDetector(
          //       onTap: widget.onDetectorViewModeChanged,
          //       child: Icon(
          //         Platform.isIOS ? Icons.camera_alt_outlined : Icons.camera,
          //       ),
          //     ),
          //   ),
          // ],
        ),
        body: galleryBody());
  }

  Widget galleryBody() {
    return ListView(shrinkWrap: true, children: [
      _image != null
          ? SizedBox(
        height: 400,
        width: 400,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Image.file(_image!),
          ],
        ),
      )
          : const Icon(
        Icons.image,
        size: 200,
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ElevatedButton(
          child: const Text('From Gallery'),
          onPressed: () => _getImage(ImageSource.gallery),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ElevatedButton(
          child: const Text('Take a picture'),
          onPressed: () => _getImage(ImageSource.camera),
        ),
      ),
      if (_image != null)
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Text("number of recognized texts: ${widget.textBlock.length.toString()}"),
              if (widget.textBlock != null)
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text("Please Select the number of Your Water Meter"),
                    DropdownMenu<String>(
                      initialSelection:  (widget.textBlock!.isNotEmpty) ? widget.textBlock?.first : "Nothing",
                      onSelected: (String? value) {
                        // This is called when the user selects an item.
                        setState(() {
                          widget.textBlock?.first = value!;
                          title = value!;
                        });
                      },
                      dropdownMenuEntries: widget.textBlock!.map<DropdownMenuEntry<String>>((String value) {
                        return DropdownMenuEntry<String>(
                            value: value,
                            label: value

                        );
                      }).toList(),
                    ),
                  ],
                ),
              ElevatedButton(
                onPressed: () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => ResultPage(listRecognized: widget.textBlock,waterMeter: title,image: _image!,)),
                  // );
                },
                child: const Text("Data Result"),
              ),
            ],
          ),//${_path == null ? '' : 'Image path: $_path'}\n\n
        ),
    ]);
  }

  Future _getImage(ImageSource source) async {
    setState(() {
      _image = null;
      _path = null;
    });
    final pickedFile = await _imagePicker?.pickImage(source: source);
    if (pickedFile != null) {
      _processFile(pickedFile.path);
    }
  }

  Future _processFile(String path) async {
    setState(() {
      _image = File(path);
    });
    _path = path;
    final inputImage = InputImage.fromFilePath(path);
    widget.onImage(inputImage);
  }
}