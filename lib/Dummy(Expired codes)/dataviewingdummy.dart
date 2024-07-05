/*
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'home_page.dart';

class DataViewing extends StatefulWidget {
  const DataViewing({Key? key}) : super(key: key);

  @override
  State<DataViewing> createState() => _DataViewingState();
}

class _DataViewingState extends State<DataViewing> {
  final User? user = FirebaseAuth.instance.currentUser;
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final weightController = TextEditingController();
  final heightController = TextEditingController();
  late TextEditingController activityLevelController;

  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;

  String _currentGender = 'Male';
  final List<String> _genderOptions = ['Male', 'Female', 'Other'];
  double _currentSliderValue = 5;

  @override
  void initState() {
    super.initState();
    activityLevelController = TextEditingController();
    _initializeControllers();
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
          heightController.text = data['height']?.toString() ?? '';
          weightController.text = data['weight']?.toString() ?? '';
          _currentGender = data['gender'] ?? 'Male';
          _currentSliderValue =
              (data['activityLevel'] as num?)?.toDouble() ?? 5.0;
          activityLevelController.text = _currentSliderValue.toString();
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
        'gender': _currentGender,
        'age': int.tryParse(ageController.text) ?? 0,
        'height': double.tryParse(heightController.text) ?? 0,
        'weight': double.tryParse(weightController.text) ?? 0,
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
      appBar: AppBar(
        title: Text('Data Viewing'),
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
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (user == null) {
      return Center(child: Text('No user logged in'));
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('Personals')
          .doc(user!.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        var data = snapshot.data?.data();
        if (data != null) {
          nameController.text = data['name'] ?? '';
          ageController.text = data['age']?.toString() ?? '';
          heightController.text = data['height']?.toString() ?? '';
          weightController.text = data['weight']?.toString() ?? '';
          _currentGender = data['gender'] ?? 'Male';
          _currentSliderValue =
              (data['activityLevel'] as num?)?.toDouble() ?? 5.0;
          activityLevelController.text = _currentSliderValue.toString();
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: 'Name'),
                    enabled: _isEditing,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  DropdownButtonFormField<String>(
                    value: _currentGender,
                    items: _genderOptions.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: _isEditing
                        ? (newValue) {
                            setState(() {
                              _currentGender = newValue!;
                            });
                          }
                        : null,
                    decoration: InputDecoration(labelText: 'Gender'),
                  ),
                  TextFormField(
                    controller: ageController,
                    decoration: InputDecoration(labelText: 'Age'),
                    enabled: _isEditing,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your age';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: heightController,
                    decoration: InputDecoration(labelText: 'Height (cm)'),
                    enabled: _isEditing,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your height';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: weightController,
                    decoration: InputDecoration(labelText: 'Weight (kg)'),
                    enabled: _isEditing,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your weight';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  Text('Rate your activity level (1 is low, 10 is high)'),
                  Slider(
                    value: _currentSliderValue,
                    max: 10,
                    divisions: 10,
                    label: _currentSliderValue.round().toString(),
                    onChanged: _isEditing
                        ? (double value) {
                            setState(() {
                              _currentSliderValue = value;
                              activityLevelController.text = value.toString();
                            });
                          }
                        : null,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_isEditing &&
                          _formKey.currentState?.validate() == true) {
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
                    child: Text(_isEditing ? 'Save' : 'Edit'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
*/
