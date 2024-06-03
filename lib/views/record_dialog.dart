import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:robo9_mobile_app/Service/Bloc/ros_bloc.dart';
import 'package:robo9_mobile_app/Service/Bloc/ros_event.dart';

class RecordDialog extends StatefulWidget {
  final void Function(bool) onComplete;
  const RecordDialog({super.key, required this.onComplete});
  @override
  State<RecordDialog> createState() => _RecordDialogState();
}

class _RecordDialogState extends State<RecordDialog> {
  bool _isSaved = false;
  int _feedback = 0;
  late final TextEditingController _filename;

  @override
  void initState() {
    _filename = TextEditingController();
    super.initState();
    context.read<RosBloc>().add(RosSubsribeEvent(
        feedbackHandler, '/app_com/file_request_feedback', 'std_msgs/Int8'));
  }

  Future<void> feedbackHandler(Map<String, dynamic> msg) async {
    _feedback = msg['data'];
  }

  @override
  Widget build(BuildContext context) {
    // TextEditingController filename = TextEditingController();
    return AlertDialog(
      title: const Text('Record'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _filename,
            decoration: const InputDecoration(
              labelText: 'File Save',
              hintText: 'Filename',
              hintStyle: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  // 保存文件的逻辑
                  if (_filename.text == '') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please input a valid name!'),
                      ),
                    );
                  } else {
                    String topic = 'app_com/file_operation';
                    String datatype = 'std_msgs/String';
                    String msg = "1," + _filename.text;
                    Map<String, dynamic> json = {"data": msg};
                    context
                        .read<RosBloc>()
                        .add(RosPublishEvent(topic, datatype, json));
                    await Future.delayed(const Duration(milliseconds: 500));
                    setState(() {
                      if (_feedback == 0) {
                        _isSaved = true;
                      } else {
                        _isSaved = false;
                      }

                      // filename.text = filename.text;
                    });
                    // 在这里添加保存文件的代码
                    if (_feedback == 0) {
                      _feedback = 0;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('File saved successfully!'),
                        ),
                      );
                    } else if (_feedback == 1) {
                      _feedback = 0;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('File already exits!'),
                        ),
                      );
                    }
                  }
                },
                child: const Text('Save File'),
              ),
            ],
          ),
          if (_isSaved)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // 返回 true 并关闭对话框
                    bool data = true;
                    Map<String, dynamic> json = {"data": data};
                    context.read<RosBloc>().add(RosPublishEvent(
                        '/move_client/save_init', 'std_msgs/Bool', json));
                    // widget.onComplete(true);
                    // Navigator.of(context).pop();
                  },
                  child: const Text('Save Initial'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // 返回 true 并关闭对话框
                    context.read<RosBloc>().add(RosSetParamEvent(
                        '/ebenezer_train/record_output_file', _filename.text));
                    int data = 1;
                    Map<String, dynamic> json = {"data": data};
                    context.read<RosBloc>().add(RosPublishEvent(
                        '/ebenezer_train/record', 'std_msgs/Int16', json));
                    widget.onComplete(true);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Start Record'),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class SaveDialog extends StatefulWidget {
  final void Function(bool) onComplete;
  const SaveDialog({super.key, required this.onComplete});

  @override
  State<SaveDialog> createState() => _SaveDialogState();
}

class _SaveDialogState extends State<SaveDialog> {
  // final bool _isPathSelected = false;
  // final String _selectedPath = '';
  String _recordfile = '';
  Future<void> recordfileHandler(Map<String, dynamic> msg) async {
    _recordfile = msg['value'];
    _recordfile = _recordfile.replaceAll('"', '');
    // print("file get is : ${_recordfile}");
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Save Path?'),
      // content: Column(
      //   mainAxisSize: MainAxisSize.min,
      //   crossAxisAlignment: CrossAxisAlignment.start,
      //   children: [
      //     OutlinedButton(
      //       onPressed: () async {
      //         // 打开文件选择器,让用户选择保存路径
      //         final directory = await FilePicker.platform.getDirectoryPath();
      //         if (directory != null) {
      //           // 在这里保存文件到选择的路径
      //           setState(() {
      //             _isPathSelected = true;
      //             _selectedPath = directory;
      //           });
      //           print('Saved file to: $directory');
      //         }
      //       },
      //       child: const Text('Save Path'),
      //     ),
      //     // if()

      //     Text(
      //       _isPathSelected ? _selectedPath : 'No path selected',
      //     ),
      //   ],
      // ),
      actions: [
        ElevatedButton(
          onPressed: () async {
            int data = 1;
            Map<String, dynamic> json = {"data": data};
            context.read<RosBloc>().add(RosPublishEvent(
                '/ebenezer_train/clear', 'std_msgs/Int16', json));

            context.read<RosBloc>().add(RosGetParamEvent(
                '/ebenezer_train/record_output_file', recordfileHandler));
            await Future.delayed(const Duration(seconds: 1));
            if (_recordfile != '') {
              String topic = 'app_com/file_operation';
              String datatype = 'std_msgs/String';
              String msg = "0," + _recordfile;
              Map<String, dynamic> operation = {"data": msg};
              context
                  .read<RosBloc>()
                  .add(RosPublishEvent(topic, datatype, operation));
              context.read<RosBloc>().add(
                  RosSetParamEvent('/ebenezer_train/record_output_file', ''));
              // print("I am going to remove file : ${filename_remove}");
            }
            widget.onComplete(true);
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            int data = 1;
            Map<String, dynamic> json = {"data": data};
            context.read<RosBloc>().add(RosPublishEvent(
                '/ebenezer_train/save', 'std_msgs/Int16', json));
            widget.onComplete(true);
            Navigator.of(context).pop();
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}
