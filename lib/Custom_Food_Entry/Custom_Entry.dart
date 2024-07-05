import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dieter/Custom_Food_Entry/Custom_Entry_Results.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../auth.dart';
import '__custom_entry_state_text_form_field.dart';

class CustomEntry extends StatefulWidget {
  const CustomEntry({super.key});

  @override
  State<CustomEntry> createState() => _CustomEntryState();
}

class _CustomEntryState extends State<CustomEntry> {
  File? _selectedImage;

  final User? user = Auth().currentUser;

  Future<void> _pickImageFromGallery() async {
    try {
      final pickedImage =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedImage != null) {
        setState(() {
          _selectedImage = File(pickedImage.path);
        });
      }
    } catch (e) {
      print("Image picker error: $e");
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final pickedImage =
          await ImagePicker().pickImage(source: ImageSource.camera);
      if (pickedImage != null) {
        setState(() {
          _selectedImage = File(pickedImage.path);
        });
      }
    } catch (e) {
      print("Image picker error: $e");
    }
  }

  void _showCustomSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(
                Icons.photo_library,
                color: Colors.white,
              ),
              onPressed: () {
                _pickImageFromGallery();
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
            const Text('Select an option'),
            IconButton(
              icon: const Icon(
                Icons.camera_alt,
                color: Colors.white,
              ),
              onPressed: () {
                _pickImageFromCamera();
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ],
        ),
      ),
    );
  }

  final _formKey = GlobalKey<FormState>();

  // Controllers for the text fields
  final TextEditingController _foodNameController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _proteinController = TextEditingController();
  final TextEditingController _fatController = TextEditingController();
  final TextEditingController _carbController = TextEditingController();
  final TextEditingController _sugarController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();
  final TextEditingController _sodiumController = TextEditingController();
  final TextEditingController _fiberController = TextEditingController();

  @override
  void dispose() {
    // Dispose of the controllers when the widget is disposed
    _foodNameController.dispose();
    _weightController.dispose();
    _proteinController.dispose();
    _fatController.dispose();
    _carbController.dispose();
    _sugarController.dispose();
    _caloriesController.dispose();
    _sodiumController.dispose();
    _fiberController.dispose();
    super.dispose();
  }

  Future<void> CustomFoods() async {
    try {
      final userUid = user?.uid;
      final userRef =
          FirebaseFirestore.instance.collection('Personals').doc(userUid);
      final custom = userRef.collection('CustomFoodEntry');

      // Upload image to Firebase Storage
      String? imageUrl;
      if (_selectedImage != null) {
        final storageRef = FirebaseStorage.instance.ref().child(
            'custom_food_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
        final uploadTask = storageRef.putFile(_selectedImage!);
        final taskSnapshot = await uploadTask.whenComplete(() => {});
        imageUrl = await taskSnapshot.ref.getDownloadURL();
      }

      await custom.add({
        'Food Name': _foodNameController.text,
        'calories': _caloriesController.text,
        'protein': _proteinController.text,
        'fat': _fatController.text,
        'carbs': _carbController.text,
        'fiber': _fiberController.text,
        'sugar': _sugarController.text,
        'sodium': _sodiumController.text,
        'weight': _weightController.text,
        'image_url': imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data successfully added')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding data: $e')),
      );
      print('Error adding data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFB9DC78),
      appBar: AppBar(
        backgroundColor: Colors.white30,
        title: const Text('Custom Food Entry'),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => CustomDataPage()));
              },
              icon: Icon(Icons.menu_open)),
        ],
      ),
      body: Container(
        /*decoration: new BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Colors.white,
              Colors.green,
            ],
          ),
        ),*/
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    TextFormField(
                      controller: _foodNameController,
                      decoration: InputDecoration(
                        labelText: 'Food Name',
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.black),
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the food name';
                        }
                        return null;
                      },
                    ),
                    Row(
                      children: <Widget>[
                        CustomEntryStateTextFormField(
                          controller: _weightController,
                          labelText: 'Weight (g)',
                        ),
                        CustomEntryStateTextFormField(
                          controller: _fatController,
                          labelText: 'Fats (g)',
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        CustomEntryStateTextFormField(
                          controller: _carbController,
                          labelText: 'Carbs (g)',
                        ),
                        CustomEntryStateTextFormField(
                          controller: _caloriesController,
                          labelText: 'Calories',
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        CustomEntryStateTextFormField(
                          controller: _proteinController,
                          labelText: 'Proteins (g)',
                        ),
                        CustomEntryStateTextFormField(
                          controller: _fiberController,
                          labelText: 'Fiber (g)',
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        CustomEntryStateTextFormField(
                          controller: _sugarController,
                          labelText: 'Sugar (g)',
                        ),
                        CustomEntryStateTextFormField(
                          controller: _sodiumController,
                          labelText: 'Sodium (mg)',
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    IconButton(
                      onPressed: () {
                        _showCustomSnackBar(context);
                      },
                      icon: Icon(
                        Icons.camera_enhance_rounded,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _selectedImage != null
                        ? Image.file(
                            _selectedImage!,
                            width: 200,
                            height: 200,
                            fit: BoxFit.cover,
                          )
                        : const Text(''),
                    IconButton(
                      onPressed: () {
                        if (_selectedImage == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please select an image'),
                            ),
                          );
                          return;
                        }

                        if (_formKey.currentState!.validate()) {
                          CustomFoods();
                        }
                      },
                      icon: Icon(
                        Icons.verified,
                        size: 40,
                      ),
                      //child: const Text('Submit'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
