import Toybox.Test;
import Toybox.Lang;
import Toybox.Activity;
import Toybox.Time;
import Toybox.System;

// Tests exact zero speed behavior
(:test)
function testExactZeroSpeed(logger as Logger) as Boolean {
    var view = new SinceStoppedView();
    var activity = Activity.getActivityInfo();
    activity.currentSpeed = 0.0;
    activity.timerState = Activity.TIMER_STATE_ON;
    
    var time = Time.now();
    var result = view.getDisplayText(activity, time);
    
    return result.equals("00:00");
}

// Tests high speed behavior
(:test) 
function testHighSpeed(logger as Logger) as Boolean {
    var view = new SinceStoppedView();
    var activity = Activity.getActivityInfo();
    activity.currentSpeed = 100.0; // Very high speed
    activity.timerState = Activity.TIMER_STATE_ON;
    
    var time = Time.now();
    var second = new Time.Duration(1);
    
    for(var i = 0; i < 180; i++) {
        view.getDisplayText(activity, time);
        time = time.add(second);
    }
    
    var result = view.getDisplayText(activity, time);
    return result.equals("00:03"); // Should show 3 mins
}

// Tests hour rollover
(:test)
function testHourRollover(logger as Logger) as Boolean {
    var view = new SinceStoppedView();
    var activity = Activity.getActivityInfo();
    activity.currentSpeed = 5.0;
    activity.timerState = Activity.TIMER_STATE_ON;
    
    var time = Time.now();
    var second = new Time.Duration(1);
    
    // Simulate 65 minutes of movement
    for(var i = 0; i < 3900; i++) {
        view.getDisplayText(activity, time);
        time = time.add(second);
    }
    
    var result = view.getDisplayText(activity, time);
    return result.equals("01:05"); // Should show 1 hour 5 mins
}

// Tests jitter threshold boundary
(:test)
function testJitterThresholdExact(logger as Logger) as Boolean {
    var view = new SinceStoppedView();
    var activity = Activity.getActivityInfo();
    activity.timerState = Activity.TIMER_STATE_ON;
    
    var time = Time.now();
    var second = new Time.Duration(1);
    
    // Generate exactly threshold number of zero readings
    activity.currentSpeed = 0.0;
    for(var i = 0; i < 20; i++) {
        view.getDisplayText(activity, time);
        time = time.add(second);
    }
    
    // Then one moving reading
    activity.currentSpeed = 1.0;
    var result = view.getDisplayText(activity, time);
    
    return result.equals("00:00"); // Should still show zero due to jitter
}

// Tests exact stopped threshold
(:test)
function testStoppedThresholdExact(logger as Logger) as Boolean {
    var view = new SinceStoppedView();
    var activity = Activity.getActivityInfo();
    activity.timerState = Activity.TIMER_STATE_ON;
    
    var time = Time.now();
    var second = new Time.Duration(1);
    
    // Move for 1 minute
    activity.currentSpeed = 5.0;
    for(var i = 0; i < 60; i++) {
        view.getDisplayText(activity, time);
        time = time.add(second);
    }
    
    // Stop for exactly 5 minutes
    activity.currentSpeed = 0.0;
    for(var i = 0; i < 300; i++) {
        view.getDisplayText(activity, time);
        time = time.add(second);
    }
    
    var result = view.getDisplayText(activity, time);
    return result.equals("00:00"); // Should reset to zero
}

// Tests jitter recovery
(:test)
function testJitterRecovery(logger as Logger) as Boolean {
    var view = new SinceStoppedView();
    var activity = Activity.getActivityInfo();
    activity.timerState = Activity.TIMER_STATE_ON;
    
    var time = Time.now();
    var second = new Time.Duration(1);
    
    // Generate some jittery readings
    for(var i = 0; i < 30; i++) {
        activity.currentSpeed = (i % 2) == 0 ? 0.1 : 0.0;
        view.getDisplayText(activity, time);
        time = time.add(second);
    }
    
    // Then steady movement
    activity.currentSpeed = 5.0;
    for(var i = 0; i < 60; i++) {
        view.getDisplayText(activity, time);
        time = time.add(second);
    }
    
    var result = view.getDisplayText(activity, time);
    return result.equals("00:01"); // Should show 1 min after recovery
}