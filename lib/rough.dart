// import 'package:flutter/material.dart';
// import 'package:dio/dio.dart';

// void main() => runApp(MyApp());

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: MyHomePage(),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State&lt;MyHomePage> {

//   String nextPage = "https://swapi.co/api/people";

//   ScrollController _scrollController = new ScrollController();

//   bool isLoading = false;

//   List names = new List();


//   final dio = new Dio();
//   void _getMoreData() async {
//     if (!isLoading) {
//       setState(() {
//         isLoading = true;
//       });

//       final response = await dio.get(nextPage);
//       List tempList = new List();
//       nextPage = response.data['next'];
//       for (int i = 0; i &lt; response.data['results'].length; i++) {
//         tempList.add(response.data['results'][i]);
//       }

//       setState(() {
//         isLoading = false;
//         names.addAll(tempList);
//       });
//     }
//   }

//   @override
//   void initState() {
//     this._getMoreData();
//     super.initState();
//     _scrollController.addListener(() {
//       if (_scrollController.position.pixels ==
//           _scrollController.position.maxScrollExtent) {
//         _getMoreData();
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _scrollController.dispose();
//     super.dispose();
//   }

//   Widget _buildProgressIndicator() {
//     return new Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: new Center(
//         child: new Opacity(
//           opacity: isLoading ? 1.0 : 00,
//           child: new CircularProgressIndicator(),
//         ),
//       ),
//     );
//   }

//   Widget _buildList() {
//     return ListView.builder(
//       //+1 for progressbar
//       itemCount: names.length + 1,
//       itemBuilder: (BuildContext context, int index) {
//         if (index == names.length) {
//           return _buildProgressIndicator();
//         } else {
//           return new ListTile(
//             title: Text((names[index]['name'])),
//             onTap: () {
//               print(names[index]);
//             },
//           );
//         }
//       },
//       controller: _scrollController,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Pagination"),
//       ),
//       body: Container(
//         child: _buildList(),
//       ),
//       resizeToAvoidBottomPadding: false,
//     );
//   }
// }