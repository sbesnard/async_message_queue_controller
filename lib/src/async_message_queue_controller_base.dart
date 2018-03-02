import 'dart:async';
import 'dart:collection';

typedef OUT AsyncMessageQueueCallback<IN,OUT>(IN);

class AsyncMessageQueueController<Tinput,Toutput>{
  StreamController<Tinput> _controllerIn;
  StreamController<Toutput> _controllerOut;
  bool _isProcessing = false;
  bool _isRunning = false;
  Queue<Tinput> _queue = new Queue<Tinput>();
  AsyncMessageQueueCallback<Tinput,Future<Toutput>> _processor;

  /// Initializes the controller with the callback passed as parameter
  AsyncMessageQueueController(this._processor);


  /// Stops the controller, clears the streams and the queue.
  void stop() {
    _queue.clear();

    if (_controllerIn != null ){
      _controllerIn.close();
      _controllerIn = null;
    }
    if (_controllerOut != null ){
      _controllerOut.close();
      _controllerOut = null;
    }
    _isRunning = false;
    _isProcessing = false;


  }

  /// Starts waiting for messages to be added to the queue
  Stream<Toutput> start() {

    _controllerIn = new StreamController<Tinput>();
    _controllerOut= new StreamController<Toutput>();

    _isRunning = true;
    _isProcessing = false;

    _controllerIn.stream.listen(onData);
    return _controllerOut.stream;


  }

  /// asynchronous loop where the callback is called.
  /// This function is called when a new message is added to the queue.
  /// If a loop is already running (_isProcessing == true) then return
  /// without further treatment.
  onData(Tinput msg) async {
    if (!_isProcessing){
      _isProcessing = true;

      // treat sequentially the messages in the queue
      // until the queue is empty or the service is stopped
      while(_queue.isNotEmpty && _isRunning) {
        Tinput data = _queue.removeFirst();

        _controllerOut.add(await _processor(data));
      }
      _isProcessing =  false;
    }

  }

  /// Adds a message to the message queue
  /// The message will only be kept and processed if the controller is running
  void queueMessage(Tinput msg){
    if (_isRunning) {
      _queue.add(msg);
      _controllerIn.add(msg);
    }
  }

}
