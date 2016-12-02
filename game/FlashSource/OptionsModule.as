package  {

	import flash.display.MovieClip;
	import flash.net.Socket;
    import flash.utils.ByteArray;
    import flash.events.Event;
    import flash.events.ProgressEvent;
    import flash.events.IOErrorEvent;
    import flash.utils.Timer;
    import flash.events.TimerEvent;

    public class OptionsModule extends MovieClip {
        // Dota stuff
        public var gameAPI:Object;
        public var globals:Object;
        public var elementName:String;

        // Our socket to connect with
		private var sock:Socket;

        // The message to write
        private var ourMessage:String;

        // The data we get sent
        private var resData;

        // The max time to wait for the server to respond (in ms)
        private var MAX_WAIT:Number = 3 * 1000;

        // Server info
		private var SERVER_ADDRESS:String = "176.31.182.87";
		private var SERVER_PORT:Number = 4444;
        private var SERVER_PATH:String = '/something.php';
        private var SERVER_HOST:String = 'getdotastats.net';

        // The timer to do handle timeouts
        private var timeoutTimer:Timer;

        // Have we finished with our reporting?
        private var doneReporting:Boolean = false;

        // String to prefix onto every message we print
        private static var debugPrefix:String = 'GDS: ';

        // String to replace double quotes with
        private static var quoteReplacer:String = '&qt!';

        public function onLoaded() : void {
            // Tell the user what is going on
            trace(debugPrefix + 'Loading options module...');

            // Load KV
            var settings = globals.GameInterface.LoadKVFile('scripts/stat_collection.kv');

            // Load the live setting
            var live:Boolean = (settings.live == "1");

            // Load the settings for the given mode
            if(live) {
                // Load live settings
                SERVER_ADDRESS = settings.OPTION_ADDRESS_LIVE;
                SERVER_PORT = parseInt(settings.OPTION_PORT_LIVE);
                SERVER_HOST = settings.OPTION_HOST_LIVE;
                SERVER_PATH = settings.OPTION_PATH_LIVE;

                // Tell the user it's live mode
                trace(debugPrefix + 'Options module is set to LIVE mode.');
            } else {
                // Load live settings
                SERVER_ADDRESS = settings.OPTION_ADDRESS_TEST;
                SERVER_PORT = parseInt(settings.OPTION_PORT_TEST);
                SERVER_HOST = settings.OPTION_HOST_TEST;
                SERVER_PATH = settings.OPTION_PATH_TEST;

                // Tell the user it's test mode
                trace(debugPrefix + 'Options module is set to TEST mode.');
            }

            // Log the server
            trace(debugPrefix + 'Server was set to ' + SERVER_ADDRESS + ":" + SERVER_PORT + ', will request: ' + SERVER_HOST+SERVER_PATH);

            // Hook the stat collection event
            gameAPI.SubscribeToGameEvent("gds_options", doOptionsStuff);

            // Wait a second then offer to pull the options
            var timer:Timer = new Timer(1000, 1);
            timer.addEventListener(TimerEvent.TIMER, requestOptions, false, 0, true);
            timer.start();

            // Done loading <3
            trace(debugPrefix + 'Options module was loaded.');
        }

        // Fired when we connect successfully
		private function socketConnect(e:Event) {
			// We have connected successfully!
            trace(debugPrefix + 'Connected to the server!');

            // Hook the data connection
			var buff:ByteArray = new ByteArray();
			writeString(buff, ourMessage);
			sock.writeBytes(buff, 0, buff.length);
            sock.flush();
		}

        // Fired when we get data from the server
        private function socketData(e:ProgressEvent) {
            // Store the data
            resData += sock.readUTFBytes(sock.bytesAvailable);
        }

        // Fired when the socket times out
        private function socketClose(e:Event) {
            // Debug info
            trace(debugPrefix + 'Socket was closed.');

            // Report it
            doTimeout();
        }

        // Fired when we have been waiting too long
        private function doTimeout() {
            // Reset the timer
            if(timeoutTimer != null) {
                timeoutTimer.stop();
                timeoutTimer = null;
            }

            // Ensure we only report once
            if(doneReporting) return;
            doneReporting = true;

            // Log what we got
            trace(debugPrefix + 'Full message: ' + resData);

            // Report it
            if(resData == '') {
                // Report the failure
                reportFailure('We timed out!');
            } else {
                var split:Array = resData.split('\r\n\r\n');
                if(split.length >= 2) {
                    // Grab the data
                    var data:String = split[1];

                    // Trace the stripped message
                    trace(debugPrefix + 'Stripped message: ' + data);

                    // Succes, report it
                    reportSuccess(data);
                    return;
                }

                // Report failure
                reportFailure('Error decoding request!');
            }
        }

        // Used to write messages
		private static function writeString(buff:ByteArray, write:String){
			trace("Message: "+write);
			trace("Length: "+write.length);
            buff.writeUTFBytes(write);
        }

        // This function tells the server we are happy to send options
        private function requestOptions():void {
            // Tell the server we failed, with an error message
            gameAPI.SendServerCommand('gds_request_options');
        }

        // This function tells the server we failed to get options from the master server
        private function reportFailure(msg:String):void {
            // Tell the server we failed, with an error message
            gameAPI.SendServerCommand('gds_failure "' + msg.split('"').join(quoteReplacer) + '"');
        }

        // This function tells the server we failed to get options from the master server
        private function reportSuccess(msg:String):void {
            // Replace quotes
            msg = msg.split('"').join(quoteReplacer);

            var msgPrt = 200;

            for(var i=0; i<msg.length; i+=msgPrt) {
                // Tell the server we failed, with an error message
                gameAPI.SendServerCommand('gds_send_part "' + msg.substr(i, msgPrt) + '"');
            }

            // Tell the server we failed, with an error message
            gameAPI.SendServerCommand('gds_send_options');
        }

        // The server has asked us to request options from the master server
		private function doOptionsStuff(args:Object):void {
            // Grab our playerID
            var playerID:Number = globals.Players.GetLocalPlayer();

            // Info trace
            trace(debugPrefix+'Server has asked for options from ' + args.playerID + ' (we are ' + playerID + ')');

            // Ensure it was us
            if(args.playerID == -1) return;
            if(playerID != args.playerID) return;

            // Tell the player
            trace(debugPrefix + 'Server wants us to get the options!');

            // Create failure timeout
            timeoutTimer = new Timer(MAX_WAIT, 1);
            timeoutTimer.addEventListener(TimerEvent.TIMER, doTimeout, false, 0, true);
            timeoutTimer.start();

            // Reset our options response
            resData = '';

            // Grab the command
            var command:String = args.command;

            // Build the message
            ourMessage = 'GET ' + SERVER_PATH + command + ' HTTP/1.1\r\n' +
               'Host: ' + SERVER_HOST + '\r\n' +
               "Connection: close\r\n\r\n";

            // Tell the client
			trace(debugPrefix + 'Sending command to the server: ' + SERVER_HOST + SERVER_PATH + command);

            // Create the socket
			sock = new Socket();
			sock.timeout = 10000; //10 seconds is fair..

			// Setup socket event handlers
			sock.addEventListener(Event.CONNECT, socketConnect);
            sock.addEventListener(ProgressEvent.SOCKET_DATA, socketData);
            sock.addEventListener(Event.CLOSE, socketClose);

            // Attempt to connect
			try {
				// Connect
				sock.connect(SERVER_ADDRESS, SERVER_PORT);
			} catch (e:Error) {
				// Oh shit, there was an error
				trace(debugPrefix + 'Failed to connect to the master server.');

                // Report a failure to the server
                reportFailure(e.message);
			}
		}
    }
}
