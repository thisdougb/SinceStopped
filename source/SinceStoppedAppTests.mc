/*
Tests: Command + Shift + P , Monkey C: Run Tests

Comment out the entire file when building a release. It seems to result in a smaller binary file,
even though the compiler is meant to exclude tests by default.

I commented the first test as documentation for anyone trying to figure out how to unit test. The
rest of the comments are for me, to remember what I'm testing in the data field.

In the app code I've used the proxy function getDisplayText() to be able to run tests, as it's 
simpler than wrestling with compute().
*/

import Toybox.Test;
import Toybox.Lang;
import Toybox.Activity;
import Toybox.Time;
import Toybox.System;

// Tests that remaining stationary does not increment the display text.
(:test)
function testAlwaysStationaryTimerOn(logger as Logger) as Boolean {
  
    // create a test class object to access the compute() proxy method
  var testView = new SinceStoppedView();

  // create test activity object we can pass into the compute() proxy function
  var testActivity = Activity.getActivityInfo();
  testActivity.currentSpeed = 0.0;
  testActivity.timerState = Activity.TIMER_STATE_ON;
  
  // the base time for the test
  var testTime = Time.now();
  var secondDuration = new Time.Duration(1);
  var response = "";

  // play 1 min of activity with no speed
  for (var i = 0; i < 60; i++) {

    response = testView.getDisplayText(testActivity, testTime);
    testTime = testTime.add(secondDuration); // incremement the time value

    if (!response.equals("00:00")) {
        logger.debug("inner loop response was [" + response + "]");
        return false;
    }
  }
  
  // if we didn't move the response should be 00:00
  response = testView.getDisplayText(testActivity, testTime);
  if (response.equals("00:00")) {
    return true;
  }

  logger.debug("response was [" + response + "]");
  return (false);
}

// Tests that continuous moving increments the display text.
(:test)
function testAlwaysMovingTimerOn(logger as Logger) as Boolean {
  
  var testView = new SinceStoppedView();
  var testActivity = Activity.getActivityInfo();
  testActivity.currentSpeed = 0.5;
  testActivity.timerState = Activity.TIMER_STATE_ON;
  
  var testTime = Time.now();
  var secondDuration = new Time.Duration(1);
  var response = "";

  for (var i = 0; i < 60; i++) {

    response = testView.getDisplayText(testActivity, testTime);
    testTime = testTime.add(secondDuration);

    if (!response.equals("00:00")) {
        logger.debug("inner loop response was [" + response + "]");
        return false;
    }
  }
  
  response = testView.getDisplayText(testActivity, testTime);
  
  if (response.equals("00:01")) {
    return true;
  }

  logger.debug("response was [" + response + "]");
  return (false);
}

// Tests that moving then stopping for 301 seconds resets display counter.
(:test)
function testMoveStopTimerOn(logger as Logger) as Boolean {
  
  var testView = new SinceStoppedView();
  var testActivity = Activity.getActivityInfo();
  testActivity.currentSpeed = 0.5;
  testActivity.timerState = Activity.TIMER_STATE_ON;
  
  var testTime = Time.now();
  var secondDuration = new Time.Duration(1);
  var response = "";

  // Move for two minutes then check display text
  for (var i = 0; i < 120; i++) {
    response = testView.getDisplayText(testActivity, testTime);
    testTime = testTime.add(secondDuration);
  }

  response = testView.getDisplayText(testActivity, testTime);
  if (!response.equals("00:02")) {
    logger.debug("after 2 mins moving response was [" + response + "]");
    return false;
  }

  // Stop for five minutes then check display text
  testActivity.currentSpeed = 0.0;
  for (var i = 0; i <= 300; i++) {
    response = testView.getDisplayText(testActivity, testTime);
    testTime = testTime.add(secondDuration);
  }
  
  response = testView.getDisplayText(testActivity, testTime);
  if (response.equals("00:00")) {
    return true;
  }

  logger.debug("response was [" + response + "]");
  return (false);
}

