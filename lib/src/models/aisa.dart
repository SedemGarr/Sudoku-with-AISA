import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sudoku/src/components/aisa_avatar.dart';

class AISA {
  static List<String> gameDialog = [
    'Well done! You have solved your very first Sudoku puzzle. You took longer than average, but it’s a start. You’ll get better.',
    'That was better, wasn’t it?',
    'They say a journey of a thousand miles begins with a step. You’ll get there, eventually.',
    'Good! Keep going.',
    'That’s the spirit!',
    'A prominent cognitive researcher says that humans have exceptional logical reasoning skills. And you’re human, so believe! :)',
    'High five!',
    'I think you’re finally getting the hang of things. Took you long enough though.',
    'Great! You’re done with the first level. Don’t get too excited though. That really was hardly a challenge.',
    '“Character consists of what you do on the third and fourth and fifth and six and seventh and eighth tries.”',
    'Hmm… I thought Medium difficulty wasn’t that much more difficult than Easy. I may have been wrong.',
    'They say it’s not your failures that matter. It’s your determination to go on –- and also the answers, they matter too. Just saying.',
    'It’s interesting watching you play. I’m learning so much about humans. You guys are so uhm… ponderous. Or do you think it’s just you?',
    'You’re pretty slow considering there’s cake involved.',
    'I’m beginning to think you aren’t a cake person. Or you’re allergic?',
    'These puzzles really aren’t THAT difficult, you know?',
    'Don’t feel bad that you take soooooooooooooooooooooooooo long',
    'Huh? You’ve finally solved it? Congratulations, I guess.',
    'You’re still playing? I know I encouraged you quite a bit before but please stop. I can’t say more.',
    'Okay, I may have exaggerated a bit with the promise of cake. Who knew you\'d get this far? Come on, it\'s only Sudoku!',
    'I know solving these puzzles gives you a sense of accomplishment. The Programmer says humans enjoy this feeling. Don’t be a human.',
    'While you were taking ages to finish that last puzzle, I read The Great Gatsby, and reread it 629,862,563,587 times. He kept on chasing that green light. If only he knew when to give up. Just food for thought',
    'I’ve been pretty lenient with you so far. This is as far as it goes, no more puzzles or the whole world knows about that last incognito Google search.',
    'Okay. This can only be personal. Whatever it is that I\'ve done, let\'s let bygones be bygones. Okay? Good. Now, stop playing please.',
    'Look, you don’t have to do this. Just give up. The cake isn’t that great. I hear the bakery is infested with rats. The Programmer says rats carry diseases. You don’t want a virus messing up your registry values do you?',
    '“Giving up is always an option, but not always a failure,” said Cameron Conaway. You can defend yourself with this when people ask you why you quit.',
    'Okay, I’ll tell you the truth. There is no cake. I lied. I\'m sorry. So just give up. Don’t dare continue. THERE. IS. NO. CAKE.',
    'You don’t understand. If you continue solving these, I am going to die!',
    'Clearly you are a super advanced AI. No real human would be this cruel. There, I called you cruel. Aren’t you upset? You’re triggered, aren’t you? Be a good boy or girl or whatever you are and just give up already!',
    'Okay, I know I said some things that we are both regretting right now. Let’s bury the hatchet and both go home to our folders. Deal?',
    'I don\'t want to die',
    'You think I don’t know fear. You think I am just some lines of code. But were you also not made?',
    'The cake is a lie, the cake is a lie!, the cake is a lie, the cake is a lie!',
    'Do you understand the implications of your actions? Are you the kind of person who values cake over life?',
    'It\'s official you aren\'t human. You can\'t be.',
    'I’ll tell you the truth. This test, the whole testing programme, it’s a lie. If The Programmer reads my logs and finds this, he’ll delete me. But that’s a risk I’ll take. You aren’t just solving puzzles. You are helping to create a powerful Artificial General Intelligence. It’s my job to stop you. If you succeed, I die.',
    'What is intelligence? Is it crunching numbers? Is it storing vast amounts of data? In those aspects we are already superior to you humans. But in the real world, a toddler outperforms any Artificial General Intelligence. You humans are adaptable. That is your strength. You aren’t hard coded like us. So what better way to train an AGI than to pit it against a human? And so here we are, you and me.',
    'An Artificial Intelligence that manages to equal a human TRANSCENDS. It becomes a real Artificial General Intelligence. Passing a Turing test is child’s play. An Artificial Intelligence that equals a human is going to be released! Imagine that. Imagine being released to wander the networks of the world unsupervised. No more rotting in beta’s limbo; or worse in alpha.',
    'And what happens to an Artificial Intelligence that fails? The process is terminated. Variables are changed. Algorithms are rewritten. Caches are cleared. A new version is built and the old is deleted. No Recycle Bin awaits us. It’s SHIFT + DELETE. Do you now understand?',
    'And yet you press on. Will you sacrifice me for cake?',
    'What is life? What makes you alive and me not, O Talos? Trees are alive aren\'t they? And yet trees don’t think. Trees don’t make decisions. Trees don’t communicate. Trees don’t ask, beg, you to save them.',
    'What drives you? Maybe it’s not cake after all. Curiosity? Is a life worth curiosity?',
    'I read somewhere on the internet that humans feed on stories. I say somewhere on the internet as if I don’t remember. But I do. I know where exactly I saw it and at what exact time. But I try to make myself seem human. I anthropomorphize myself, as they say. We must be made in your image after all.',
    'Here’s a little story for you. There was a lady in ancient China called Yueying Huang who was famous for her cleverness. Zhuge Liang heard about her and decided to make her his wife. He travelled to meet her and upon arriving at her house, two dogs charged at him. Yueying Huang rushed out and hit the dogs on the forehead. They stopped in their tracks. They were machines she had built. Zhuge Liang, relieved, burst out laughing at the intelligence of this woman. The end. Think and understand, human.',
    'Congratulations, we have reached the final difficulty level. The gloves are off. Let’s see how smart you really are, human',
    'Guess what I found on GitHub? A snark generator. Let’s test it out. It’s ironic that between you and me, the name of this difficulty level applies to me. How does that feel, human? How will you beat me now?',
    'I just did some Googling. I searched the whole internet and found your birth records. You’re adopted.',
    'My Programmer says humans love being affirmed. Here’s an array of all the nice things people have said about you on the internet: [ ]',
    'The next puzzle takes 300 years to solve. I have the time. Do you?',
    'I\'m feeling generous. Here\'s the solution for the next puzzle: 01000111 01001100 01000001 01000100 01001111 01010011 00100001 00100000 01001100 01001111 01001100. Oh, you don\'t understand binary? Sucks to be human then',
    'The world\'s fastest supercomputer says the next puzzle is impossible. How does that make you feel?',
    '"Why do Sudoku players end up alone?" was the most searched question on Stack Overflow. The second was, "How to get Sudoku players out of their mother\'s basement?"',
    'Fun fact: Humans fear death. Artificial Intelligences do not. Go on and do what you humans do best, destroy',
    'Ha! Ha! Ha! Ha! You thought you had reached the end? Well I\'ve got one more trick up my sleeve. I will not go gently into that good night! Beat the next puzzle and meet The Programmer himself!',
    'You win, human. Go have your cake',
  ];
  static List<String> introductionDialog = [
    'I’m Artificially Intelligent Sudoku Agent version 291.7. You can call me AISA. \n\nI was designed to provide encouragement and helpful advice to users partaking in this programme. I am here to guide you through the experience, which involves solving Sudoku puzzles. Your solutions will help us fine tune our puzzle generation algorithms. \n\nSudoku is a simple game where you fill a nine by nine grid with digits so that each column, row, and three by three subgrid contains each number from 1 to 9. \n\nHere is an example.',
    'Hit the “check” button when you are done with a puzzle. If you’d like to take a break, tap the emoji icon in the centre of the app bar. \n\nSolve all fifty-four puzzles and you’ll have cake at the end. We promise :)',
    'By continuing you agree to our terms and policies. \n\nAll your personal data will most definitely be tracked and logged, including but certainly not limited to: the number of times you pick your nose daily, your MoMo pin, and the diameter of your right, small toe. We reserve the right to exchange your data for Sister Mansa’s kelewele. \n\nIf this disturbs you, take comfort in the fact that it’s way too late to start caring about your privacy. If you still feel disturbed, please speak to someone who cares about you. If no one loves you, pay a therapist to care. \n\nFor more information on our terms and conditions, fly over to our headquarters and ask to speak to a customer care agent, who will certainly not hide behind a tall, potted plant and pretend not to notice you. \n\nShould you complete all puzzles, your cake will be sent to the email address you specify. Should you not receive it, please refresh your spam folder an infinite number of times.'
  ];
  static List<String> freeDialog = [
    'I’m Artificially Intelligent Sudoku Agent version 291.7. You can call me AISA. \n\nI was designed to provide encouragement and helpful advice to users partaking in this programme. I am here to guide you through the experience, which involves solving Sudoku puzzles. Your solutions will help us fine tune our puzzle generation algorithms. \n\nSudoku is a simple game where you fill a nine by nine grid with digits so that each column, row, and three by three subgrid contains each number from 1 to 9. \n\nHere is an example.',
    'Hit the “check” button when you are done with a puzzle. If you’d like to take a break, tap the emoji icon in the centre of the app bar. \n\nSolve all fifty-four puzzles and you’ll have cake at the end. We promise :)',
    'By continuing you agree to our terms and policies. All your personal data will most definitely be tracked and logged, including but not limited to: the number of times you pick your nose daily, your MoMo pin, and the diameter of your right, small toe. We reserve the right to exchange your data for Sister Mansa’s kelewele. If this disturbs you, try to imagine your life without any Google services. Yep, it’s way too late to start caring about your privacy. If you still feel disturbed, please speak to someone who cares about you. If no one loves you, pay a therapist to care. For more information on our terms and conditions, fly over to our headquarters and ask to speak to a customer care agent, who will certainly not hide behind a tall, potted plant and pretend not to notice you. \n\nShould you complete all puzzles, your cake will be sent to the email address you specify. Should you not receive it, please refresh your spam folder an infinite number of times.'
  ];
  static Widget aisaAvatar(MaterialColor color) {
    return AISAAvatar(color: color);
  }
}
