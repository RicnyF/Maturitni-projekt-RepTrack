import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:rep_track/auth/auth.dart';
import 'package:rep_track/components/my_boldtext.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rep_track/helper/helper_functions.dart';
import 'package:logger/logger.dart';
class ProfilePage extends StatefulWidget {
  
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final logger = Logger();
  bool isLoading = false; 
  final storageRef = FirebaseStorage.instance;
  // current logged in user
  final User ? currentUser = FirebaseAuth.instance.currentUser;

  Future<DocumentSnapshot<Map<String,dynamic>>> getUserDetails() async{
    return await FirebaseFirestore.instance.collection("Users").doc(currentUser!.uid).get();
  }

  Future<void> editPfp(Map<String, dynamic>? user)async{
    
   final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50, maxHeight: 1000, maxWidth: 1000);
    if (image == null) return;
    final imageRef = storageRef.ref().child(user!['username']);
    try{
    final imageBytes= await image.readAsBytes();
    await imageRef.putData(imageBytes);
    final imageUrl = await imageRef.getDownloadURL();
    await FirebaseFirestore.instance.collection("Users").doc(currentUser!.uid).set({
        'photoURL': imageUrl,
        'updatedAt': DateTime.now(),
      },SetOptions(merge: true));
    }
    
    catch(e){
      logger.e(e, time: DateTime.now());
    }
    getImageUrl();
   
  }

  
  late String imageUrl;
  
 
  @override
  void initState(){
    super.initState();
    imageUrl='';
    getImageUrl();
  }

 Future<void> getImageUrl()async{

    final userDoc = await getUserDetails();
     Map<String, dynamic>? userData = userDoc.data();
     final url= userData!['photoURL'];    
     
      if (url!="") {
      try {
        
        setState((){
          imageUrl = url;
         isLoading = false;
        });
        
      } catch (e) {
        logger.e(e, time: DateTime.now());
      }
     
  }
  }
  @override Widget  build(BuildContext context) {
    var scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
      
      appBar: AppBar( 
        automaticallyImplyLeading: false,

        centerTitle: true,
        title: Text("My Profile"),
  
        actions: [Builder(builder: (context){
          return IconButton(
 onPressed: () { Scaffold.of(context).openEndDrawer();},           
 icon: Icon(Icons.settings));
  })],
          
       
        
        backgroundColor: null,
          ),
        endDrawer: Drawer(
          key:scaffoldKey,
          child: ListView(
            children: [
              ListTile(
                title: const Text("Settings"),
                onTap: (){},
              ),
              ListTile(
                title: const Text("Log out",style: TextStyle(color:Colors.red)),
                onTap: () =>logout(context),
              )
            ],
          ),
          
        ),  
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: 
        
        FutureBuilder<DocumentSnapshot<Map<String,dynamic>>>(
          future: getUserDetails(), 
        builder: (context,snapshot){
          
          //loading
          if(snapshot.connectionState== ConnectionState.waiting){
            return const Center(child: CircularProgressIndicator(),);

          }
          //error
          else if(snapshot.hasError){
            return Text("Error: ${snapshot.error}");
          }
          //data received
          else if (snapshot.hasData){
           
            Map<String, dynamic>? user = snapshot.data!.data();
           
            return Center(
              child: Column(children: [
                
                Stack(alignment: Alignment.topRight,
                children: 
                [
                  
                ClipOval(
               
                child:Image.network(
                imageUrl,
                fit: BoxFit.cover,
                height: 150,
                width: 150,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null){
                    return child;
                  }
                  else{ 
                  return SizedBox(height: 150,width: 150,
                    child:Center(child: CircularProgressIndicator()));}
                },
                errorBuilder: (context, error, stackTrace) {
                  
                    return Container( 
            height: 150,
            width: 150,
            child: Icon(Icons.account_box,size: 150, color: Theme.of(context).colorScheme.inversePrimary), // icon of the button
            
              
              decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Theme.of(context).colorScheme.primary,
    ), // Splash color

          );
                    }
                    )
                  )
                ,
                
                Positioned (

                    right: 5,
                    top: 5,
                    child: GestureDetector(
                    onTap: ()=>editPfp(user),
                    child: Container( decoration: BoxDecoration(
                      
                  color: Theme.of(context).colorScheme.inversePrimary, // Button background color
                  shape: BoxShape.circle, // Circular button
                    
                ),
                padding: EdgeInsets.all(4), // Padding around the icon
                child: Icon(
                  Icons.edit,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20, ),)
                  )
                  )
                ],),

                
                Text(capitalizeFirstLetter(user!['username']),style: TextStyle(fontWeight: FontWeight.bold,fontSize: 25),),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(width: 50,),
                    MyBoldText(text: "User Email: "),
                    Text(user['email']),
                  ],
                  
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(width: 50,),
                    MyBoldText(text: "Username:  "),
                    Text(user['username']),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(width: 50,),
                    MyBoldText(text: "Date of birth:  "),
                    Text(user['birthDate']),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(width: 50,),
                    MyBoldText(text: "Account created:  "),
                    Text(user['createdAt']),

                  ],
                ),
              ],
              ),
            );
            }else {
              return Text("No data");
            }

        }
        )
        );
      
  }
}