// Tests that moving, stopping for 301 seconds, then jittering for 59 seconds shows 00:00.
(:test)
function testMoveStopJitterTimerOn(logger as Logger) as Boolean {
  
  var testView = new SinceStoppedView();
  var testActivity = Activity.getActivityInfo();
  testActivity.currentSpeed = 0.5;
  testActivity.timerState = Activity.TIMER_STATE_ON;
  
  var testTime = Time.now();
  var secondDuration = new Time.Duration(1);
  var response = "";

  // Move for two minutes then check display text
  for (var i = 0; i < 120; i++) {
    response = testView.getDisplayText(testActivity, testTime);
    testTime = testTime.add(secondDuration);
  }

  response = testView.getDisplayText(testActivity, testTime);
  if (!response.equals("00:02")) {
    logger.debug("after 2 mins moving response was [" + response + "]");
    return false;
  }

  // Stop for five minutes then check display text
  testActivity.currentSpeed = 0.0;
  for (var i = 0; i <= 300; i++) {
    response = testView.getDisplayText(testActivity, testTime);
    testTime = testTime.add(secondDuration);
  }
  
  response = testView.getDisplayText(testActivity, testTime);
  if (!response.equals("00:00")) {
    logger.debug("after 5 mins moving response was [" + response + "]");
    return false;
  }

  // Jitter just below threshold
  var jitterThreshold = 20;
  testActivity.currentSpeed = 0.3;
  for (var i = 0; i < jitterThreshold; i++) {
    response = testView.getDisplayText(testActivity, testTime);
    testTime = testTime.add(secondDuration);
  }
  
  response = testView.getDisplayText(testActivity, testTime);
  if (response.equals("00:00")) {
    return true;
  }

  logger.debug("response was [" + response + "]");
  return (false);
}

// Tests that moving, stopping for 301 seconds, then moving for 1 min shows 00:01.
(:test)
function testMoveStopMoveTimerOn(logger as Logger) as Boolean {
  
  var testView = new SinceStoppedView();
  var testActivity = Activity.getActivityInfo();
  testActivity.currentSpeed = 0.5;
  testActivity.timerState = Activity.TIMER_STATE_ON;
  
  var testTime = Time.now();
  var secondDuration = new Time.Duration(1);
  var response = "";

  // Move for two minutes then check display text
  for (var i = 0; i < 120; i++) {
    response = testView.getDisplayText(testActivity, testTime);
    testTime = testTime.add(secondDuration);
  }

  response = testView.getDisplayText(testActivity, testTime);
  if (!response.equals("00:02")) {
    logger.debug("after 2 mins moving response was [" + response + "]");
    return false;
  }

  // Stop for five minutes then check display text
  testActivity.currentSpeed = 0.0;
  for (var i = 0; i <= 300; i++) {
    response = testView.getDisplayText(testActivity, testTime);
    testTime = testTime.add(secondDuration);
  }
  
  response = testView.getDisplayText(testActivity, testTime);
  if (!response.equals("00:00")) {
    logger.debug("after 5 mins moving response was [" + response + "]");
    return false;
  }

  // Move again for 2 min + jitterThreshold
  testActivity.currentSpeed = 0.3;
  for (var i = 0; i < 140; i++) {
    response = testView.getDisplayText(testActivity, testTime);
    testTime = testTime.add(secondDuration);
  }
  
  response = testView.getDisplayText(testActivity, testTime);
  if (response.equals("00:02")) {
    return true;
  }

  logger.debug("response was [" + response + "]");
  return (false); // returning true indicates pass, false indicates failure
}

