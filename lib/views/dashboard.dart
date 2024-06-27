import 'dart:async';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'package:robo9_mobile_app/Service/Bloc/ros_bloc.dart';
import 'package:robo9_mobile_app/Service/Bloc/ros_event.dart';
import 'package:robo9_mobile_app/Utilities/Colors.dart';
import 'package:robo9_mobile_app/Utilities/Joystick.dart';

// ui part
import 'package:cupertino_battery_indicator/cupertino_battery_indicator.dart';
import 'package:robo9_mobile_app/Utilities/disconnect_dialog.dart';
import 'package:robo9_mobile_app/Utilities/error_dialog.dart';
import 'package:robo9_mobile_app/Utilities/file_dialog.dart';
import 'package:robo9_mobile_app/views/record_dialog.dart';

enum MenuAction { Disconnect }

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  // String _filename = '';
  double _battery = 0.0;
  bool _isRecording = false;
  bool _isStop = false;
  double _sliderValue = 0.5;
  double voltage = 0.00;
  double _maxspeed = 0.5;
  bool _isSliderEnabled = true;
  List<bool> _isSelected = [true, false];
  bool _isPressed = false;
  late String dropdownValue;
  dynamic filenames;
  late final TextEditingController filenameText;
  late final TextEditingController maxSpeedText;
  late final TextEditingController humanWidthText;
  late final TextEditingController obstacleDistanceText;
  late final TextEditingController cameraobstacleDistanceText;

  Future<void> fileListHandler(Map<String, dynamic> msg) async {
    String data = msg['data'];
    // print("fileListhandler called");
    List<String> files = data.split(',');
    files.removeLast();
    filenames = files;
  }

  Future<void> stopParamHandler(Map<String, dynamic> param) async {
    String data = param['value'];
    _isStop = data.toLowerCase() == 'true';
    // print("data receive from param system ${_isStop}");
    _isPressed = _isStop;
  }

  Future<void> rosInfoHandler(Map<String, dynamic> msg) async {
    voltage = msg['voltage'];
    _battery = (voltage - 22) / (25.7 - 22);
    if (_battery > 1) {
      _battery = 1;
    }
    setState(() {});
  }

  Future<void> rosSettingHandler(Map<String, dynamic> msg) async {
    String filename = msg['follow_path_file'].toString();
    List<String> file_str = filename.split('/');
    file_str = file_str.last.split('.');
    // filenameText.text = file_str[0];
    dropdownValue = file_str[0];
    humanWidthText.text = msg['human_width'].toString();
    _maxspeed = msg['max_speed'];
    _sliderValue = _maxspeed;
    maxSpeedText.text = msg['max_speed'].toString();
    obstacleDistanceText.text = msg['obstacle_distance'].toString();
    cameraobstacleDistanceText.text =
        msg['camera_obstacle_distance'].toString();
    setState(() {});
  }

  @override
  void initState() {
    filenameText = TextEditingController();
    humanWidthText = TextEditingController();
    maxSpeedText = TextEditingController();
    obstacleDistanceText = TextEditingController();
    cameraobstacleDistanceText = TextEditingController();
    // _filenames = <String>[
    //   'File1_long',
    //   'File2_very_long',
    //   'File3',
    //   'File4',
    //   'File5'
    // ];
    super.initState();
    int data = 1;
    Map<String, dynamic> json = {"data": data};

    context.read<RosBloc>().add(
        RosPublishEvent('app_com/file_list_request', 'std_msgs/Int8', json));

    context.read<RosBloc>().add(RosPublishEvent(
        'robot_system/setting_request', 'std_msgs/Int16', json));

    context.read<RosBloc>().add(
        RosSubsribeEvent(rosInfoHandler, '/robotinfo', 'robo9_msgs/RobotInfo'));
    context.read<RosBloc>().add(RosSubsribeEvent(
        fileListHandler, '/app_com/file_list', 'std_msgs/String'));

    context.read<RosBloc>().add(RosSubsribeEvent(
        rosSettingHandler, '/robot_system/setting', 'robo9_msgs/RobotSetting'));

    context
        .read<RosBloc>()
        .add(RosGetParamEvent('follow_path/emergency_stop', stopParamHandler));
  }

  String _check_msg_vality(var msg) {
    if (msg['max_speed'] > 0.5 || msg['max_speed'] < 0) {
      return "invalid speed setting";
    }
    if (msg["obstacle_distance"] < 0 || msg["camera_obstacle_distance"] < 0) {
      return "invalid obstacle distance";
    }
    if (msg["follow_path_file"] == "") {
      return "empty file name";
    }
    return "";
  }

  void _showReplayDialog(BuildContext pcontext) {
    showDialog(
      context: pcontext,
      builder: (pcontext) {
        return AlertDialog(
          title: const Text('Path Replay'),
          content: SingleChildScrollView(
              child: StatefulBuilder(builder: (pcontest, StateSetter setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // TextField(
                //   controller: filenameText,
                //   decoration: const InputDecoration(
                //     labelText: 'File Load',
                //     hintText: 'Filename',
                //     hintStyle: TextStyle(
                //       color: Colors.grey,
                //       fontSize: 14,
                //     ),
                //   ),
                // ),
                // DropdownMenu(
                //   initialSelection: 'File1',
                //   onSelected: (String? file){

                //   },
                //   dropdownMenuEntries:
                //       _filenames.map<DropdownMenuEntry<String>>((String file) {
                //     return DropdownMenuEntry(value: file, label: file);
                //   }).toList(),
                // ),
                DropdownButton(
                  value: dropdownValue,
                  icon: const Icon(Icons.folder),
                  isExpanded: true,
                  menuMaxHeight: 250,
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                  enableFeedback: true,
                  hint: const Text('Please select a route file'),
                  underline: Container(
                    color: Colors.blue,
                    height: 2,
                  ),
                  onChanged: (String? file) async {
                    if (file != dropdownValue) {
                      int option = await showFileDialog(context, file!);
                      if (option == 0) {
                        dropdownValue = file;
                      } else if (option == 1) {
                        dropdownValue = dropdownValue;
                      } else if (option == -1) {
                        String topic = 'app_com/file_operation';
                        String datatype = 'std_msgs/String';
                        String msg = "0," + file;
                        Map<String, dynamic> json = {"data": msg};
                        context
                            .read<RosBloc>()
                            .add(RosPublishEvent(topic, datatype, json));
                        filenames.remove(file);
                        // dropdownValue = null;
                        // dropdownValue = dropdownValue;
                      }
                      setState(() {
                        print("Set State should call");

                        // dropdownValue = file!;
                        // dropdownValue = null;
                      });
                    }
                  },
                  items: filenames.map<DropdownMenuItem<String>>((String file) {
                    return DropdownMenuItem(value: file, child: Text(file));
                  }).toList(),
                ),

                TextField(
                  controller: maxSpeedText,
                  decoration: const InputDecoration(
                    labelText: 'Robot Speed ',
                    suffixText: 'M/s',
                    // suffixStyle: TextStyle(
                    //   color: Colors.grey,
                    //   fontSize: 14,
                    // ),
                  ),
                ),
                TextField(
                  controller: obstacleDistanceText,
                  decoration: const InputDecoration(
                    labelText: 'Obstacle Distance',
                    suffixText: 'M',
                  ),
                ),
                TextField(
                  controller: cameraobstacleDistanceText,
                  decoration: const InputDecoration(
                    labelText: 'Camera Obstacle Distance',
                    suffixText: 'M',
                  ),
                ),
                TextField(
                  controller: humanWidthText,
                  decoration: const InputDecoration(
                    labelText: 'Human Width',
                    suffixText: 'M',
                  ),
                ),
              ],
            );
          })),
          actions: [
            TextButton(
              onPressed: () {
                //replay button callback
                String errormsg;
                String datatype = 'robo9_msgs/RobotSetting';
                double maxspeed = double.parse(maxSpeedText.text);
                double obstacledistance =
                    double.parse(obstacleDistanceText.text);
                double cameraobstacledistance =
                    double.parse(cameraobstacleDistanceText.text);
                // print("check dropdownvalue");
                // print(dropdownValue);
                String filename = "/opt/robo9/record_path/${dropdownValue}.txt";
                double humanwidth = double.parse(humanWidthText.text);

                var settingmsg = {
                  'max_speed': maxspeed,
                  'obstacle_distance': obstacledistance,
                  'camera_obstacle_distance': cameraobstacledistance,
                  'follow_path_file': filename,
                  'human_width': humanwidth
                };
                errormsg = _check_msg_vality(settingmsg);
                if (dropdownValue == '') {
                  errormsg = 'empty filename';
                }
                if (errormsg == "") {
                  /******** send param setting *********/
                  context.read<RosBloc>().add(const RosSetParamEvent(
                      '/EbenezerPathPlanner/return_home', false));

                  context.read<RosBloc>().add(RosSetParamEvent(
                      '/move_client/path_file_name', filename));

                  context.read<RosBloc>().add(
                      RosSetParamEvent('/base_drive/robot_speed', maxspeed));

                  context.read<RosBloc>().add(RosSetParamEvent(
                      '/move_client/lidar_obstacle_distance',
                      obstacledistance));

                  context.read<RosBloc>().add(RosSetParamEvent(
                      '/move_client/camera_obstacle_distance',
                      cameraobstacledistance));

                  context.read<RosBloc>().add(
                      RosSetParamEvent('/move_client/human_width', humanwidth));

                  // /****** publish setting update ********/
                  context.read<RosBloc>().add(RosPublishEvent(
                      '/robot_system/update_setting', datatype, settingmsg));
                  // print("should pop windows");
                  Navigator.of(context).pop();
                  int data = 1;
                  Map<String, dynamic> json = {"data": data};
                  context.read<RosBloc>().add(RosPublishEvent(
                      'robot_system/setting_request', 'std_msgs/Int16', json));
                  // context.read<RosBloc>().add(RosSubsribeEvent(
                  //     rosInfoHandler, '/robotinfo', 'robo9_msgs/RobotInfo'));
                  Map<String, dynamic> cancel = {};
                  context.read<RosBloc>().add(RosPublishEvent(
                      '/move_base/cancel', 'actionlib_msgs/GoalID', cancel));
                } else {
                  showErrorDialog(context, errormsg);
                }
              },
              child: const Text('Replay'),
            ),
            TextButton(
              onPressed: () {
                //Update button callback
                String errormsg;
                String datatype = 'robo9_msgs/RobotSetting';
                double maxspeed = double.parse(maxSpeedText.text);
                double obstacledistance =
                    double.parse(obstacleDistanceText.text);
                double cameraobstacledistance =
                    double.parse(cameraobstacleDistanceText.text);
                // print("check dropdownvalue");
                // print(dropdownValue);
                String filename = "/opt/robo9/record_path/${dropdownValue}.txt";
                double humanwidth = double.parse(humanWidthText.text);

                var settingmsg = {
                  'max_speed': maxspeed,
                  'obstacle_distance': obstacledistance,
                  'camera_obstacle_distance': cameraobstacledistance,
                  'follow_path_file': filename,
                  'human_width': humanwidth
                };

                errormsg = _check_msg_vality(settingmsg);
                if (dropdownValue == '') {
                  errormsg = 'empty filename';
                }
                if (errormsg == "") {
                  print("enter block");
                  context.read<RosBloc>().add(const RosSetParamEvent(
                      '/EbenezerPathPlanner/return_home', false));

                  context.read<RosBloc>().add(RosSetParamEvent(
                      '/move_client/path_file_name', filename));

                  context.read<RosBloc>().add(
                      RosSetParamEvent('/base_drive/robot_speed', maxspeed));

                  context.read<RosBloc>().add(RosSetParamEvent(
                      '/move_client/lidar_obstacle_distance',
                      obstacledistance));

                  context.read<RosBloc>().add(RosSetParamEvent(
                      '/move_client/camera_obstacle_distance',
                      cameraobstacledistance));

                  context.read<RosBloc>().add(
                      RosSetParamEvent('/move_client/human_width', humanwidth));

                  /****** publish setting update ********/
                  context.read<RosBloc>().add(RosPublishEvent(
                      '/robot_system/update_setting', datatype, settingmsg));

                  Map<String, dynamic> cancel = {};
                  context.read<RosBloc>().add(RosPublishEvent(
                      '/move_base/cancel', 'actionlib_msgs/GoalID', cancel));
                  /*** trigger save file action ****/

                  //pending....
                  String topic = 'app_com/file_operation';
                  String datatype_fo = 'std_msgs/String';
                  String msg = "3," + "dummy";
                  Map<String, dynamic> json = {"data": msg};
                  context
                      .read<RosBloc>()
                      .add(RosPublishEvent(topic, datatype_fo, json));
                  Navigator.of(context).pop();
                  int data = 1;
                  Map<String, dynamic> json_2 = {"data": data};
                  context.read<RosBloc>().add(RosPublishEvent(
                      'robot_system/setting_request',
                      'std_msgs/Int16',
                      json_2));
                  context.read<RosBloc>().add(RosSubsribeEvent(
                      rosInfoHandler, '/robotinfo', 'robo9_msgs/RobotInfo'));
                } else {
                  showErrorDialog(context, errormsg);
                }
              },
              child: const Text('Update'),
            ),
          ],
        )
            .animate()
            .fadeIn(curve: Curves.easeIn)
            .scale(curve: Curves.easeInOutExpo);
      },
    );
  }

  Future<bool> _showRecordDialog(BuildContext pcontext) {
    Completer<bool> completer = Completer<bool>();
    showDialog(
      context: pcontext,
      builder: (pcontext) {
        return BlocProvider<RosBloc>.value(
          value: context.read<RosBloc>(),
          child: RecordDialog(
            onComplete: (bool shouldStartRecording) {
              completer.complete(shouldStartRecording);
            },
          ),
        );
      },
    );
    return completer.future;
  }

  // 在需要显示对话框的地方调用这个函数
  Future<bool> _showSavePathDialog(BuildContext pcontext) {
    Completer<bool> completer = Completer<bool>();
    showDialog(
      context: pcontext,
      builder: (pcontext) {
        return BlocProvider<RosBloc>.value(
          value: context.read<RosBloc>(),
          child: SaveDialog(
            onComplete: (bool save) {
              completer.complete(save);
            },
          ),
        );
      },
    );
    return completer.future;
  }

  void _toggleButton(int index) {
    setState(() {
      _isSelected = [index == 0, index == 1];
      if (index == 0) {
        _isSliderEnabled = true;
      } else {
        _isSliderEnabled = false;
      }
    });
  }
  // @override
  // void initState() {
  //   super.initState();

  //   // Timer(const Duration(seconds: 1), () {
  //   // print("call rossub....");
  //   // context.read<RosBloc>().add(
  //   //     RosSubsribeEvent(subscribeHandler, '/client_count', 'std_msgs/Int32'));
  //   // });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            actions: [
              PopupMenuButton<MenuAction>(
                onSelected: (value) async {
                  switch (value) {
                    case MenuAction.Disconnect:
                      final disconnect = await showDisconnectDialog(context);
                      if (disconnect) {
                        context.read<RosBloc>().add(const RosDisconnectEvent());
                      }
                  }
                },
                itemBuilder: (BuildContext context) =>
                    <PopupMenuEntry<MenuAction>>[
                  const PopupMenuItem<MenuAction>(
                    value: MenuAction.Disconnect,
                    child: Text('Disconnect'),
                  ),
                ],
              ),
            ],
            title: Padding(
              padding:
                  EdgeInsets.only(left: MediaQuery.of(context).size.width / 5),
              child: const Text(
                'Path Follow System',
                style: TextStyle(
                    fontSize: 20, // 设置字体大小
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
            backgroundColor: greyblue),
        backgroundColor: lightblue,
        body: Column(
          children: [
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 10, 10, 0),
                child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  BatteryIndicator(
                    trackHeight: 25.0,
                    value: _battery,
                    trackPadding: 1,
                    barColor: Colors.lightGreen,
                    icon: Text(
                      '${(_battery * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 16, // 设置字体大小
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 2.5,
                    height: MediaQuery.of(context).size.height / 8,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // 点击 'Return Home' 按钮的操作
                        // context.read<RosBloc>().add(const RosSetParamEvent(
                        //     "/follow_path/emergency_stop", true));
                      },
                      style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          backgroundColor: lightblue,
                          side: BorderSide(
                            color: greyblue, // 边框线颜色
                            width: 2, // 边框线宽度
                          )),
                      icon: Icon(
                        Icons.home,
                        color: !_isRecording ? Colors.blue : Colors.grey,
                        size: 35,
                      ),
                      label: Text(
                        'Return Home',
                        style: TextStyle(
                            fontSize: 18, // 设置字体大小
                            color: text),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 2.5,
                    height: MediaQuery.of(context).size.height / 8,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // 点击 'Stop' 按钮的操作
                        setState(() {
                          if (!_isRecording) {
                            _isPressed = !_isPressed;
                          }
                        });
                        _isStop = !_isStop;
                        context.read<RosBloc>().add(RosSetParamEvent(
                            'follow_path/emergency_stop', _isStop));
                      },
                      style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          backgroundColor: lightblue,
                          side: BorderSide(
                            color: greyblue, // 边框线颜色
                            width: 2, // 边框线宽度
                          )),
                      icon: Icon(
                        Icons.stop,
                        color: !_isRecording
                            ? _isPressed
                                ? Colors.red
                                : Colors.blue
                            : Colors.grey,
                        size: 35,
                      ),
                      label: Text(
                        'Stop',
                        style: TextStyle(
                            fontSize: 18, // 设置字体大小
                            color: text),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 2.5,
                    height: MediaQuery.of(context).size.height / 8,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        // 点击 'Record' 按钮的操作
                        if (!_isRecording) {
                          Future<bool> startRecording =
                              _showRecordDialog(context);
                          startRecording.then((bool shouldStart) {
                            if (shouldStart) {
                              setState(() {
                                _isRecording = !_isRecording;
                              });
                            }
                          });
                        } else {
                          Future<bool> startRecording =
                              _showSavePathDialog(context);
                          startRecording.then((bool shouldStart) {
                            if (shouldStart) {
                              setState(() {
                                _isRecording = !_isRecording;
                              });
                            }
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(20), // 设置圆角矩形的圆角程度
                          ),
                          backgroundColor: lightblue,
                          side: BorderSide(
                            color: greyblue, // 边框线颜色
                            width: 2, // 边框线宽度
                          )),
                      icon: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: _isRecording ? Colors.red : Colors.blue,
                              width: 2),
                        ),
                        child: Center(
                          child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 10),
                              child: _isRecording
                                  ? Center(
                                      child: Icon(Icons.stop,
                                          key: ValueKey<bool>(_isRecording),
                                          color: Colors.red),
                                    )
                                  : Center(
                                      child: Icon(Icons.fiber_manual_record,
                                          key: ValueKey<bool>(_isRecording),
                                          color: Colors.blue),
                                    )),
                        ),
                      ),

                      // RecordButton(), // 添加图标
                      label: Text(
                        'Record',
                        style: TextStyle(
                            fontSize: 18, // 设置字体大小
                            color: text),
                      ), // 添加文字
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 2.5,
                    height: MediaQuery.of(context).size.height / 8,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        int data = 1;
                        Map<String, dynamic> json = {"data": data};
                        context.read<RosBloc>().add(RosPublishEvent(
                            'robot_system/setting_request',
                            'std_msgs/Int16',
                            json));
                        context.read<RosBloc>().add(RosPublishEvent(
                            'app_com/file_list_request',
                            'std_msgs/Int8',
                            json));
                        !_isRecording ? _showReplayDialog(context) : {};
                      },
                      style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(20), // 设置圆角矩形的圆角程度
                          ),
                          backgroundColor: lightblue,
                          side: BorderSide(
                            color: greyblue, // 边框线颜色
                            width: 2, // 边框线宽度
                          )),
                      icon: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: !_isRecording ? Colors.blue : Colors.grey,
                              width: 2),
                        ),
                        child: Center(
                          child: Icon(Icons.play_arrow,
                              color: !_isRecording
                                  ? Colors.blue[600]
                                  : Colors.grey),
                        ),
                      ), // 添加图标
                      label: Text('Replay',
                          style: TextStyle(
                              fontSize: 18, // 设置字体大小
                              color: text)), // 添加文字
                    ),
                  ),
                ],
              ),
            ),

            // TODO: SPEED BAR
            // Expanded(
            //   flex: 2,
            //   child:
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Slider(
                  value: _sliderValue,
                  min: 0.2,
                  max: 0.5,
                  divisions: 100,
                  onChanged: (newValue) {
                    setState(() {
                      _sliderValue = newValue;
                      context.read<RosBloc>().add(RosSetParamEvent(
                          '/base_drive/robot_speed', _sliderValue));
                    });
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Text(
                    '${_sliderValue.toStringAsFixed(2)} m/s',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            // ),
            ToggleButtons(
              isSelected: _isSelected,
              onPressed: _toggleButton,
              children: const [
                Icon(Icons.lock_open),
                Icon(Icons.lock),
              ],
            ),
            Expanded(
              flex: 3,
              child: Center(
                child: Joystick(
                  stick: const MyJoystickStick(),
                  listener: (detail) {
                    if (_isSliderEnabled) {
                      String topic = '/cmd_vel';
                      String datatype = 'geometry_msgs/Twist';
                      // print("Y value : ${detail.y}");
                      // print("X value : ${detail.x}");
                      double y = detail.y;
                      double x = detail.x;
                      if (detail.y < 0.2 && detail.y > -0.2) {
                        y = 0;
                      }
                      if (detail.y >= 0.2) {
                        x = -x;
                      }
                      var linear = {'x': -y * _sliderValue, 'y': 0.0, 'z': 0.0};
                      var angular = {'x': 0.0, 'y': 0.0, 'z': -x * 0.75};
                      var twist = {'linear': linear, 'angular': angular};

                      context
                          .read<RosBloc>()
                          .add(RosPublishEvent(topic, datatype, twist));
                    }
                  },
                ),
              ),
            )
            // 速度条
          ],
        ));
  }
}
