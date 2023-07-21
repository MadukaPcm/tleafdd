import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class ImageCaptureScreen extends StatefulWidget {
  @override
  _ImageCaptureScreenState createState() => _ImageCaptureScreenState();
}

class _ImageCaptureScreenState extends State<ImageCaptureScreen> {
  File? _image;
  final picker = ImagePicker();
  // String _rr = '';
  var rr = '';

  Future getImageFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  Future getImageFromCamera() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  void displayResponse(String response) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('API Response'),
          content: Text(response),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future sendImageToAPI() async {
    if (_image != null) {
      String url = 'http://192.168.43.43:8000/upload-image/';

      // Create a multipart request
      var request = http.MultipartRequest('POST', Uri.parse(url));
      // Attach the image file
      // request.fields['image_path'] = _image!.path;
      request.files
          .add(await http.MultipartFile.fromPath('image', _image!.path));

      // Send the request and get the response
      var response = await request.send();

      if (response.statusCode == 201) {
        String responseBody = await response.stream.bytesToString();
        // Assuming the response body is in JSON format: {"message": "Your message here"}
        var data = jsonDecode(responseBody);
        var message = data['rr'];

        setState(() {
          rr = message;
        });
        // return responseBody;
      } else {
        setState(() {
          rr = 'Failed to upload image';
        });
        print('Error uploading image. Status code: ${response.statusCode}');
        // return null;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload|capture tomato leaf img'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _image != null
                ? Image.file(
                    _image!,
                    height: 200,
                  )
                : Text('No image selected'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: getImageFromGallery,
              child: Text('Select from Gallery'),
            ),
            ElevatedButton(
              onPressed: getImageFromCamera,
              child: Text('Capture from Camera'),
            ),
            ElevatedButton(
              onPressed: sendImageToAPI,
              child: Text('predict'),
            ),
            const SizedBox(height: 20),
            Text(rr),
          ],
        ),
      ),
    );
  }
}
