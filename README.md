## Since Stopped

#### Garmin Docs

[Build my first app](https://developer.garmin.com/connect-iq/connect-iq-basics/your-first-app/)

#### My Developer ID

https://apps.garmin.com/developer/cc7db9c9-7700-4ee2-a83a-74925bf4aad6/apps

### Device Reference

This gives the dimensions of field layouts. Useful for troubleshooting.

https://developer.garmin.com/connect-iq/reference-guides/devices-reference/#edge®840840solar

#### SDK

API Reference :https://developer.garmin.com/connect-iq/api-docs/

Get the latest SDK: [here](https://developer.garmin.com/connect-iq/sdk/)

Get the url of the download and use curl (it doesn't download via a browser):

```
$ curl https://developer.garmin.com/downloads/connect-iq/sdk-manager/connectiq-sdk-manager.dmg --output ./Downloads/connectiq-sdk-manager.dmg
```

Then open the .dmg and install, and select to set it as the current SDK.

```
$ pwd
/Users/dougb/Library/Application Support/Garmin/ConnectIQ/Sdks
$ ls -l
total 0
drwxr-xr-x   6 dougb  staff  192  3 Apr  2021 connectiq-sdk-mac-3.1.8-2020-05-01-5a72d0ab2
drwxr-xr-x   6 dougb  staff  192  3 Apr  2021 connectiq-sdk-mac-3.1.9-2020-06-24-1cc9d3a70
drwxr-xr-x   6 dougb  staff  192  3 Apr  2021 connectiq-sdk-mac-3.2.1-2020-08-20-56ff593b7
drwxr-xr-x   6 dougb  staff  192  3 Apr  2021 connectiq-sdk-mac-3.2.2-2020-08-28-a50584d55
drwxr-xr-x   6 dougb  staff  192  3 Apr  2021 connectiq-sdk-mac-3.2.3-2020-10-13-c14e609bd
drwxr-xr-x  13 dougb  staff  416  3 Aug  2022 connectiq-sdk-mac-4.1.4-2022-06-07-f86da2dee
drwxr-xr-x@ 13 dougb  staff  416 12 Apr 09:26 connectiq-sdk-mac-4.2.4-2023-04-05-5830cc591
```

Next go to the Devices tab, and ensure new devices are downloaded.

Also use:

Command + Shift + P , _Monkey C: Open SDK Manager_

#### Add Supported Devices

Now add new devices to the app manifest, using the UI:

Command + Shift + P , _Monkey C: Edit Products_

#### Run Tests

Command + Shift + P , _Monkey C: Run Tests_

#### Run In Simulator

Menu: Run > Run Without Debugging

#### Side Loading

Side loading the app binary onto device lets you test it.

Command + Shift + P , _Monkey C: Build for Device_

Then copy the .prg file onto the device /Garmin/Apps.

#### Build For Submission

Command + Shift + P , _Monkey C: Export Project_

Build into /Users/dougb/dev/SinceStopped/exports/

```
(py3.9) dougb $ ls -l exports 
total 520
-rw-r--r--  1 dougb  staff  261838 12 Apr 09:56 SinceStopped.iq
```

#### Upload Submission

[Developer Dashboard](https://apps.garmin.com/en-US/apps/f1cbfe29-f1a0-40c8-a16a-aff5236a6bfa)

Uploads the .iq file, and allos (in the UI) to set the app version number.