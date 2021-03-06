import 'package:flutter/material.dart';
import 'package:task_graph/DM_interface.dart';
import 'package:task_graph/data_model.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({
    Key? key,
  }) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Board> boards = [mockBoard]; //temporary solution
  Board activeBoard = mockBoard; //temporary solution as well
  late Node mockGoal = activeBoard.addGoal('mockGoal');
  late Node mockStep;
  bool isTitleClicked = false;
  late Function updateAppState = ({
    Board? newActiveBoard,
    bool? newIsTitleClicked,
    bool simplyChangeTheTitleMode: false,
  }) {
    setState(() {
      activeBoard = newActiveBoard ?? activeBoard;
      if (simplyChangeTheTitleMode) {
        isTitleClicked = !isTitleClicked;
      } else {
        isTitleClicked = newIsTitleClicked ?? isTitleClicked;
      }
    });
  };

  @override
  void initState() {
    //done to initialise the structure. temporary solution
    Node mockStep = activeBoard.addStepByAim('Mock Step', mockGoal);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          actions: [
            IconButton(
              icon: Icon(Icons.map),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("placeholder for a feature (map graph)")));
              },
            )
          ],
          leading: IconButton(
            icon: Icon(Icons.menu_open),
            onPressed: () {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text("a menu should open")));
            }, //TODO: implement menu for boards
          ),
          title: ResponsiveTitle(
            board: activeBoard,
            isInEditingMode: isTitleClicked,
            updateAppStateCallback: updateAppState,
          )),
      body: UnlockedList(
        activeBoard,
        updateAppState: updateAppState,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          openNodePage(context, mockStep);
        },
        tooltip: 'open step description',
        child: Icon(Icons.add),
      ),
    );
  }
}

class ResponsiveTitle extends StatelessWidget {
  final Board board;
  final bool isInEditingMode;
  final Function updateAppStateCallback;
  ResponsiveTitle({
    Key? key,
    required this.board,
    required this.isInEditingMode,
    required this.updateAppStateCallback,
  }) : super(key: key);
  late final TextEditingController controller =
      TextEditingController(text: board.title);

  Widget build(BuildContext context) {
    if (isInEditingMode) {
      return TextField(
        controller: controller,
        autofocus: true,
        autocorrect: false,
        onSubmitted: (value) {
          board.title = value;
          updateAppStateCallback(
              newActiveBoard: board, simplyChangeTheTitleMode: true);
        },
        showCursor: true,
        enableSuggestions: false,
      );
    }
    return GestureDetector(
      child: Text(board.title),
      onTap: () {
        updateAppStateCallback(simplyChangeTheTitleMode: true);
      },
    );
  }
}

void openNodePage(BuildContext context, Node node) {
  showDialog(
      context: context, builder: (BuildContext context) => NodePage(node));
}

class NodePage extends StatelessWidget {
  final Node node;
  NodePage(this.node);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    size = Size(size.width / 2, size.height / 2);
    return Center(
        child: Container(
      color: Colors.blue,
      height: size.height,
      width: size.width,
      child: Column(
        //rearrange neatly
        children: [
          Text(
            node.title,
            style: TextStyle(color: Colors.white),
          ),
          Text(node.description),
          for (Node aim in node.aim)
            TextButton(
                onPressed: () {
                  openNodePage(context, aim);
                },
                style: ButtonStyle(),
                child: Text(
                  aim.title,
                  style: TextStyle(color: Colors.white),
                ))
        ],
      ),
    ));
  }
}

class UnlockedList extends StatelessWidget {
  final Board board;
  final Function updateAppState;
  UnlockedList(
    this.board, {
    Key? key,
    required this.updateAppState,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Node> unlocked = board.unlocked();
    return ListView.builder(
      itemCount: unlocked.length,
      itemBuilder: (BuildContext context, int index) {
        return Dismissible(
          key: ValueKey<int>(unlocked[index].id),
          child: ListTile(
            title: Text(unlocked[index].title),
          ),
          background: Container(
            color: Colors.red,
          ),
          secondaryBackground: Container(
            color: Colors.green,
          ),
          onDismissed: (DismissDirection direction) {
            if (direction == DismissDirection.endToStart) {
              taskClearedHandler(unlocked[index]);
            } else {}
          },
        );
      },
    );
  }

//{Board? newActiveBoard, bool? newIsTitleClicked, bool simplyChangeTheTitleMode: false,}
  void taskClearedHandler(Node clearedNode) {
    board.clearNode(clearedNode);
    updateAppState(newActiveBoard: board);
  }
}
