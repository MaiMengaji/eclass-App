import 'dart:async';
import 'dart:io';
import 'package:eclass/common/apidata.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zoom_sdk/zoom_options.dart';
import 'package:flutter_zoom_sdk/zoom_view.dart';
import 'package:flutter/foundation.dart';

class ZoomMeetingScreen extends StatefulWidget {
  final userName;
  final meetingId;
  final meetingPassword;

  ZoomMeetingScreen({this.userName, this.meetingId, this.meetingPassword});

  @override
  _MeetingWidgetState createState() => _MeetingWidgetState();
}

class _MeetingWidgetState extends State<ZoomMeetingScreen> {
  Timer timer;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    joinMeeting(context);
  }

  @override
  Widget build(BuildContext context) {
    // new page needs scaffolding!
    return Scaffold(
      appBar: AppBar(
        title: const Text('Initializing meeting'),
      ),
      body: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: Colors.blue, // background
            onPrimary: Colors.white, // foreground
          ),
          onPressed: () async {
            joinMeeting(context);
          },
          child: const Text('Join'),
        ),
      ),
    );
  }

  //API KEY & SECRET is required for below methods to work
  //Join Meeting With Meeting ID & Password
  joinMeeting(BuildContext context) {
    bool _isMeetingEnded(String status) {
      var result = false;

      if (Platform.isAndroid) {
        result = status == "MEETING_STATUS_DISCONNECTING" ||
            status == "MEETING_STATUS_FAILED";
      } else {
        result = status == "MEETING_STATUS_IDLE";
      }

      return result;
    }

    ZoomOptions zoomOptions = ZoomOptions(
      domain: "zoom.us",
      appKey: APIData.zoomAppKey, //API KEY FROM ZOOM
      appSecret: APIData.zoomSecretKey, //API SECRET FROM ZOOM
    );
    var meetingOptions = ZoomMeetingOptions(
        userId: widget.userName,

        /// pass username for join meeting only --- Any name eg:- EVILRATT.
        meetingId: widget.meetingId,

        /// pass meeting id for join meeting only
        meetingPassword: widget.meetingPassword,

        /// pass meeting password for join meeting only
        disableDialIn: "true",
        disableDrive: "true",
        disableInvite: "true",
        disableShare: "true",
        disableTitlebar: "false",
        viewOptions: "true",
        noAudio: "false",
        noDisconnectAudio: "false");

    var zoom = ZoomView();
    zoom.initZoom(zoomOptions).then((results) {
      if (results[0] == 0) {
        zoom.onMeetingStatus().listen((status) {
          if (kDebugMode) {
            print("[Meeting Status Stream] : " + status[0] + " - " + status[1]);
          }
          if (_isMeetingEnded(status[0])) {
            if (kDebugMode) {
              print("[Meeting Status] :- Ended");
            }
            timer.cancel();
          }
        });
        if (kDebugMode) {
          print("listen on event channel");
        }
        zoom.joinMeeting(meetingOptions).then((joinMeetingResult) {
          timer = Timer.periodic(const Duration(seconds: 2), (timer) {
            zoom.meetingStatus(meetingOptions.meetingId).then((status) {
              if (kDebugMode) {
                print("[Meeting Status Polling] : " +
                    status[0] +
                    " - " +
                    status[1]);
              }
            });
          });
        });
      }
    }).catchError((error) {
      if (kDebugMode) {
        print("[Error Generated] : " + error);
      }
    });
  }
}
