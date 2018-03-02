import 'package:async_message_queue_controller/async_message_queue_controller.dart';
import 'package:test/test.dart';
import "dart:async";


Future<Map<String,String>> process(String msg){
  return new Future.delayed(const Duration(seconds: 1), () => {'OK':' Processed msg : $msg'});
}

void main() async {
  group('Two Strings should return', () {


    var mqc = new AsyncMessageQueueController<String,Map<String,String>>(process);


    test('First Test', () async {
      int counter = 0;

      Stream<Map<String, String>> s = mqc.start();
      mqc.queueMessage('Hello');
      mqc.queueMessage('World');

      new Timer(new Duration(seconds: 3), ()=> mqc.queueMessage('stop') );
      new Timer(new Duration(seconds: 4), ()=> mqc.queueMessage('will not be processed') );
      await for (var value in s) {
        if (value['OK'] == ' Processed msg : stop') break;
        print('***${value['OK']}');
        counter++;
      }

      mqc.stop();

      expect(counter==2, isTrue);

    });
  });
}
