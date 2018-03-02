# AsyncMessageQueueProcessor

A simple controller that processes a message payload queue asynchronously.

Useful when needing to process asynchronously a series of messages with predefined payload type,
and those processes should be sequential.

For instance, manage several file uploads in a Flutter app, and be able to suspend the queue
when the connectivity is lost.

## Usage

A simple usage example:

```
import 'package:async_message_queue_controller/async_message_queue_controller.dart';
import "dart:async";

/// The callback used by the controller to "process" a message/payload
/// Here the payload is a simple string, an simulates a heavy process
/// lasting 1 second.

Future<Map<String,String>> process(String msg){
  return new Future.delayed(const Duration(seconds: 1), () => {'OK':' Processed msg : $msg'});
}


void main() async {

  var mqc = new AsyncMessageQueueController<String, Map<String,String>>(process);


  Stream<Map<String, String>> s = mqc.start();

  mqc.queueMessage('Hello'); // will appear after 1 sec
  mqc.queueMessage('World'); // will appear after 2 sec

  // stop the process after 3 seconds
  new Timer(new Duration(seconds: 3), ()=> mqc.queueMessage('stop') );

  // this will not be processed
  new Timer(new Duration(seconds: 4), ()=> mqc.queueMessage('will not be processed') );

  // Loop waiting for processed values
  await for (var value in s) {
    if (value['OK'] == ' Processed msg : stop') break; // stop our loop if 'stop' is sent
    print(value['OK']); // Otherwise print the value

  }

}
```


