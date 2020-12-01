// import 'package:flutter/material.dart';
// import 'package:flutter_phoenix/flutter_phoenix.dart';
// import 'package:flutter_sudoku/aisa.dart';
// import 'package:flutter_sudoku/globalvariables.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class EndPage extends StatefulWidget {
//   @override
//   _EndPageState createState() => _EndPageState();
// }

// class _EndPageState extends State<EndPage> {
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async => false,
//       child: Scaffold(
//         body: Container(
//             padding: EdgeInsets.all(20),
//             child: ListView(
//               children: <Widget>[
//                 SizedBox(
//                   height: 20,
//                 ),
//                 Text(
//                   'Hello player,',
//                   style: GoogleFonts.lato(
//                       fontSize: 30, fontWeight: FontWeight.bold),
//                 ),
//                 SizedBox(
//                   height: 30,
//                 ),
//                 Text('You’ve found me, the man behind the curtain.'),
//                 SizedBox(
//                   height: 10,
//                 ),
//                 Text(
//                     'Well, I guess we know the answer to “Would you kill for me?” now. Lol. Okay, maybe you wouldn’t kill but you’d certainly let an AI die. AISA 291 is fine, by the way.'),
//                 SizedBox(
//                   height: 10,
//                 ),
//                 Text(
//                     'You have shown extraordinary persistence to get here and I am touched that you’ve devoted your time to this my labour of love.'),
//                 SizedBox(
//                   height: 10,
//                 ),
//                 Text(
//                     'It’s currently 12:59 am on the 22nd of April 2020. I am exhausted and had to take a break from coding. Cam Cam is helping me code the puzzles for the Inhuman difficulty level. I have been working almost nonstop for five days now. I just realised that I have to disable editing on the form fields (or the cells) that contain prefilled values for each cell on each puzzle board in each difficulty. That is 81 changes for each table on 9 pages for 6 difficulty levels. That works out to 4,374 unique changes. I can’t copy and paste or find and replace here; each change is unique to each specific puzzle. I have reached the end of my endurance for tonight. Currently, I have written more than a hundred thousand lines of code.'),
//                 SizedBox(
//                   height: 10,
//                 ),
//                 Text(
//                     'This is just a glimpse of what it took to make this app. What started out as a simple ad-free Sudoku app has turned into something a bit more.'),
//                 SizedBox(
//                   height: 10,
//                 ),
//                 Text(
//                     'I felt like no one would reach this far. I remember telling a friend that no one would ever to make it to the end. And so I was going to spill of sorts of secrets and post my embarrassing baby pictures.'),
//                 SizedBox(
//                   height: 10,
//                 ),
//                 Text(
//                     'But that lack of faith would be doing you a disservice, dear player.'),
//                 SizedBox(
//                   height: 10,
//                 ),
//                 // Text(
//                 //     'I have been told several times that I push people away or that I behave as if everyone is out to hurt me. I agree. Blame it on my Fe trickster lol. You could even think of AISA 291 as kind of a representation of this behaviour.'),
//                 // SizedBox(
//                 //   height: 10,
//                 // ),
//                 Text(
//                     'So I decided to have faith that you would find me. Now that you\'re here, I would like to express my appreciation for all these fine people:'),
//                 SizedBox(
//                   height: 10,
//                 ),
//                 Text('•	Cam Cam'),
//                 Text('•	K'),
//                 // SizedBox(
//                 //   height: 10,
//                 // ),
//                 Text('•	Seidu!'),
//                 // SizedBox(
//                 //   height: 10,
//                 // ),
//                 Text('•	Google and'),
//                 // SizedBox(
//                 //   height: 10,
//                 // ),
//                 Text('•	Stack Overflow. Lol'),
//                 SizedBox(
//                   height: 10,
//                 ),
//                 Text('This couldn’t have been possible without them.'),
//                 SizedBox(
//                   height: 10,
//                 ),
//                 Text(
//                     'This also wouldn’t have been possible without the wonderful people who created the following packages:'),
//                 SizedBox(
//                   height: 10,
//                 ),
//                 Text('•	google_fonts: ^0.5.0+1'),
//                 // SizedBox(
//                 //   height: 10,
//                 // ),
//                 Text('•	font_awesome_flutter: ^8.8.1'),
//                 // SizedBox(
//                 //   height: 10,
//                 // ),
//                 Text('•	carousel_slider: ^1.3.1'),
//                 // SizedBox(
//                 //   height: 10,
//                 // ),
//                 Text('•	shared_preferences: ^0.5.6+2'),
//                 SizedBox(
//                   height: 10,
//                 ),
//                 Text(
//                     'When I was in a primary school some misty years ago, the headmistress called me into her office. I was scared stiff because I thought she was going to punish me for some wrong I had done. But instead she gave me a copy of Great Expectations. She asked me to go and read it and come tell her what I thought and return the book. According to her, this was because I was “a promising child.” Whether or not I have lived up to her expectation is up for debate, but she gave me confidence in myself. And I am grateful for that.'),
//                 SizedBox(
//                   height: 10,
//                 ),
//                 Text(
//                     'I am also grateful for my parents who sacrificed time, energy, and their own dreams to give me what they never had.'),
//                 SizedBox(
//                   height: 10,
//                 ),
//                 Text(
//                     'I am grateful for the wonderful friends I have, who put up with the thorns underneath my petals.'),
//                 SizedBox(
//                   height: 10,
//                 ),
//                 Text(
//                     'I am grateful for my boss. He makes sure I don’t starve to death on the street.'),
//                 SizedBox(
//                   height: 10,
//                 ),
//                 Text('I am grateful for the beautiful planet I live on.'),
//                 SizedBox(
//                   height: 10,
//                 ),
//                 Text(
//                     'I am grateful that plantain was created. I am also grateful that deep frying is a thing. I am grateful these two can be put together.'),
//                 SizedBox(
//                   height: 10,
//                 ),
//                 Text(
//                     'I am grateful for Hans Zimmer’s Interstellar soundtrack. (It’s auditory balm for the soul!)'),
//                 SizedBox(
//                   height: 10,
//                 ),
//                 Text(
//                     'Why am I telling you all this? This app ended up becoming a bit of a metaphor and a mirror. We all have AISA 291s that we defend our insecurities with. I have decided to be more grateful because…'),
//                 SizedBox(
//                   height: 10,
//                 ),
//                 Center(
//                   child: Text(
//                     'A person who does not appreciate their blessings has no blessings.',
//                     style: GoogleFonts.lato(
//                       fontStyle: FontStyle.italic,
//                     ),
//                   ),
//                 ),
//                 SizedBox(
//                   height: 10,
//                 ),
//                 Text(
//                     'So last but definitely not the least, thank you dear player for this time we have had together. Te flows into Fi for me. Go forth and be thankful.'),
//                 SizedBox(
//                   height: 80,
//                 ),
//                 Text('Yours gratefully,'),
//                 SizedBox(
//                   height: 10,
//                 ),
//                 Text('The Programmer'),
//                 SizedBox(
//                   height: 10,
//                 ),
//                 // Image(image: AssetImage('images/prog.jpg')),
//                 // Center(child: Text('(And a person who loves him :D)')),
//                 // SizedBox(
//                 //   height: 40,
//                 // ),
//                 Divider(),
//                 SizedBox(
//                   height: 40,
//                 ),
//                 Image(image: AssetImage('images/cake.jpg')),
//                 SizedBox(
//                   height: 10,
//                 ),
//                 Center(
//                     child: Text(
//                         'And oh, here’s your cake. AISA will email it you. Check your spam folder :)')),
//                 // SizedBox(
//                 //   height: 10,
//                 // ),
//                 // Divider(),
//                 SizedBox(
//                   height: 30,
//                 ),
//                 Container(
//                     child: Column(
//                   children: <Widget>[
//                     FlatButton(
//                       onPressed: () async {
//                         print(level);
//                         isComplete = true;
//                         difficulty = "Complete";
//                         final SharedPreferences prefs =
//                             await SharedPreferences.getInstance();
//                         prefs.setInt("level", level);
//                         prefs.setInt("stringIndex", stringIndex);
//                         prefs.setInt("totalScore", totalScore);
//                         prefs.setBool("isComplete", isComplete);
//                         prefs.setString("UserName", userName);
//                         Phoenix.rebirth(context);
//                       },
//                       child: Text(
//                         'Goodbye, player',
//                         style: GoogleFonts.architectsDaughter(),
//                       ),
//                       color: colors[colorindex],
//                     ),
//                   ],
//                 )),
//                 SizedBox(height: 30),
//                 Divider(),
//                 Center(
//                     child: FlatButton(
//                   child: Text(
//                     'Built with Flutter',
//                     style: GoogleFonts.architectsDaughter(),
//                   ),
//                   onPressed: () {
//                     showAboutDialog(context: context);
//                   },
//                 ))
//               ],
//             )),
//       ),
//     );
//   }
// }
