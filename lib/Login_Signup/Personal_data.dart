import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../auth.dart';
import 'home_page.dart';

class PersonalData extends StatefulWidget {
  const PersonalData({Key? key}) : super(key: key);

  @override
  State<PersonalData> createState() => _PersonalDataState();
}

List<String> options = ['Male', 'Female', 'Others'];

class _PersonalDataState extends State<PersonalData> {
  final User? user = Auth().currentUser;
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final weightController = TextEditingController();
  final heightController = TextEditingController();
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String currentOption = options[0];
  double _currentSliderValue = 5;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _emailController.text = user?.email ?? '';
    _initializeControllers();
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    weightController.dispose();
    heightController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _initializeControllers() async {
    if (user != null) {
      DocumentSnapshot<Map<String, dynamic>> doc = await FirebaseFirestore
          .instance
          .collection('Personals')
          .doc(user!.uid)
          .get();

      Map<String, dynamic>? data = doc.data();
      if (data != null) {
        setState(() {
          nameController.text = data['name'] ?? '';
          ageController.text = data['age']?.toString() ?? '';
          weightController.text = data['weight']?.toString() ?? '';
          heightController.text = data['height']?.toString() ?? '';
          currentOption = data['gender'] ?? 'Male';
          _currentSliderValue =
              (data['activityLevel'] as num?)?.toDouble() ?? 5.0;
        });
      }
    }
  }

  void navigateToHomePage() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  }

  Future<void> _saveData() async {
    if (user != null) {
      Map<String, dynamic> dataToUpdate = {
        'name': nameController.text,
        'email': _emailController.text,
        'gender': currentOption,
        'age': int.tryParse(ageController.text),
        'height': double.tryParse(heightController.text),
        'weight': double.tryParse(weightController.text),
        'activityLevel': _currentSliderValue,
      };
      await FirebaseFirestore.instance
          .collection('Personals')
          .doc(user!.uid)
          .set(dataToUpdate, SetOptions(merge: true));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFB9DC78),
      appBar: AppBar(
        backgroundColor: Colors.white60,
        title: Text('Personal Data'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (_isEditing && _formKey.currentState?.validate() == true) {
                _formKey.currentState?.save();
                _saveData();
                setState(() {
                  _isEditing = false;
                });
              } else {
                setState(() {
                  _isEditing = true;
                });
              }
            },
          )
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                          borderRadius: BorderRadius.circular(15)),
                      icon: Icon(Icons.person)),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                  enabled: _isEditing,
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                          borderRadius: BorderRadius.circular(15)),
                      icon: Icon(Icons.mail)),
                  enabled: false, // Email should not be editable
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: ageController,
                  decoration: InputDecoration(
                      labelText: 'Age',
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                          borderRadius: BorderRadius.circular(15)),
                      icon: Icon(Icons.accessible)),
                  enabled: _isEditing,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your age';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: weightController,
                  decoration: InputDecoration(
                      labelText: 'Weight (kg)',
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                          borderRadius: BorderRadius.circular(15)),
                      icon: Icon(Icons.waterfall_chart)),
                  enabled: _isEditing,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your weight';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: heightController,
                  decoration: InputDecoration(
                      labelText: 'Height (cm)',
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                          borderRadius: BorderRadius.circular(15)),
                      icon: Icon(Icons.h_plus_mobiledata_outlined)),
                  enabled: _isEditing,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your height';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: currentOption,
                  items: options.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: _isEditing
                      ? (newValue) {
                          setState(() {
                            currentOption = newValue!;
                          });
                        }
                      : null,
                  decoration: InputDecoration(
                      labelText: 'Gender',
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                          borderRadius: BorderRadius.circular(15)),
                      icon: Icon(Icons.account_box_outlined)),
                ),
                SizedBox(height: 20),
                Text('Rate your activity level (1 is low, 10 is high)'),
                Text('(Your Level: ${_currentSliderValue.round()})'),
                Slider(
                  value: _currentSliderValue,
                  max: 10,
                  divisions: 10,
                  label: _currentSliderValue.round().toString(),
                  onChanged: _isEditing
                      ? (double value) {
                          setState(() {
                            _currentSliderValue = value;
                          });
                        }
                      : null,
                ),
                SizedBox(height: 20),
                IconButton(
                  onPressed: () {
                    if (_isEditing &&
                        _formKey.currentState?.validate() == true) {
                      _formKey.currentState?.save();
                      _saveData();
                      setState(() {
                        _isEditing = false;
                      });
                      navigateToHomePage();
                    }
                  },
                  icon: Icon(
                    Icons.verified_outlined,
                    size: 40,
                  ),
                  //child: Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
