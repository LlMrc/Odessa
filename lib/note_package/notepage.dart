import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lottie/lottie.dart';

import '../data/box.dart';
import '../data/datahelper.dart';
import 'add_note.dart';
import 'display_note.dart';

//******************************   class StickyNote  *********************************** /**/
class NotePage extends StatefulWidget {
  const NotePage({Key? key}) : super(key: key);

  @override
  NotePageState createState() => NotePageState();
}

class NotePageState extends State<NotePage> {
  bool isvisible = false;

  //INITIATES -------------------------------

  @override
  void initState() {
    super.initState();
  }

  final TextEditingController _editingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color.fromARGB(255, 51, 70, 105),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 145,
            floating: true,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
                background: Image(
                  image: SilverBar
                      .getColorItem(), //AssetImage('assets/appBar.jpg'),
                  fit: BoxFit.cover,
                ),
                title:const  Text('Sticky notes'),
                centerTitle: true,),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                Visibility(visible: isvisible, child: suggestList()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ValueListenableBuilder<Box<Note>>(
                      valueListenable: NoteBoxes.getNotes().listenable(),
                      builder: (context, box, _) {
                        final currentNote = box.values.toList().cast<Note>();
                        if (currentNote.isEmpty) {
                          return Center(
                              child: SizedBox(
                                height: 200,
                                width: 150,
                                child: Column(
                          //  mainAxisSize: MainAxisSize.min,
                         //   crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                                LottieBuilder.asset('assets/book.json'),
                                const Text(
                                  'Add notes',
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                      letterSpacing: 2),
                                ),
                            ],
                          ),
                              ));
                        } else {
                          return MasonryGridView.count(
                              primary: false,
                              shrinkWrap: true,
                              crossAxisCount: isPortrait ? 2 : 4,
                              itemCount: currentNote.length,
                              crossAxisSpacing: 2,
                              mainAxisSpacing: 2,
                              itemBuilder: (context, index) {
                                final note = currentNote[index];
                                return GestureDetector(
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4)),
                                    color: color[index % color.length],
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      child: Column(
                                        children: [
                                          const SizedBox(
                                            height: 6,
                                          ),
                                          Text(
                                            note.title,
                                            maxLines: 1,
                                            overflow: TextOverflow.fade,
                                            style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Text(
                                            note.description,
                                            maxLines: 12,
                                            overflow: TextOverflow.ellipsis,
                                            style:
                                                const TextStyle(fontSize: 16),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  onTap: () async {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) => DisplayNote(
                                                  noteId: note,
                                                )));
                                  },
                                );
                              });
                        }
                      }),
                ),
              ],
            ),
          ),
        ],
      ),
      //--------}----------- floatingActionButton--------------------------------

      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.white.withOpacity(0.3),
          tooltip: 'Add note',
          elevation: 4,
          child: const Icon(
            Icons.add,
            semanticLabel: 'Edit',
          ),
          onPressed: () async {
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => const AddNote()));
          }),
    );
  }

  Widget suggestList() {
    return Container(
      height: 600,
      width: 400,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10)
      ),
      child: ListView.builder(
          itemCount: 12,
          itemBuilder: (context, indext) {
            return ListTile(
              title: Text("search text"),
            );
          }),
    );
  }

  List<Color> color = const [
    Color.fromARGB(255, 113, 141, 191),
    Color.fromARGB(255, 223, 121, 121),
    Color(0xffeee8e8),
    Color.fromARGB(255, 89, 190, 162),
    Color.fromARGB(255, 65, 184, 240),
    Color.fromARGB(255, 204, 217, 132),
    Color(0xffC8C2BC),
    Color.fromARGB(255, 222, 124, 150),
    Color.fromARGB(255, 205, 184, 92),
  ];
}

////////////////////////////    NOTES DETAILS ////////////////////////////////////////////////
class SilverBar {
  static List sliverAppBar = const [
    AssetImage('assets/appBar.jpg'),
    AssetImage('assets/appBar1.jpg'),
    AssetImage('assets/appBar2.jpg'),
    AssetImage('assets/appBar3.jpg'),
    AssetImage('assets/appBar4.jpg')
  ];
  static AssetImage getColorItem() => (sliverAppBar.toList()..shuffle()).first;
}
