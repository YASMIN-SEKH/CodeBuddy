import 'package:codebuddy/background.dart';
import 'package:codebuddy/otp_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  bool isLoading = false;

  Future<void> saveUserToFirestore(String name, String phoneNumber) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(phoneNumber).set({
        'name': name,
        'phone': phoneNumber,
        'created_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving user data: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Signup"),
          centerTitle: true,
        ),
        body: GradientBackground(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: TextField(
                  textAlign: TextAlign.center,
                  controller: nameController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      helperStyle: const TextStyle(fontSize: 10),
                      hintText: "Enter Your Name",
                      prefixIcon:
                      const Icon(Icons.person, applyTextScaling: true),
                      contentPadding: const EdgeInsets.symmetric(vertical: 20),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24))),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: TextField(
                  textAlign: TextAlign.center,
                  inputFormatters: [LengthLimitingTextInputFormatter(10)],
                  controller: phoneNumberController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      helperStyle: const TextStyle(fontSize: 15),
                      hintText: "Enter Phone Number",
                      prefixIcon:
                      const Icon(Icons.phone, applyTextScaling: true),
                      contentPadding: const EdgeInsets.symmetric(vertical: 20),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24))),
                ),
              ),
              const SizedBox(height: 15),
              if (isLoading)
                const CircularProgressIndicator(), // Show loading spinner
              const SizedBox(height: 15),
              ElevatedButton(
                  onPressed: () async {
                    if (isLoading) return;
                    if (nameController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Error: Name field cannot be empty"),
                            duration: Durations.extralong4),
                      );
                      return;
                    }
                    if (phoneNumberController.text.isEmpty ||
                        phoneNumberController.text.length != 10) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              "Error: Phone number field cannot be empty and should be 10 lengths long."),
                          duration: Durations.extralong4,
                        ),
                      );
                      return;
                    }
                    setState(() {
                      isLoading = true;
                    });

                    await saveUserToFirestore(
                        nameController.text, phoneNumberController.text);

                    await FirebaseAuth.instance.verifyPhoneNumber(
                        verificationCompleted:
                            (PhoneAuthCredential credential) {},
                        verificationFailed: (FirebaseAuthException ex) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    "VerificationFailed, Error: ${ex.toString()}")),
                          );
                          setState(() {
                            isLoading = false;
                          });
                        },
                        codeSent: (String verificationId, int? resendToken) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => OtpScreen(

                                    verificationId: verificationId,
                                    name: nameController.text,
                                  )));

                                        verificationId: verificationId,
                                      name: nameController.text.isNotEmpty ? nameController.text : "Code Buddy"
                                      )));

                          setState(() {
                            isLoading = false;
                          });
                        },
                        codeAutoRetrievalTimeout: (String verificationId) {},
                        phoneNumber:
                        "+91${phoneNumberController.text}"); //todo allow different codes
                  },
                  child: const Text("Send OTP")),
            ],
          ),
        ));
  }
}
