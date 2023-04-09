import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:wsa/homePage.dart';

class profile extends StatefulWidget {
  const profile({Key? key}) : super(key: key);

  @override
  State<profile> createState() => _profileState();
}

class _profileState extends State<profile> {

  final FirebaseStorage storage = FirebaseStorage.instance;

  final NameController = TextEditingController();
  final DescriptionController = TextEditingController();
  final PhotoUrlController = TextEditingController();
  final LinkController = TextEditingController();


  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    NameController.dispose();
    DescriptionController.dispose();
    PhotoUrlController.dispose();
    LinkController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange.shade300,
      body: SafeArea(
        child: Column(
          children: [
            Text("Create Profile Page",style: TextStyle(color: Colors.blueGrey,fontSize: 30,fontWeight: FontWeight.w500),),
            Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 15, top: 8, bottom: 5),
                        child: Text(
                          "Full Name",
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500, color: Colors.white),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10, bottom: 3, right: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            border: Border.all(color: Colors.white),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: TextFormField(
                              //obscureText: true,
                              controller: NameController,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Enter Full name',
                              ),
                            ),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Flexible(
                            flex:1,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 15, top: 8, bottom: 5),
                                  child: Text(
                                    "Age",
                                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500, color: Colors.white),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 10, bottom: 3, right: 10),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      border: Border.all(color: Colors.white),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 20),
                                      child: TextFormField(
                                        //obscureText: true,
                                        controller: NameController,
                                        textInputAction: TextInputAction.next,
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          hintText: 'Enter Age',
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Flexible(
                            flex:2,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 15, top: 8, bottom: 5),
                                  child: Text(
                                    "Phone Number",
                                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500, color: Colors.white),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 10, bottom: 3, right: 10),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      border: Border.all(color: Colors.white),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 20),
                                      child: TextFormField(
                                        //obscureText: true,
                                        controller: NameController,
                                        textInputAction: TextInputAction.next,
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          hintText: 'Enter Phone Number',
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),

                      Padding(
                        padding: const EdgeInsets.only(left: 15, top: 8, bottom: 5),
                        child: Text(
                          "Email",
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500, color: Colors.white),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10, bottom: 3, right: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            border: Border.all(color: Colors.white),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: TextFormField(
                              //obscureText: true,
                              controller: NameController,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Enter Email',
                              ),
                            ),
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(left: 15, top: 8, bottom: 5),
                        child: Text(
                          "Father Name",
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500, color: Colors.white),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10, bottom: 3, right: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            border: Border.all(color: Colors.white),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: TextFormField(
                              //obscureText: true,
                              controller: NameController,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Enter Father Name',
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 15, top: 8, bottom: 5),
                        child: Text(
                          "Father Phone Number",
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500, color: Colors.white),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10, bottom: 3, right: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            border: Border.all(color: Colors.white),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: TextFormField(
                              //obscureText: true,
                              controller: NameController,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Enter Father Phone Number',
                              ),
                            ),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Spacer(),
                          Padding(
                            padding: const EdgeInsets.only(right: 20,top: 10),
                            child: InkWell(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15)
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      Text("Create and Next ",style: TextStyle(fontSize: 20),),
                                      Icon(Icons.arrow_forward_ios_sharp,color: Colors.greenAccent,)
                                    ],
                                  ),
                                ),
                              ),
                              onTap: (){
                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>HomePage()));
                              },
                            ),
                          )
                        ],
                      )
                      ],
                  ),
                ))
          ],
        ),
      ),
    );
  }
}

// Stream<List<UnitsConvertor>> readUnits(String subjectsID) =>
//     FirebaseFirestore.instance
//         .collection('ECE')
//         .orderBy("Heading", descending: false)
//         .snapshots()
//         .map((snapshot) => snapshot.docs
//         .map((doc) => UnitsConvertor.fromJson(doc.data()))
//         .toList());


Future createUnits({
  required String mode,
      required String heading,
      required String description,
      required String PDFSize,
      required String Date,
      required String PDFName,
      required String PDFLink,
      required String subjectsID
}) async {
  final docflash = FirebaseFirestore.instance
      .collection("ECE")
      .doc(mode)
      .collection(mode)
      .doc(subjectsID)
      .collection("Units")
      .doc();
  final flash = UnitsConvertor(
      id: docflash.id,
      name: heading,
      email: PDFName,
      photoUrl: description,
      fatherName: PDFSize,
      address: PDFLink,
      Date: Date,
  userPn: 0,
  fatherPn: 0);
  final json = flash.toJson();
  await docflash.set(json);
}

class UnitsConvertor {
  String id;
  final String name, email, photoUrl, fatherName, address, Date;
  final int userPn,fatherPn;

  UnitsConvertor(
      {this.id = "",
        required this.name,
        required this.email,
        required this.photoUrl,
        required this.fatherName,
        required this.address,
        required this.Date,
      required this.fatherPn,
      required this.userPn});

  Map<String, dynamic> toJson() => {
    "id": id,
    "Heading": name,
    "PDFName": email,
    "Description": photoUrl,
    "PDFSize": fatherName,
    "PDFLink": address,
    "Date": Date
  };

  // static UnitsConvertor fromJson(Map<String, dynamic> json) => UnitsConvertor(
  //     address: json["PDFLink"],
  //     id: json['id'],
  //     name: json["Heading"],
  //     email: json["PDFName"],
  //     photoUrl: json["Description"],
  //     fatherName: json["PDFSize"],
  //     Date: json["Date"]);
}
