import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../Login_Signup/home_page.dart';

class DataViewing extends StatefulWidget {
  const DataViewing({super.key});

  @override
  State<DataViewing> createState() => _DataViewingState();
}

class _DataViewingState extends State<DataViewing> {
  final User? user = FirebaseAuth.instance.currentUser;
  final Map<String, TextEditingController> _controllers = {};
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;

  String _currentGender = 'Male';
  final List<String> _genderOptions = ['Male', 'Female', 'Other'];
  double _currentSliderValue = 5;

  @override
  void initState() {
    super.initState();
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
      setState(() {
        if (data != null) {
          _controllers['name'] =
              TextEditingController(text: data['name'] ?? '');
          _controllers['email'] =
              TextEditingController(text: data['email'] ?? '');
          _controllers['age'] =
              TextEditingController(text: data['age']?.toString() ?? '');
          _controllers['height'] =
              TextEditingController(text: data['height']?.toString() ?? '');
          _controllers['weight'] =
              TextEditingController(text: data['weight']?.toString() ?? '');
          _currentGender = data['gender'] ?? 'Male';
          _currentSliderValue =
              (data['activityLevel'] as num?)?.toDouble() ?? 5.0;
        } else {
          _controllers['name'] = TextEditingController();
          _controllers['email'] = TextEditingController(text: user?.email);
          _controllers['age'] = TextEditingController();
          _controllers['height'] = TextEditingController();
          _controllers['weight'] = TextEditingController();
        }
      });
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
        'name': _controllers['name']?.text,
        'email': _controllers['email']?.text,
        'gender': _currentGender,
        'age': int.tryParse(_controllers['age']?.text ?? ''),
        'height': double.tryParse(_controllers['height']?.text ?? ''),
        'weight': double.tryParse(_controllers['weight']?.text ?? ''),
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
        title: Text('Data Updating'),
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
          return Center(
              child: Image.asset(
            'assets/gif/food_indicator.gif',
            height: 100,
            width: 100,
          ));
        }

        var data = snapshot.data?.data();
        if (data != null) {
          _controllers['name']?.text = data['name'] ?? '';
          _controllers['email']?.text = data['email'] ?? '';
          _controllers['age']?.text = data['age']?.toString() ?? '';
          _controllers['height']?.text = data['height']?.toString() ?? '';
          _controllers['weight']?.text = data['weight']?.toString() ?? '';
          _currentGender = data['gender'] ?? 'Male';
          _currentSliderValue =
              (data['activityLevel'] as num?)?.toDouble() ?? 5.0;
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextFormField(
                      controller: _controllers['name'],
                      decoration: InputDecoration(
                          labelText: 'Name',
                          border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                              borderRadius: BorderRadius.circular(15)),
                          icon: Icon(Icons.person)),
                      enabled: _isEditing,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      controller: _controllers['email'],
                      decoration: InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                              borderRadius: BorderRadius.circular(15)),
                          icon: Icon(Icons.mail)),
                      enabled: false, // Email should not be editable
                    ),
                    SizedBox(
                      height: 20,
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
                      decoration: InputDecoration(
                          labelText: 'Gender',
                          border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                              borderRadius: BorderRadius.circular(15)),
                          icon: Icon(Icons.account_box_outlined)),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      controller: _controllers['age'],
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
                    SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      controller: _controllers['height'],
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
                    SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      controller: _controllers['weight'],
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
                          navigateToHomePage();
                        }
                      },
                      child: Text('Submit'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
