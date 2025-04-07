
import Toybox.Test;
import Toybox.Lang;
import Toybox.Activity;
import Toybox.Time;

// Tests that remaining stationary does not increment the display text.
(:test)
function testAlwaysStationary(logger as Logger) as Boolean {
  
    // create a test class object to access the compute() method
  var testView = new SinceStoppedView();

  // create test activity object we can pass into compute()
  var testActivity = Activity.getActivityInfo();
  testActivity.currentSpeed = 0.0;
  
  // the base time for the test
  var testTime = Time.now();
  var secondDuration = new Time.Duration(1);
  var response = "";

  // 1 min of stationary
  for (var i = 0; i < 60; i++) {

    response = testView.getDisplayText(testActivity, testTime);
    testTime = testTime.add(secondDuration);

    if (!response.equals("00:00")) {
        logger.debug("inner loop response was [" + response + "]");
        return false;
    }
  }
  
  response = testView.getDisplayText(testActivity, testTime);
  
  if (response.equals("00:00")) {
    return true;
  }

  logger.debug("response was [" + response + "]");
  return (false); // returning true indicates pass, false indicates failure
}

// Tests that continuous moving increments the display text.
(:test)
function testAlwaysMoving(logger as Logger) as Boolean {
  
  var testView = new SinceStoppedView();
  var testActivity = Activity.getActivityInfo();
  testActivity.currentSpeed = 0.5;
  
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
  return (false); // returning true indicates pass, false indicates failure
}

// Tests that moving then stopping for 301 seconds resets display counter.
(:test)
function testMoveStop(logger as Logger) as Boolean {
  
  var testView = new SinceStoppedView();
  var testActivity = Activity.getActivityInfo();
  testActivity.currentSpeed = 0.5;
  
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
  return (false); // returning true indicates pass, false indicates failure
}

// Tests that moving, stopping for 301 seconds, then jittering for 59 seconds shows 00:00.
(:test)
function testMoveStopJitter(logger as Logger) as Boolean {
  
  var testView = new SinceStoppedView();
  var testActivity = Activity.getActivityInfo();
  testActivity.currentSpeed = 0.5;
  
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

  // Jitter just below threshold of 60.
  testActivity.currentSpeed = 0.3;
  for (var i = 0; i < 60; i++) {
    response = testView.getDisplayText(testActivity, testTime);
    testTime = testTime.add(secondDuration);
  }
  
  response = testView.getDisplayText(testActivity, testTime);
  if (response.equals("00:00")) {
    return true;
  }

  logger.debug("response was [" + response + "]");
  return (false); // returning true indicates pass, false indicates failure
}

// Tests that moving, stopping for 301 seconds, then moving for 1 min shows 00:01.
(:test)
function testMoveStopMove(logger as Logger) as Boolean {
  
  var testView = new SinceStoppedView();
  var testActivity = Activity.getActivityInfo();
  testActivity.currentSpeed = 0.5;
  
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
