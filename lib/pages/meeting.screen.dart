// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:conference_app/pages/home_screen.dart';
import 'package:conference_app/widgets/control_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:conference_app/models/meeting.details.dart';
import 'package:flutter_webrtc_wrapper/flutter_webrtc_wrapper.dart';

import '../utils/user.util.dart';
import '../widgets/remote_connection.dart';

class MeetingPage extends StatefulWidget {

  final String ? meetingId;
  final String ? name;
  final MeetingDetail meetingDetail;
  MeetingPage({
    Key? key,
    this.meetingId,
    this.name,
    required this.meetingDetail,
  }) : super(key: key);

  @override
  State<MeetingPage> createState() => _MeetingPageState();
}

class _MeetingPageState extends State<MeetingPage> {
  final _localRenderer = RTCVideoRenderer();
  final Map<String, dynamic> mediaConstraints = { "audio":true, "video":true};
  bool isConnectionFailed = false;
  WebRTCMeetingHelper ? meetingHelper;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: _buildMeetingRoom(),
      bottomNavigationBar: ControlPanel(
        onAudioToggle: onAudioToggle ,
        onVideoToggle: onVideoToggle,
        videoEnabled: isVideoEnabled(),
        audioEnabled: isAudioEnabled(),
        isConnectionFailed: isConnectionFailed,
        onReconnect: handleReconnect,
        onMeetingEnd: onMeetingEnd,
      ),
    );
  }

  void startMeeting() async{
    final String userId = await loadUserId();
    meetingHelper = WebRTCMeetingHelper(
        url:"http://192.168.43.158:5000",
        meetingId: widget.meetingDetail.id,
        userId: userId,
        name:widget.name,
     );

     MediaStream _localStream = 
     await navigator.mediaDevices.getUserMedia(mediaConstraints);

     _localRenderer.srcObject = _localStream;
     meetingHelper!.stream = _localStream;

     meetingHelper!.on("open",
      context, (ev, context) { 
        setState(() {
          isConnectionFailed = false;
        });
      });
           meetingHelper!.on("connection",
      context, (ev, context) { 
        setState(() {
          isConnectionFailed = false;
        });
      });
           meetingHelper!.on("user-left",
      context, (ev, context) { 
        setState(() {
          isConnectionFailed = false;
        });
      });
      // ignore: use_build_context_synchronously
      meetingHelper!.on("video-toggle",
      context, (ev, context) { 
        setState(() {
     
        });
      });
      // ignore: use_build_context_synchronously
      meetingHelper!.on("audio-toggle",
      context, (ev, context) { 
        setState(() {
         
        });
      });
      // ignore: use_build_context_synchronously
      meetingHelper!.on("meeting-end",
      context, (ev, context) { 
        setState(() {
         onMeetingEnd();
        });
      });
       // ignore: use_build_context_synchronously
       meetingHelper!.on("connection-setting-changed",
      context, (ev, context) { 
        setState(() {
   
          isConnectionFailed = false;
      
        });
      });
      meetingHelper!.on("stream-changed",
      context, (ev, context) { 
        setState(() {
       
          isConnectionFailed = false;
     
        });
      });
        setState(() {
       
        
     
        });
  }

initRenderers() async{
  await _localRenderer.initialize();
}
@override
void initState(){
  super.initState();
  initRenderers();
  startMeeting();
}
@override
void deactivate(){
  super.deactivate();
  _localRenderer.dispose();
  if(meetingHelper != null){
    meetingHelper!.destroy();
    meetingHelper = null;
  }
}

void onMeetingEnd() {
  if (meetingHelper != null){
    meetingHelper!.endMeeting();
    meetingHelper = null;
    goToHomePage();
  }
}
  

  void onAudioToggle() {
    if (meetingHelper != null){
      setState(() {
        meetingHelper!.toggleAudio();
      });
    }
  }

  void onVideoToggle() {
    if (meetingHelper != null){
      setState(() {
        meetingHelper!.toggleVideo();
      });
    }
  }
  
  _buildMeetingRoom() {
    return Stack(
      children: [
        meetingHelper != null && meetingHelper!.connections.isNotEmpty ?
        GridView.count(
          crossAxisCount:  meetingHelper!.connections.length<3? 1:2,
          children: List.generate(meetingHelper!.connections.length, (index){
            return Padding(padding: const EdgeInsets.all(1),
            child:RemoteConnection(
              renderer:meetingHelper!.connections[index].renderer,
              connection:meetingHelper!.connections[index],
            ),
            );
          }),)
          :const Center(
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Text("Waitng for participants",
              style: TextStyle(
                color: Colors.grey,
                fontSize:24
              ),
              ),),
          ),
          Positioned(bottom: 10,right: 0,
          child:SizedBox(
            width:150,
            height: 200,
            child:RTCVideoView(_localRenderer)
          ))
      ],
    );
  }

  void handleReconnect() {
    if (meetingHelper != null){
      meetingHelper?.reconnect();
    }
  }
  bool isVideoEnabled(){
    return meetingHelper != null ? meetingHelper!.videoEnabled! : false;
 
  }
 bool  isAudioEnabled(){
  return meetingHelper != null ? meetingHelper!.audioEnabled! : false;
 
 }
 
  void goToHomePage() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
  }
}


