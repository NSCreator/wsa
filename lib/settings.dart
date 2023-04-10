import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/material.dart';

import 'authPage.dart';


class settings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromRGBO(4, 9, 35, 1),
                Color.fromRGBO(39, 105, 171, 1),
              ],
              begin: FractionalOffset.bottomCenter,
              end: FractionalOffset.topCenter,
            ),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          child: Icon(
                            Icons.arrow_back,
                            size: 30,
                            color: Colors.white,
                          ),
                          onTap: () {
                            Navigator.pop(context);
                          },
                        ),
                        Text(
                          "Settings",
                          style: TextStyle(color: Colors.white, fontSize: 30),
                        ),
                        Icon(
                          Icons.ice_skating,
                          color: Colors.white,
                        ),
                      ],
                    ),
                    Container(
                      height: height * 0.80,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          double innerHeight = constraints.maxHeight;
                          double innerWidth = constraints.maxWidth;
                          return Stack(
                            fit: StackFit.expand,
                            children: [
                              Positioned(
                                top: -170,
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: StreamBuilder<DocumentSnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection("users")
                                        .doc(fullUserId())
                                        .snapshots(),
                                    builder: (context, mainsnapshot) {
                                      switch (mainsnapshot.connectionState) {
                                        case ConnectionState.waiting:
                                          return const Center(
                                              child: CircularProgressIndicator(
                                            strokeWidth: 0.3,
                                            color: Colors.cyan,
                                          ));
                                        default:
                                          if (mainsnapshot.data!.exists) {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    height: innerHeight * 0.30,
                                                    width: innerWidth,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              30),
                                                      color: Colors.white,
                                                    ),
                                                    child: Column(
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Spacer(),
                                                            Padding(
                                                              padding: const EdgeInsets.only(right: 15),
                                                              child: Text(
                                                                mainsnapshot.data!["name"],
                                                                style: TextStyle(
                                                                  color: Color.fromRGBO(
                                                                      39, 105, 171, 1),
                                                                  fontFamily: 'Nunito',
                                                                  fontSize: 37,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(height: 5,),
                                                        Text(
                                                          "Email : ${mainsnapshot.data!["email"]}",
                                                          style: const TextStyle(
                                                              fontSize: 20,
                                                              color: Colors.blue),
                                                        ),
                                                        Row(
                                                          mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                          children: [
                                                            Text(
                                                              'Age : ${mainsnapshot.data!["age"]}',
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .grey[700],
                                                                fontFamily:
                                                                'Nunito',
                                                                fontSize: 20,
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                horizontal: 10,
                                                                vertical: 8,
                                                              ),
                                                              child: Container(
                                                                height: 20,
                                                                width: 3,
                                                                decoration:
                                                                BoxDecoration(
                                                                  borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                      100),
                                                                  color: Colors.grey,
                                                                ),
                                                              ),
                                                            ),
                                                            Text(
                                                              'Phone : ${mainsnapshot.data!["phoneNumber"]}',
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .grey[700],
                                                                fontFamily:
                                                                'Nunito',
                                                                fontSize: 20,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        Row(
                                                          mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                          children: [
                                                            Text(
                                                              "Age : ${mainsnapshot.data!["age"]}",
                                                              style: const TextStyle(
                                                                  fontSize: 20,
                                                                  color:
                                                                  Colors.white),
                                                            ),
                                                            const SizedBox(
                                                              width: 10,
                                                            ),
                                                            Text(
                                                              "Phone : ${mainsnapshot.data!["phoneNumber"]}",
                                                              style: const TextStyle(
                                                                  fontSize: 20,
                                                                  color:
                                                                  Colors.white),
                                                            )
                                                          ],
                                                        ),
                                                        Padding(
                                                          padding: const EdgeInsets.all(8.0),
                                                          child: Text(
                                                            "Address : ${mainsnapshot.data!['address']}",
                                                            style: const TextStyle(
                                                                fontSize: 25,
                                                                color: Colors.blue),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(height: 10,),
                                                  Container(
                                                    width: double.infinity,
                                                    decoration: BoxDecoration(
                                                        color: Colors.black
                                                            .withOpacity(0.5),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(15)),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(5.0),
                                                          child: Text(
                                                            "Live Location :",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .orange,
                                                                fontSize: 20),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  left: 20,
                                                                  right: 3),
                                                          child: Row(
                                                            children: [
                                                              Text(
                                                                "lat : ${mainsnapshot.data!["lat"]}",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        18,
                                                                    color: Colors
                                                                        .white),
                                                              ),
                                                              Text(
                                                                "  lng : ${mainsnapshot.data!["lng"]}",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        18,
                                                                    color: Colors
                                                                        .white),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  left: 20,
                                                                  right: 5,
                                                                  bottom: 5,
                                                                  top: 3),
                                                          child: Text(
                                                            "Place: ${mainsnapshot.data!["location"]}",
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: TextStyle(
                                                                fontSize: 18,
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                  Text(
                                                    mainsnapshot
                                                        .data!["lastUpdate"],
                                                  )
                                                ],
                                              ),
                                            );
                                          } else {
                                            return Container();
                                          }
                                      }
                                    }),
                                // child: Container(
                                //   height: innerHeight * 0.72,
                                //   width: innerWidth,
                                //   decoration: BoxDecoration(
                                //     borderRadius: BorderRadius.circular(30),
                                //     color: Colors.white,
                                //   ),
                                //   child: StreamBuilder<DocumentSnapshot>(
                                //       stream: FirebaseFirestore.instance
                                //           .collection("users")
                                //           .doc(fullUserId())
                                //           .snapshots(),
                                //       builder: (context, mainsnapshot) {
                                //         switch (mainsnapshot.connectionState) {
                                //           case ConnectionState.waiting:
                                //             return const Center(
                                //                 child: CircularProgressIndicator(
                                //                   strokeWidth: 0.3,
                                //                   color: Colors.cyan,
                                //                 ));
                                //           default:
                                //             if (mainsnapshot.data!.exists) {
                                //               return Padding(
                                //                 padding: const EdgeInsets.all(8.0),
                                //                 child: Column(
                                //                   mainAxisAlignment: MainAxisAlignment.center,
                                //                   crossAxisAlignment: CrossAxisAlignment.center,
                                //                   children: [
                                //                     Text(mainsnapshot.data!["name"],
                                //                   style: TextStyle(
                                //                             color: Color.fromRGBO(39, 105, 171, 1),
                                //                             fontFamily: 'Nunito',
                                //                             fontSize: 37,
                                //                           ),
                                //                     ),
                                //                     Text(mainsnapshot.data!["email"],style: const TextStyle(fontSize: 20,color: Colors.blue),),
                                //                         Row(
                                //                           mainAxisAlignment:
                                //                           MainAxisAlignment.center,
                                //                           children: [
                                //                             Column(
                                //                               children: [
                                //                                 Text(
                                //                                   'Orders',
                                //                                   style: TextStyle(
                                //                                     color: Colors.grey[700],
                                //                                     fontFamily: 'Nunito',
                                //                                     fontSize: 25,
                                //                                   ),
                                //                                 ),
                                //                                 Text(
                                //                                   '10',
                                //                                   style: TextStyle(
                                //                                     color: Color.fromRGBO(
                                //                                         39, 105, 171, 1),
                                //                                     fontFamily: 'Nunito',
                                //                                     fontSize: 25,
                                //                                   ),
                                //                                 ),
                                //                               ],
                                //                             ),
                                //                             Padding(
                                //                               padding: const EdgeInsets.symmetric(
                                //                                 horizontal: 25,
                                //                                 vertical: 8,
                                //                               ),
                                //                               child: Container(
                                //                                 height: 50,
                                //                                 width: 3,
                                //                                 decoration: BoxDecoration(
                                //                                   borderRadius:
                                //                                   BorderRadius.circular(100),
                                //                                   color: Colors.grey,
                                //                                 ),
                                //                               ),
                                //                             ),
                                //                             Column(
                                //                               children: [
                                //                                 Text(
                                //                                   'Pending',
                                //                                   style: TextStyle(
                                //                                     color: Colors.grey[700],
                                //                                     fontFamily: 'Nunito',
                                //                                     fontSize: 25,
                                //                                   ),
                                //                                 ),
                                //                                 Text(
                                //                                   '1',
                                //                                   style: TextStyle(
                                //                                     color: Color.fromRGBO(
                                //                                         39, 105, 171, 1),
                                //                                     fontFamily: 'Nunito',
                                //                                     fontSize: 25,
                                //                                   ),
                                //                                 ),
                                //                               ],
                                //                             ),
                                //                           ],
                                //                         ),
                                //                     Row(
                                //                       mainAxisAlignment: MainAxisAlignment.center,
                                //                       crossAxisAlignment: CrossAxisAlignment.center,
                                //                       children: [
                                //                         Text("Age : ${mainsnapshot.data!["age"]}",style: const TextStyle(fontSize: 20,color: Colors.white),),
                                //                         const SizedBox(width: 10,),
                                //                         Text("Phone : ${mainsnapshot.data!["phoneNumber"]}",style: const TextStyle(fontSize: 20,color: Colors.white),)
                                //                       ],
                                //                     ),
                                //                     Text("Address : ${mainsnapshot.data!['address']}",style: const TextStyle(fontSize: 20,color: Colors.blue),),
                                //                     Container(
                                //                       width: double.infinity,
                                //                       decoration: BoxDecoration(
                                //                           color: Colors.black.withOpacity(0.5),
                                //                           borderRadius: BorderRadius.circular(15)
                                //                       ),
                                //                       child: Column(
                                //                         mainAxisAlignment: MainAxisAlignment.start,
                                //                         crossAxisAlignment: CrossAxisAlignment.start,
                                //                         children: [
                                //                           Padding(
                                //                             padding: const EdgeInsets.all(5.0),
                                //                             child: Text("Live Location :",style: TextStyle(color: Colors.orange,fontSize: 20),),
                                //                           ),
                                //                           Padding(
                                //                             padding: const EdgeInsets.only(left: 20,right: 3),
                                //                             child: Row(
                                //                               children: [
                                //                                 Text("lat : ${mainsnapshot.data!["lat"]}",style: TextStyle(fontSize: 18,color: Colors.white),),
                                //                                 Text("  lng : ${mainsnapshot.data!["lng"]}",style: TextStyle(fontSize: 18,color: Colors.white),),
                                //                               ],
                                //                             ),
                                //                           ),
                                //                           Padding(
                                //                             padding: const EdgeInsets.only(left: 20,right: 5,bottom: 5,top: 3),
                                //                             child: Text("Place: ${mainsnapshot.data!["location"]}",overflow: TextOverflow.ellipsis,style: TextStyle(fontSize: 18,color: Colors.white),),
                                //                           )
                                //                         ],
                                //                       ),
                                //                     ),
                                //                     Text(mainsnapshot.data!["lastUpdate"],)
                                //                   ],
                                //                 ),
                                //               );
                                //             }else{
                                //               return Container();
                                //             }
                                //         }
                                //       }),
                                //   // child: Column(
                                //   //   children: [
                                //   //     SizedBox(
                                //   //       height: 80,
                                //   //     ),
                                //   //     Text(
                                //   //       'Jhone Doe',
                                //   //       style: TextStyle(
                                //   //         color: Color.fromRGBO(39, 105, 171, 1),
                                //   //         fontFamily: 'Nunito',
                                //   //         fontSize: 37,
                                //   //       ),
                                //   //     ),
                                //   //     SizedBox(
                                //   //       height: 5,
                                //   //     ),
                                //   //     Row(
                                //   //       mainAxisAlignment:
                                //   //       MainAxisAlignment.center,
                                //   //       children: [
                                //   //         Column(
                                //   //           children: [
                                //   //             Text(
                                //   //               'Orders',
                                //   //               style: TextStyle(
                                //   //                 color: Colors.grey[700],
                                //   //                 fontFamily: 'Nunito',
                                //   //                 fontSize: 25,
                                //   //               ),
                                //   //             ),
                                //   //             Text(
                                //   //               '10',
                                //   //               style: TextStyle(
                                //   //                 color: Color.fromRGBO(
                                //   //                     39, 105, 171, 1),
                                //   //                 fontFamily: 'Nunito',
                                //   //                 fontSize: 25,
                                //   //               ),
                                //   //             ),
                                //   //           ],
                                //   //         ),
                                //   //         Padding(
                                //   //           padding: const EdgeInsets.symmetric(
                                //   //             horizontal: 25,
                                //   //             vertical: 8,
                                //   //           ),
                                //   //           child: Container(
                                //   //             height: 50,
                                //   //             width: 3,
                                //   //             decoration: BoxDecoration(
                                //   //               borderRadius:
                                //   //               BorderRadius.circular(100),
                                //   //               color: Colors.grey,
                                //   //             ),
                                //   //           ),
                                //   //         ),
                                //   //         Column(
                                //   //           children: [
                                //   //             Text(
                                //   //               'Pending',
                                //   //               style: TextStyle(
                                //   //                 color: Colors.grey[700],
                                //   //                 fontFamily: 'Nunito',
                                //   //                 fontSize: 25,
                                //   //               ),
                                //   //             ),
                                //   //             Text(
                                //   //               '1',
                                //   //               style: TextStyle(
                                //   //                 color: Color.fromRGBO(
                                //   //                     39, 105, 171, 1),
                                //   //                 fontFamily: 'Nunito',
                                //   //                 fontSize: 25,
                                //   //               ),
                                //   //             ),
                                //   //           ],
                                //   //         ),
                                //   //       ],
                                //   //     )
                                //   //   ],
                                //   // ),
                                // ),
                              ),
                              Positioned(
                                top: 110,
                                right: 20,
                                child: Icon(
                                  Icons.edit,
                                  color: Colors.grey[700],
                                  size: 30,
                                ),
                              ),
                              Positioned(
                                  top: 30,
                                  right: 30,
                                  child: Text(
                                    "My Profile",
                                    style: TextStyle(
                                        color: Colors.orangeAccent,
                                        fontSize: 40,
                                        fontWeight: FontWeight.w500),
                                  )),
                              Positioned(
                                top: 10,
                                left: 0,
                                right: 190,
                                child: Center(
                                  child: Container(
                                    height: 140,
                                    width: 140,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(60),
                                        image: DecorationImage(
                                            image: NetworkImage(
                                                "https://www.telugu360.com/wp-content/uploads/2023/03/Pawan-Kalyan.jpg"),
                                            fit: BoxFit.cover)),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}

getAddressFromLatLng(location) async {
  List<Placemark> placemarks = await placemarkFromCoordinates(
    location.latitude,
    location.longitude,
  );
  Placemark place = placemarks[0];
  FirebaseFirestore.instance.collection('users').doc(fullUserId()).update({
    "location": "${place.street}, "
        "${place.locality}, "
        "${place.country}",
    "lng": location.longitude,
    "lat": location.latitude,
  });
}

fullUserId() {
  var user = FirebaseAuth.instance.currentUser!.email!;
  return user;
}
