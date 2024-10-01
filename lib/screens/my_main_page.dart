import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expends_money/functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:translator/translator.dart';

class MyMainPage extends StatefulWidget {
  const MyMainPage({super.key});

  @override
  State<MyMainPage> createState() => _MyMainPageState();
}

class _MyMainPageState extends State<MyMainPage> {
  bool showAuthContainer = false,
      loader = false,
      showOptions = false,
      showTranslate = false;
  final userName = TextEditingController();
  final bodyContent = TextEditingController();
  final searchData = TextEditingController();
  String searchContent = '';
  String tamilContent = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (FirebaseAuth.instance.currentUser?.uid == null) {
      setState(() {
        showAuthContainer = true;
      });
    } else {
      setState(() {
        Auth().getProfile();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          SizedBox(
            width: width(context),
            height: height(context),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.only(top: 50, left: 15),
                  color: Theme.of(context).colorScheme.secondary,
                  child: Row(
                    children: [
                      Text(
                        'Chat',
                        style: GoogleFonts.saira(
                            textStyle: TextStyle(
                                color: Theme.of(context).colorScheme.tertiary,
                                fontSize: 22.5)),
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      Expanded(
                        child: Container(
                            padding: const EdgeInsets.only(top: 5, left: 10),
                            decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surface
                                    .withOpacity(0.2),
                                borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(20))),
                            width: width(context) * 0.5,
                            child: TextField(
                              controller: searchData,
                              keyboardType: TextInputType.text,
                              cursorColor:
                                  Theme.of(context).colorScheme.tertiary,
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.tertiary),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: ' Search',
                                hintStyle: GoogleFonts.outfit(
                                    textStyle: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .tertiary
                                            .withOpacity(0.5),
                                        fontSize: 12.5)),
                              ),
                              onSubmitted: (str) {
                                if (searchData.text.isNotEmpty) {
                                  setState(() {
                                    searchContent = searchData.text;
                                  });
                                }
                              },
                            )),
                      ),
                      GestureDetector(
                        onTap: () {
                          if (searchData.text.isNotEmpty) {
                            setState(() {
                              searchContent = searchData.text;
                            });
                            if (searchContent.isNotEmpty) {
                              setState(() {
                                searchContent = '';
                                searchData.clear();
                              });
                            }
                          }
                        },
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 15, horizontal: 10),
                            decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surface
                                    .withOpacity(0.2),
                                borderRadius: const BorderRadius.only(
                                    topRight: Radius.circular(20))),
                            child: Icon(
                              searchContent.isEmpty
                                  ? Icons.search
                                  : Icons.clear,
                              color: Theme.of(context).colorScheme.tertiary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                    ],
                  ),
                ),
                Expanded(
                    child: (FirebaseAuth.instance.currentUser?.uid != null)
                        ? SizedBox(
                            child: StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('Chat')
                                  .doc('content')
                                  .collection('allContent')
                                  .snapshots(),
                              builder: (context,
                                  AsyncSnapshot<QuerySnapshot> snapshot) {
                                if (snapshot.hasData) {
                                  return ListView(
                                    reverse: true,
                                    children: snapshot.data!.docs
                                        .map((content) => textBox(content))
                                        .toList()
                                        .reversed
                                        .toList(),
                                  );
                                }
                                return Center(
                                  child: SvgPicture.asset(
                                    'assets/images/null.svg',
                                    width: 250,
                                    height: 250,
                                  ),
                                );
                              },
                            ),
                          )
                        : const SizedBox()),
                Container(
                    padding: const EdgeInsets.only(top: 5, left: 10, right: 10),
                    margin: const EdgeInsets.only(top: 5),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .secondary
                          .withOpacity(0.7),
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20)),
                    ),
                    width: width(context) * 0.95,
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              showOptions = true;
                            });
                          },
                          child: Icon(
                            Icons.camera_alt,
                            color: Theme.of(context).colorScheme.tertiary,
                            weight: 10,
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: TextField(
                            controller: bodyContent,
                            cursorColor: Theme.of(context).colorScheme.tertiary,
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.tertiary),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: ' Message...',
                              hintStyle: GoogleFonts.outfit(
                                  textStyle: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .tertiary
                                    .withOpacity(0.5),
                              )),
                            ),
                            onSubmitted: (String con) {
                              setState(() {
                                if (bodyContent.text.isNotEmpty) {
                                  Auth().addContent(
                                      bodyContent.text, context, '');
                                  bodyContent.clear();
                                }
                                FocusScope.of(context).unfocus();
                              });
                            },
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              if (bodyContent.text.isNotEmpty) {
                                Auth()
                                    .addContent(bodyContent.text, context, '');
                                bodyContent.clear();
                              }
                              FocusScope.of(context).unfocus();
                            });
                          },
                          child: Icon(
                            Icons.send_rounded,
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                        )
                      ],
                    )),
              ],
            ),
          ),
          if (showAuthContainer || showOptions || showTranslate)
            GestureDetector(
              onTap: () {
                setState(() {
                  if (showOptions = true) {
                    showOptions = false;
                  }
                  if (showTranslate = true) {
                    showTranslate = false;
                    tamilContent = '';
                  }
                });
              },
              child: Container(
                width: width(context),
                height: height(context),
                color: Theme.of(context).colorScheme.tertiary.withOpacity(0.5),
              ),
            ),
          if (showTranslate)
            Card(
              child: Container(
                width: width(context) * 0.8,
                height: 180,
                margin: const EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'In Tamil',
                          style: GoogleFonts.outfit(
                              textStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Theme.of(context).colorScheme.tertiary,
                          )),
                        ),
                        IconButton(
                            onPressed: () {
                              setState(() {
                                showTranslate = false;
                              });
                            },
                            focusColor: Theme.of(context).colorScheme.tertiary,
                            icon: Icon(
                              Icons.clear,
                              color: Theme.of(context).colorScheme.tertiary,
                            )),
                      ],
                    ),
                    SizedBox(
                      width: width(context),
                      height: 125,
                      child: tamilContent.isNotEmpty
                          ? ListView(
                              children: [
                                Text(
                                  tamilContent,
                                  style: GoogleFonts.outfit(
                                      textStyle: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: tamilContent == 'ERROR'
                                        ? Colors.red
                                        : Theme.of(context)
                                            .colorScheme
                                            .tertiary,
                                  )),
                                ),
                              ],
                            )
                          : Container(
                              width: width(context) * 0.65,
                              margin: const EdgeInsets.symmetric(vertical: 60),
                              child: LinearProgressIndicator(
                                color: Theme.of(context).colorScheme.secondary,
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .secondary
                                    .withOpacity(0.3),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          if (showOptions)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 200,
                width: width(context),
                alignment: Alignment.center,
                decoration:
                    BoxDecoration(color: Theme.of(context).colorScheme.surface),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          pickImage(ImageSource.gallery);
                        });
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.file_copy_rounded,
                            color: Theme.of(context).colorScheme.tertiary,
                            size: 50,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            'Gallery',
                            style: GoogleFonts.outfit(
                                textStyle: TextStyle(
                                    fontSize: 20,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .tertiary)),
                          )
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          pickImage(ImageSource.camera);
                        });
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.camera,
                            color: Theme.of(context).colorScheme.tertiary,
                            size: 50,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            'Camera',
                            style: GoogleFonts.outfit(
                                textStyle: TextStyle(
                                    fontSize: 20,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .tertiary)),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (showAuthContainer)
            Container(
              height: 225,
              width: width(context) * 0.75,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.all(Radius.circular(17.5)),
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: height(context) * 0.02,
                  ),
                  Text(
                    'Create Profile',
                    style: GoogleFonts.outfit(
                        textStyle: TextStyle(
                            color: Theme.of(context).colorScheme.tertiary,
                            fontSize: 30)),
                  ),
                  SizedBox(
                    height: height(context) * 0.02,
                  ),
                  Container(
                      padding:
                          const EdgeInsets.only(top: 5, left: 10, right: 10),
                      margin: const EdgeInsets.only(top: 5, left: 35, right: 5),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withOpacity(0.7),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(15),
                          bottomLeft: Radius.circular(15),
                          bottomRight: Radius.circular(15),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.person,
                            color: Theme.of(context).colorScheme.tertiary,
                            weight: 10,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Expanded(
                            child: TextFormField(
                              controller: userName,
                              cursorColor:
                                  Theme.of(context).colorScheme.tertiary,
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.tertiary),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: ' Name...',
                                hintStyle: GoogleFonts.outfit(
                                    textStyle: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .tertiary
                                      .withOpacity(0.6),
                                )),
                              ),
                            ),
                          ),
                        ],
                      )),
                  Flexible(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            if (userName.text.isNotEmpty) {
                              loader = true;
                              name = userName.text;
                              createAccount();
                            } else {
                              showToast('Enter the name', context);
                            }
                          });
                        },
                        child: Container(
                            padding: const EdgeInsets.all(20),
                            margin: const EdgeInsets.only(
                                top: 5, left: 5, right: 150, bottom: 5),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(1),
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(15),
                                bottomRight: Radius.circular(15),
                                topRight: Radius.circular(15),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.data_saver_on_rounded,
                                  color: Theme.of(context).colorScheme.surface,
                                  weight: 10,
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  'Save',
                                  style: GoogleFonts.outfit(
                                      textStyle: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.surface,
                                  )),
                                ),
                              ],
                            )),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (loader)
            Container(
              alignment: Alignment.center,
              width: width(context),
              height: height(context),
              color: Theme.of(context).colorScheme.tertiary.withOpacity(0.5),
              child: CircularProgressIndicator(
                color:
                    Theme.of(context).colorScheme.secondary.withOpacity(0.75),
              ),
            ),
        ],
      ),
    );
  }

  Widget textBox(QueryDocumentSnapshot content) {
    bool firstPerson = FirebaseAuth.instance.currentUser!.uid == content['uid'];
    if (content['content'].isNotEmpty &&
        (searchContent.isEmpty ||
            content['date'].toString().contains(searchContent) ||
            content['name'].toString().contains(searchContent) ||
            content['content'].toString().contains(searchContent))) {
      return GestureDetector(
        onDoubleTap: () {
          if ((content['content'].toString().contains('https://'))) {
            setState(() {
              _translateToTamil('Image can not be translate');
            });
          } else {
            setState(() {
              _translateToTamil(content['content']);
            });
          }
          setState(() {
            showTranslate = true;
          });
        },
        onLongPress: () {
          if (firstPerson) {
            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    title: Text(
                      'Are you want to Delete This \n\'${(content['content'].toString().contains('https://')) ? Image : content['content']}\'',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: GoogleFonts.outfit(
                          textStyle: TextStyle(
                        fontSize: 15,
                        color: Theme.of(context).colorScheme.tertiary,
                      )),
                    ),
                    actions: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.outfit(
                              textStyle: TextStyle(
                            fontSize: 10,
                            color: Theme.of(context).colorScheme.secondary,
                          )),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          await FirebaseFirestore.instance
                              .collection('Chat')
                              .doc('content')
                              .collection('allContent')
                              .doc(content['id'])
                              .delete();
                          Navigator.pop(context);

                          if (content['image'].toString().isNotEmpty) {
                            await FirebaseStorage.instance
                                .ref()
                                .child('images/${content['image']}')
                                .delete();
                          }
                        },
                        child: Text(
                          'Delete',
                          style: GoogleFonts.outfit(
                              textStyle: TextStyle(
                            fontSize: 10,
                            color: Theme.of(context).colorScheme.secondary,
                          )),
                        ),
                      ),
                    ],
                  );
                });
          }
        },
        child: Column(
          crossAxisAlignment:
              firstPerson ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              margin: EdgeInsets.only(
                  top: 5,
                  right: firstPerson ? 5 : 45,
                  left: firstPerson ? 45 : 5),
              decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .secondary
                      .withOpacity(firstPerson ? 0.1 : 0.3),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(15),
                    topRight: const Radius.circular(15),
                    bottomLeft: Radius.circular(firstPerson ? 15 : 0),
                    bottomRight: Radius.circular(firstPerson ? 0 : 15),
                  )),
              child: Column(
                crossAxisAlignment: firstPerson
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Container(
                    child: !(content['content']
                            .toString()
                            .contains('https://firebasestorage'))
                        ? Text(
                            content['content'],
                            style: GoogleFonts.outfit(
                                textStyle: TextStyle(
                              color: Theme.of(context).colorScheme.tertiary,
                            )),
                          )
                        : ClipRRect(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10)),
                            child: Image.network(
                              content['content'],
                              fit: BoxFit.fill,
                              loadingBuilder: (context, child,
                                      loadingProgress) =>
                                  loadingProgress == null
                                      ? child
                                      : const SizedBox(
                                          height: 100,
                                          width: 100,
                                          child: Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        ),
                            ),
                          ),
                  ),
                  Text(
                    '${content['name']} : ${content['date']}',
                    style: GoogleFonts.outfit(
                        textStyle: TextStyle(
                      fontSize: 10,
                      color: Theme.of(context).colorScheme.secondary,
                    )),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox(
      height: 0,
    );
  }

  final FirebaseStorage storage = FirebaseStorage.instance;

  // Image file
  File? imageFile;

  Future<void> pickImage(ImageSource source) async {
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(source: source);

    setState(() {
      if (pickedImage != null) {
        imageFile = File(pickedImage.path);
        showOptions = false;
        loader = true;
      }
    });
    uploadImage();
  }

  Future<void> uploadImage() async {
    if (imageFile == null) {
      return;
    }

    try {
      final String fileName = imageFile!.path.split('/').last;
      final storageRef = storage.ref().child('images/$fileName');
      final uploadTask = storageRef.putFile(imageFile!);

      final storageSnap = await uploadTask;

      final downloadUrl = await storageSnap.ref.getDownloadURL();
      Auth().addContent(downloadUrl, context, storageSnap.ref.name);
      setState(() {
        loader = false;
      });
    } on Exception catch (e) {
      showToast('$e', context);
    }
  }

  void createAccount() async {
    try {
      Auth().signInAnonymously();
      setState(() {
        showAuthContainer = false;
        loader = false;
      });
    } catch (e) {
      setState(() {
        loader = false;
      });
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                icon: const Icon(
                  Icons.error,
                  size: 30,
                ),
                iconColor: Colors.redAccent,
                title: Text(
                  '$e',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.tertiary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600),
                ),
              ));
    }
  }

  Future<void> _translateToTamil(String content) async {
    final inputText = content;
    if (inputText.isEmpty) {
      return;
    }

    try {
      final translate = GoogleTranslator();
      final translatedText = await translate.translate(
        inputText,
        from: 'en',
        to: 'ta',
      );
      setState(() {
        tamilContent = translatedText.toString();
      });
    } catch (error) {
      showToast('unable to Translate', context);
      setState(() {
        tamilContent = 'ERROR';
      });
    }
  }
}
