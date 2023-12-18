
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'firestore.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

final FirestoreService firestoreService= FirestoreService();
final TextEditingController textController =TextEditingController();
class MyApp extends StatefulWidget {
  const MyApp({super.key});


  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FirestoreService firestore = FirestoreService();

  @override

  void openNoteBox({String ? docID}){
    showDialog(context: context, builder: (context) =>AlertDialog(
      content: TextField(
        controller: textController,
        ),
        actions: [
          ElevatedButton(onPressed: (){
            if(docID == null){
              firestoreService.addNote(textController.text);
            }
            else{
              firestoreService.updateNote(docID, textController.text);
            }
          
            textController.clear();

            Navigator.pop(context);
          }
          , child: const Text("+"))
        ],
    ));
  }
  

 @override
 Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: Text("Notes")),
      floatingActionButton: FloatingActionButton(
        onPressed: openNoteBox,
        child: const Icon(Icons.add), ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getNotesStream(),
        builder: (context, snapshot) {
          if(snapshot.hasData){
            List notesList= snapshot.data!.docs;
            return ListView.builder(
              itemCount: notesList.length,
              itemBuilder: (context, index){
                DocumentSnapshot document= notesList[index];
                String docID = document.id;

                Map<String, dynamic> data=
                  document.data() as Map<String, dynamic>;
                String noteText= data['note'];

                return ListTile(
                  title: Text(noteText),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                    onPressed: () => openNoteBox(docID: docID),
                    icon: const Icon(Icons.settings),
                    ),
                      IconButton(
                    onPressed: () => firestoreService.deleteNote(docID),
                    icon: const Icon(Icons.delete),
                      )
                    ],
                    ),
                    
                  
                  );
              },
              );
          }
          else{
            return const Text("No notes...");
          }

        },
    ),
    );
 }
  
}

