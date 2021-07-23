import 'package:flutter/material.dart';
import 'package:mesbro_chat_flutter_app/bloc_patterns/idm_bloc_patterns/change_password_bloc.dart';
import 'package:mesbro_chat_flutter_app/utils/navigation_actions.dart';
import 'package:mesbro_chat_flutter_app/utils/widgets_collection.dart';

class ChangePasswordPage extends StatefulWidget {
  final String resetToken, previousScreen;

  ChangePasswordPage({this.resetToken, this.previousScreen});

  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final ChangePasswordBloc _changePasswordBloc = ChangePasswordBloc();
  TextEditingController _passwordTextEditingController =
          TextEditingController(),
      _confirmPasswordTextEditingController = TextEditingController();
  bool _doesPasswordMatches = false, _isPasswordError = false;
  bool _isPasswordVisible = true, _isConfirmPasswordVisible = true;
  NavigationActions _navigationActions;
  WidgetsCollection _widgetsCollection;
  void initState() {
    super.initState();
    _confirmPasswordTextEditingController.text = '';
    _navigationActions = NavigationActions(context);
    _widgetsCollection = WidgetsCollection(context);
  }

  void dispose() {
    super.dispose();
    _changePasswordBloc.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Change Password',
        ),
      ),
      body: Container(
        margin:
            EdgeInsets.only(top: 10.0, bottom: 10.0, left: 10.0, right: 10.0),
        child: ListView(
          children: <Widget>[
            Column(
              children: <Widget>[
                TextField(
                  controller: _passwordTextEditingController,
                  obscureText: _isPasswordVisible,
                  decoration: InputDecoration(
                      suffixIcon: IconButton(
                          icon: Icon(Icons.remove_red_eye),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          }),
                      errorText: _isPasswordError
                          ? 'Password should have characters between 8 and 32'
                          : null,
                      labelText: 'Enter password',
                      hintText: 'Password'),
                  onChanged: (String value) {
                    if (_passwordTextEditingController.text.length < 8 ||
                        _passwordTextEditingController.text.length > 32) {
                      setState(() {
                        _isPasswordError = true;
                      });
                    } else {
                      setState(() {
                        _isPasswordError = false;
                      });
                      if (_confirmPasswordTextEditingController.text != '' &&
                          _passwordTextEditingController.text ==
                              _confirmPasswordTextEditingController.text) {
                        setState(() {
                          _doesPasswordMatches = true;
                        });
                      } else {
                        setState(() {
                          _doesPasswordMatches = false;
                        });
                      }
                    }
                  },
                ),
                TextField(
                    controller: _confirmPasswordTextEditingController,
                    obscureText: _isConfirmPasswordVisible,
                    decoration: InputDecoration(
                        suffixIcon: IconButton(
                            icon: Icon(Icons.remove_red_eye),
                            onPressed: () {
                              setState(() {
                                _isConfirmPasswordVisible =
                                    !_isConfirmPasswordVisible;
                              });
                            }),
                        errorText:
                            _confirmPasswordTextEditingController.text != '' &&
                                    !_doesPasswordMatches
                                ? 'Password doesn\'t match'
                                : null,
                        labelText: 'Enter confirm password',
                        hintText: 'Confirm Password'),
                    onChanged: (String value) {
                      if (_confirmPasswordTextEditingController.text != '' &&
                          _passwordTextEditingController.text ==
                              _confirmPasswordTextEditingController.text) {
                        setState(() {
                          _doesPasswordMatches = true;
                        });
                      } else {
                        setState(() {
                          _doesPasswordMatches = false;
                        });
                      }
                    }),
                RaisedButton(
                  color: Colors.deepOrange,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0)),
                  child: Text(
                    'Change My Password',
                    style:
                        TextStyle(color: Colors.white),
                  ),
                  onPressed: _doesPasswordMatches && (!_isPasswordError)
                      ? () {
                          _widgetsCollection.showMessageDialog();
                          _changePasswordBloc.changePassword(
                              _passwordTextEditingController.text,
                              widget.resetToken);
                        }
                      : null,
                ),
                StreamBuilder(
                    stream: _changePasswordBloc.changePasswordStream,
                    builder: (BuildContext context,
                        AsyncSnapshot<Map<String, dynamic>> asyncSnapshot) {
                      return asyncSnapshot.data == null
                          ? Container()
                          : _changePasswordFinished(asyncSnapshot.data);
                    }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _changePasswordFinished(Map<String, dynamic> mapResponse) {
    Future.delayed(Duration.zero, () {
      _navigationActions.closeDialogRoot();
      _changePasswordBloc.changePasswordStreamSink.add(null);
      //print('~~~ prev: ${widget.previousScreen}');
      if (mapResponse['code'] == 200) {
        if (widget.previousScreen == '') {
          _navigationActions.navigateToScreenNameRoot('login_page');
        } else if (widget.previousScreen == 'home_page') {
          _navigationActions.navigateToScreenNameRoot('home_page');
          _navigationActions.navigateToScreenName('login_page');
        }
      } else {
        _widgetsCollection.showToastMessage(mapResponse['content']['message']);
      }
    });
    return Container();
  }
}
