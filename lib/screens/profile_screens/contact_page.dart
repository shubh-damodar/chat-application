import 'package:flutter/material.dart';
import 'package:mesbro_chat_flutter_app/utils/navigation_actions.dart';

class ContactPage extends StatefulWidget {
  Map<String, dynamic> userMap;
  ContactPage({this.userMap}) {
    //print('ContactPage');
  }
  _ContactPageState createState() => _ContactPageState(userMap: userMap);
}

class _ContactPageState extends State<ContactPage> {
  _ContactPageState({this.userMap});
  NavigationActions _navigationActions;
  final Map<String, dynamic> userMap;
  void initState() {
    super.initState();
    _navigationActions = NavigationActions(context);
  }

  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 0.0, bottom: 0.0, left: 10.0, right: 10.0),
      child: ListView(
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Mobile',
                  style: TextStyle(
                      color: Colors.grey, fontSize: 13),
                ),
                Container(
                    margin: EdgeInsets.only(top: 3.0),
                    child: Text(
                      '${userMap['mobile']}',
                    ))
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Alternate Mobile',
                  style: TextStyle(
                      color: Colors.grey, fontSize: 13),
                ),
                Container(
                    margin: EdgeInsets.only(top: 3.0),
                    child: Text(
                      userMap['alternateMobile']['mobile'] == null
                          ? 'N/A'
                          : '${userMap['alternateMobile']['mobile']}',
                    ))
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Website',
                  style: TextStyle(
                      color: Colors.grey, fontSize: 13),
                ),
                Container(
                    margin: EdgeInsets.only(top: 3.0),
                    child: Text(
                      userMap['website'] == null
                          ? 'N/A'
                          : '${userMap['website']}',
                    ))
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Alternate Website',
                  style: TextStyle(
                      color: Colors.grey, fontSize: 13),
                ),
                Container(
                    margin: EdgeInsets.only(top: 3.0),
                    child: Text(
                      userMap['alternateWebsite'] == null
                          ? 'N/A'
                          : '${userMap['alternateWebsite']}',
                    ))
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Email',
                  style: TextStyle(
                      color: Colors.grey,  fontSize: 13),
                ),
                Container(
                    margin: EdgeInsets.only(top: 3.0),
                    child: Text(
                      '${userMap['username']}@mesbro.com',
                    ))
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Alternate Email',
                  style: TextStyle(
                      color: Colors.grey, fontSize: 13),
                ),
                Container(
                    margin: EdgeInsets.only(top: 3.0),
                    child: Text(
                      userMap['alternateEmail'] == null
                          ? 'N/A'
                          : '${userMap['alternateEmail']}',
                    ))
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Social Media',
                  style: TextStyle(
                      color: Colors.grey, fontSize: 13),
                ),
                Container(
                    margin: EdgeInsets.only(top: 3.0),
                    child: Text(
                      userMap['socialMediaLinks']['facebook'] == null
                          ? 'N/A'
                          : '${userMap['socialMediaLinks']['facebook']}',
                    ))
              ],
            ),
          ),
          Container(
            height: 30.0,
          )
        ],
      ),
    );
  }
}
