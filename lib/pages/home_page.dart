import 'dart:io';

import 'package:flutter/material.dart';
import 'package:template/pages/crop_page.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  List<String> musicList = [
    'Music 1',
    'Music 2',
    'Music 3',
    'Music 4',
    'Music 5',
  ];
  String selectedMusic = 'Music 1';
  double start = 0;
  double end = 0;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  void setAudio(double start, double end) {
    widget.start = start;
    widget.end = end;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Video Music Details',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              fontFamily: 'Times New Roman',
            ),
          ),
        ),
        backgroundColor: Colors.white,
        leading: Icon(Icons.arrow_back),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 15,
              children: [
                Text(
                  'Total Video Duraction: 3:45',
                ),
                Text(
                  'Total Music Duraction: 3:45',
                ),
                Text(
                  'Selected Music:',
                ),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton(
                      elevation: 16,
                      onChanged: (value) => setState(() {
                        widget.selectedMusic = value.toString();
                      }),
                      items: widget.musicList.map((String value) {
                        return DropdownMenuItem(
                          value: value,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(value),
                          ),
                        );
                      }).toList(),
                      value: widget.selectedMusic,
                      icon: Visibility(
                          visible: false, child: Icon(Icons.arrow_downward)),
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AudioCropperPage(
                                name: 'hello',
                                setAudio: setAudio,
                                url:
                                    '${Directory.systemTemp.path}/generatedMusic.mp3')),
                      )
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(Icons.music_note),
                        Text('Crop Music',
                            style: TextStyle(
                              color: Colors.grey[800],
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                              fontFamily: 'Times New Roman',
                              decoration: TextDecoration.underline,
                            )),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          Container(
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 14,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  child: Text(
                    'Save Video',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(Colors.grey[800]),
                    fixedSize: MaterialStateProperty.all(Size(250, 45)),
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text('Save',
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        fontFamily: 'Times New Roman',
                      )),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.white),
                    fixedSize: MaterialStateProperty.all(Size(250, 45)),
                    side: MaterialStateProperty.all(
                      BorderSide(
                        color: Colors.black,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