// Tests that moving, stopping and pausing the timer doesn't cause new readings.
(:test)
function testMoveStopTimerPause(logger as Logger) as Boolean {
  
  var testView = new SinceStoppedView();
  var testActivity = Activity.getActivityInfo();
  testActivity.currentSpeed = 0.5;
  testActivity.timerState = Activity.TIMER_STATE_ON;
  
  var testTime = Time.now();
  var secondDuration = new Time.Duration(1);
  var response = "";

  // Move for two minutes then check display text
  for (var i = 0; i < 120; i++) {
    response = testView.getDisplayText(testActivity, testTime);
    testTime = testTime.add(secondDuration);
  }

  response = testView.getDisplayText(testActivity, testTime);
  if (!response.equals("00:02")) {
    logger.debug("after 2 mins moving response was [" + response + "]");
    return false;
  }

  // Pause and stop for five minutes then check display text
  testActivity.timerState = Activity.TIMER_STATE_PAUSED;
  testActivity.currentSpeed = 0.0;
  for (var i = 0; i <= 300; i++) {
    response = testView.getDisplayText(testActivity, testTime);
    testTime = testTime.add(secondDuration);
  }
  
  response = testView.getDisplayText(testActivity, testTime);
  if (!response.equals("00:00")) {
    logger.debug("after 5 mins moving response was [" + response + "]");
    return false;
  }

  // Move again for 2 min while paused
  testActivity.currentSpeed = 0.3;
  for (var i = 0; i < 180; i++) {
    response = testView.getDisplayText(testActivity, testTime);
    testTime = testTime.add(secondDuration);
  }
  
  response = testView.getDisplayText(testActivity, testTime);
  if (response.equals("00:00")) {
    return true;
  }

  logger.debug("response was [" + response + "]");
  return (false);
}

// Tests that the counter doesn't start reading until we have started the device timer
(:test)
function testTimerOffOnMove(logger as Logger) as Boolean {
  
  var testView = new SinceStoppedView();
  var testActivity = Activity.getActivityInfo();
  testActivity.currentSpeed = 0.5;
  testActivity.timerState = Activity.TIMER_STATE_OFF;
  
  var testTime = Time.now();
  var secondDuration = new Time.Duration(1);
  var response = "";

  // Generate 5 mins of speed readings, with timer off
  for (var i = 0; i < 300; i++) {
    response = testView.getDisplayText(testActivity, testTime);
    testTime = testTime.add(secondDuration);
  }

  response = testView.getDisplayText(testActivity, testTime);
  if (!response.equals("00:00")) {
    logger.debug("after 5 mins moving response was [" + response + "]");
    return false;
  }
  
  // Timer on and do 2 mins of speed readings, counter should show 2 mins not 7 mins
  testActivity.timerState = Activity.TIMER_STATE_ON;
  testActivity.currentSpeed = 0.5;
  for (var i = 0; i < 120; i++) {
    response = testView.getDisplayText(testActivity, testTime);
    testTime = testTime.add(secondDuration);
  }
  
  response = testView.getDisplayText(testActivity, testTime);
  if (response.equals("00:02")) {
    return true;
  }

  logger.debug("response was [" + response + "]");
  return (false);
}

// Tests that the app doesn't crash if paused while threshold is reached
(:test)
function testMovePauseOverThreshold(logger as Logger) as Boolean {
  
  var testView = new SinceStoppedView();
  var testActivity = Activity.getActivityInfo();
    
  var testTime = Time.now();
  var secondDuration = new Time.Duration(1);
  var response = "";

  // Generate 5 mins of speed readings
  testActivity.currentSpeed = 0.5;
  testActivity.timerState = Activity.TIMER_STATE_ON;
  for (var i = 0; i < 300; i++) {
    response = testView.getDisplayText(testActivity, testTime);
    testTime = testTime.add(secondDuration);
  }

  response = testView.getDisplayText(testActivity, testTime);
  if (!response.equals("00:05")) {
    logger.debug("after 5 mins moving response was [" + response + "]");
    return false;
  }
  
  testActivity.timerState = Activity.TIMER_STATE_OFF;
  testActivity.currentSpeed = 0.3;
  testTime = testTime.add(secondDuration);
  testTime = testTime.add(secondDuration);
  response = testView.getDisplayText(testActivity, testTime);
  System.println("response " + response);

  // Timer paused and do 5 mins of no-speed readings
  testActivity.timerState = Activity.TIMER_STATE_PAUSED;
  testActivity.currentSpeed = 0.0;
  for (var i = 0; i < 301; i++) {
    response = testView.getDisplayText(testActivity, testTime);
    testTime = testTime.add(secondDuration);
  }
  
  response = testView.getDisplayText(testActivity, testTime);
  if (response.equals("00:00")) {
    return true;
  }

  logger.debug("response was [" + response + "]");
  return (false);
}
