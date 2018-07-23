import 'package:flutter/material.dart';
import 'profile.dart';
import 'prompt_wait.dart';
class ProfilePage extends StatefulWidget {
  const ProfilePage({this.userId});

  final String userId;

  _ProfilePage createState() => new _ProfilePage(this.userId);
}

class _ProfilePage extends State<ProfilePage> {
  _ProfilePage(this.userId);
  final String userId;
  int current_step = 0;
  List<Profile> steps = [
    new Profile(
      // Title of the Step
        title: new Text(getTimeStamp(new DateTime.now())),
        // Content, it can be any widget here. Using basic Text for this example
        content: new Text("来鞋垫东西吧"),
        subtitle: new Text("心情愉悦"),
        state: StepState.disabled,
        isActive: true),
    new Profile(
        title: new Text("Step 2"),
        content: new Text("World!"),
        state: StepState.disabled,

        // You can change the style of the step icon i.e number, editing, etc.
        isActive: true),
    new Profile(
        title: new Text("Step 3"),
        content: new Text("Hello World!"),
        state: StepState.disabled,

        isActive: true),
    new Profile(
        title: new Text("Step 5"),
        content: new Text("Hello World!"),
        state: StepState.disabled,

        isActive: true),
    new Profile(
        title: new Text("Step 6"),
        content: new Text("Hello World!"),
        state: StepState.disabled,

        isActive: true),
  ];

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
      appBar: new AppBar(
        title: const Text('Profile',
            style: const TextStyle(
                fontFamily: "Billabong", color: Colors.black, fontSize: 20.0)),
        centerTitle: true,
        backgroundColor: Colors.white10,
      ),
      body: new Container(
          child: new Profiler(
            // Using a variable here for handling the currentStep
            currentStep: this.current_step,
            // List the steps you would like to have
            steps: steps,
            // Define the type of Stepper style
            // StepperType.horizontal :  Horizontal Style
            // StepperType.vertical   :  Vertical Style
            type: ProfileType.vertical,
            // Know the step that is tapped
            onStepTapped: (step) {
              // On hitting step itself, change the state and jump to that step
              setState(() {
                // update the variable handling the current step value
                // jump to the tapped step
                current_step = step;
              });
              // Log function call
              print("onStepTapped : " + step.toString());
            },
            onStepCancel: () {
              // On hitting cancel button, change the state
              setState(() {
                // update the variable handling the current step value
                // going back one step i.e subtracting 1, until its 0
                if (current_step > 0) {
                  current_step = current_step - 1;
                } else {
                  current_step = 0;
                }
              });
              // Log function call
              print("onStepCancel : " + current_step.toString());
            },
            // On hitting continue button, change the state
            onStepContinue: () {
              setState(() {
                // update the variable handling the current step value
                // going back one step i.e adding 1, until its the length of the step
                if (current_step < steps.length - 1) {
                  current_step = current_step + 1;
                } else {
                  current_step = 0;
                }
              });
              // Log function call
              print("onStepContinue : " + current_step.toString());
            },
          )),
    );
  }
}