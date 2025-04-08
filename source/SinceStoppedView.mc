import Toybox.Activity;
import Toybox.Lang;
import Toybox.Time;
import Toybox.WatchUi;

class SinceStoppedView extends WatchUi.SimpleDataField {
    
    private var _currentMovingStartedTime as Time.Moment;
    private var _lastMovingTime as Time.Moment;
    private var _stoppedThreshold as Time.Duration;
    private var _jitterDetector as Lang.Number;
    private var _jitterThreshold as Lang.Number;
    
    function initialize() {
        
        SimpleDataField.initialize();
        label = WatchUi.loadResource(Rez.Strings.LabelTitle) as Lang.String;

        // we must initialise some values
        self._currentMovingStartedTime = Time.now();
        self._lastMovingTime = self._currentMovingStartedTime;

        // jittery speed readings are when the device thinks it's moving because of GPS drift.
        // Observations show fake speed readings may happen in bursts of two or three at a time, 
        // then fall back to zero. So we take _jitterThreshold consecutive speed readings as a sign 
        // that we are geniunely moving.
        self._jitterDetector = 0;
        self._jitterThreshold = 20;

        // the threshold is 5 minutes, after which we are considered stopped and the counter
        // resets.
        self._stoppedThreshold = new Time.Duration(5 * 60);
    }

    function compute(info as Activity.Info) as Numeric or Duration or String or Null {
        return getDisplayText(info, Time.now());
    }

    function getDisplayText(info as Activity.Info, timeNow as Time.Moment) as String {

        // timer is off, so re-init moving start time, but return not-started text.
        // I'm not 100% sure when the data field is initialised, so this may be redundant.
        if (info.timerState == 0) {
            self._currentMovingStartedTime = timeNow;
            return "00:00";
        }

        // jitter detector: 0 <= _jitterDetector < _jitterThreshold
        //
        // if _jitterDetector > 0 then we are experiencing jittery speed readings. The counter
        // maxes out at _jitterThreshold, so worst case we have to read that many consecutive
        // seconds of speed values for the timing counter to start. However, the lastMovingTime
        // is set from the last stationary reading. So the timing moving is not _jitterThreshold
        // in deficit.

        var currentSpeed = info.currentSpeed as Lang.Float;
        
        // if we are moving and not paused then decremment the jitter count        
        if (currentSpeed > 0) {
            if (self._jitterDetector > 0) {
                self._jitterDetector--;
                //System.println("jitter decremented to " + self._jitterDetector + "  speed " +info.currentSpeed);
            }
        } else {
            // we are not moving so incremement the jitter count up to max 10
            if (self._jitterDetector < self._jitterThreshold) {
                self._jitterDetector++;
                //System.println("jitter incremented to " + self._jitterDetector);
            }
        }
        
        // if there speed, no jitter, and timer is active, then we are moving.
        // this means we do not update _lastMovingTime if device timer paused/stopped.
        if (currentSpeed > 0 && self._jitterDetector == 0 && info.timerState == 3) {
            // update _lastMovingTime if we are currently moving.
            //System.println("compute(): currently moving at speed " + info.currentSpeed);
			self._lastMovingTime = timeNow;
		} else {
            // we are not moving or device timer is paused
            var durationSinceLastMovement = timeNow.subtract(self._lastMovingTime).value();
            //System.println("compute(): currently stopped for " + durationSinceLastMovement);

            // if we are over the non-moving threshold (ie stopped at a cafe), then cause the
            // data field to reset
            if (durationSinceLastMovement > self._stoppedThreshold.value()) {
                //System.println("compute(): stopped beyond threshold " + durationSinceLastMovement);

                // setting _currentMovingStartedTime to now means it is correct when we do start 
                // moving again.
                self._currentMovingStartedTime = timeNow;

                return "00:00";
            }

            // fall-through is that we have stopped moving and/or the device timer has paused, but
            // we are within the 5 min threshold. We may have stopped to check a map, or at a
            // traffic light.
        } 

        // at this point the _lastMovingTime is either now (we are moving), or it is the same as
        // _currentMovingStartedTime because we didn't move at all yet.
		var sinceStoppedDuration = self._lastMovingTime.subtract(self._currentMovingStartedTime);
        //System.println("compute(): calculated sinceStoppedDuration: " + sinceStoppedDuration.value());

        if (sinceStoppedDuration.value() == 0) {
            return "00:00";
        }

		var totalMinutes = Math.floor(sinceStoppedDuration.value() / 60);
		var hours = Math.floor(totalMinutes / 60);
		var minutes = Math.floor(totalMinutes.toNumber() % 60);

        //System.println("compute(): update display text: " + Lang.format("$1$:$2$", [hours.format("%02d"), minutes.format("%02d")]));

		return Lang.format("$1$:$2$", [hours.format("%02d"), minutes.format("%02d")]);
    }
}

