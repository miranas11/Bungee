import 'dart:io';
import 'package:Bungee/models/user.dart';
import 'package:Bungee/pages/home.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as Im;
import 'package:uuid/uuid.dart';

class Upload extends StatefulWidget {
  final User currentUser;
  Upload({this.currentUser});
  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  TextEditingController locationController = TextEditingController();
  TextEditingController captionController = TextEditingController();
  File file;
  bool isUploading = false;
  //stores unique string in postID
  String postID = Uuid().v4();
  final GeolocatorPlatform geolocator = GeolocatorPlatform.instance;

  openCamera() async {
    Navigator.pop(context);
    PickedFile tempfile = await ImagePicker()
        .getImage(source: ImageSource.camera, maxHeight: 700, maxWidth: 1000);

    file = File(tempfile.path);

    setState(() {
      this.file = File(tempfile.path);
    });
  }

  getlocation() async {
    Position position = await GeolocatorPlatform.instance
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Address> location = await Geocoder.local.findAddressesFromCoordinates(
      Coordinates(position.latitude, position.longitude),
    );
    Address address = location[1];
    locationController.text = '${address.locality}, ${address.countryName} ';
  }

  openGallery() async {
    Navigator.pop(context);
    PickedFile tempfile = await ImagePicker()
        .getImage(source: ImageSource.gallery, maxHeight: 700, maxWidth: 1000);
    setState(() {
      this.file = File(tempfile.path);
    });
  }

  selectImage(parentcontext) {
    return showDialog(
      context: parentcontext,
      builder: (context) {
        return SimpleDialog(
          title: Text('Create Post'),
          children: [
            SimpleDialogOption(
              child: Text('Take from Camera'),
              onPressed: () => openCamera(),
            ),
            SimpleDialogOption(
              child: Text('Select from Gallery'),
              onPressed: () => openGallery(),
            )
          ],
        );
      },
    );
  }

  Container buildDefaultScreen() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SvgPicture.asset(
            'assets/images/upload.svg',
            height: 250,
          ),
          SizedBox(
            height: 30,
          ),
          RaisedButton(
            onPressed: () => selectImage(context),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            color: Theme.of(context).accentColor,
            child: Text(
              'Upload Image',
              style: TextStyle(
                color: Colors.white,
                fontSize: 23,
              ),
            ),
          )
        ],
      ),
    );
  }

  clearImage() {
    setState(() {
      file = null;
    });
  }

  compressImage() async {
    final tempdir = await getTemporaryDirectory();
    final path = tempdir.path;
    Im.Image imagefile = Im.decodeImage(file.readAsBytesSync());
    final compressedfile = File('$path/img_$postID.jpg')
      ..writeAsBytesSync(
        Im.encodeJpg(imagefile, quality: 50),
      );
    setState(() {
      file = compressedfile;
    });
  }

  Future<String> uploadImage(imagefile) async {
    StorageUploadTask uploadTask =
        storageref.child('post_$postID.jpg').putFile(imagefile);
    StorageTaskSnapshot storagesnap = await uploadTask.onComplete;
    String downloadUrl = await storagesnap.ref.getDownloadURL();
    return downloadUrl;
  }

  createpostinFireStore({String mediaUrl, String location, String caption}) {
    postref.doc(widget.currentUser.id).collection('userposts').doc(postID).set({
      'postId': postID,
      'ownerId': widget.currentUser.id,
      'username': widget.currentUser.username,
      'mediaUrl': mediaUrl,
      'description': caption,
      'location': location,
      'timestamp': timestamp,
      'likes': {},
    });
  }

  handlePost() async {
    setState(() {
      isUploading = true;
    });
    await compressImage();
    String mediaUrl = await uploadImage(file);
    createpostinFireStore(
      mediaUrl: mediaUrl,
      location: locationController.text,
      caption: captionController.text,
    );

    locationController.clear();
    captionController.clear();
    setState(() {
      isUploading = false;
      postID = Uuid().v4();
      file = null;
    });
  }

  Scaffold buildUploadForm() {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.1,
        backgroundColor: Colors.white70,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: clearImage,
        ),
        title: Text(
          '                Caption Post',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          FlatButton(
            onPressed: isUploading ? null : () => handlePost(),
            child: Text(
              'Post',
              style: TextStyle(
                fontSize: 18,
                color: Colors.teal,
              ),
            ),
          )
        ],
      ),
      body: ListView(
        children: <Widget>[
          isUploading ? LinearProgressIndicator() : Text(''),
          Container(
            alignment: Alignment.center,
            height: 220,
            width: MediaQuery.of(context).size.width * 0.8,
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: FileImage(file),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundImage:
                  CachedNetworkImageProvider(widget.currentUser.photoUrl),
            ),
            title: TextField(
              controller: captionController,
              decoration: InputDecoration(
                hintText: 'Write a Caption',
                border: InputBorder.none,
              ),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(
              Icons.pin_drop,
              color: Colors.orange,
              size: 35,
            ),
            title: TextField(
              controller: locationController,
              decoration: InputDecoration(
                hintText: 'Where was the photo taken?',
                border: InputBorder.none,
              ),
            ),
          ),
          Container(
            alignment: Alignment.center,
            height: 100,
            width: 200,
            child: RaisedButton.icon(
              color: Colors.orange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              onPressed: () => getlocation(),
              icon: Icon(
                Icons.my_location,
                color: Colors.white,
              ),
              label: Text(
                'Use Current Location',
                style: TextStyle(color: Colors.white),
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return file == null ? buildDefaultScreen() : buildUploadForm();
  }
}
