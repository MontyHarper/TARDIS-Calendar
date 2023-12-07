# Udacity Feedback Response 2.0
Hello, I had two things to fix from the last feedback, and I believe I've got them...
1. App should hide the activity indicator when it's not being used: In contentView the showProgressView Bool determines whether the indicator is showing. That bool is set to true in SolarEventManager.init, then set to false once events are updated or fetched from memory, or fail to be fetched. I added a completion closure to my fetchBackup() function in SolarEventManager. That way all the state logic is encapsulated within updateSolarDaysCompletion(success:). I should only need to set showProgressView to false once there to cover all cases. If it's still misbehaving please let me know under what circumstances.
2. Impossible to ask permission to use calendar for newer versions of iOS: I have included the new code for this at line 39 in the EventManager. I attempted to use conditional compilation so the app will build for me and for you.

 
# Udacity Feedback Response 1.0
Hello, my reviewer was unable to work the app and asked for a more detailed readme. Other than the information they asked for, all details about installing and running the app are listed below.
Here is the information that was specifically requested:
- XCode version: 14.0.1 (Sorry, I know it's not the latest, but my computer is too old to run the latest macOS, so I am updated on XCode as far as I can go.)
- Swift Version: Swift 5.7 (5.7.0.127.4) 
- iOS version: minimum deployments is set for iOS 16.0

If the project does not pass again, please verify that this response was received.
Also please let me know more about what you see when launching the app:
- Does it ask for permission to track location?
- Does it ask for permission to access Calendar?
- Does it show a welcome message?
- Does it list calendars from your Calendar app? (Apple's Calendar App must be installed on the device.)
- If a list of calendars does not appear, what happens if you triple-tap the upper right-hand corner?
- Do vertical bands of dark and light color appear in the background when you swipe to the left across the screen?


# Table of Contents
- You Decide! Udacity Assignment Requirements Met: details how each requirement was met
- TARDIS Calendar: explains the purpose of the app, along with a list of major features
- Setup: explains how to install the app and how to set it up for daily use
- Planned Improvements: my to-do list for adding features and improving code


# You Decide! Udacity Assignment Requirements Met
ReadMe
- Describes user experience: see below
- Installation information: see below
  
User Interface
- Multiple pages: Two main views are available, a settings page and a calendar page. The calendar page is the main view. It reveals significant new information when the user taps an event or drags a finger left or right to zoom the timeline in and out.
- Multiple controls: On the settings page, the user can select calendars with a toggle and assign a type to each calendar with a picker. A custom gesture is used to zoom the calendar page in and out.
  
Networking
- Data from a networked source: The app displays sunrise and sunset information as colors in the background. This information is fetched from https://sunrisesunset.io/api/
- Networking code is encapsulated: The SolarEventManager class downloads sunrise and sunset information.
- Indicates network activity where appropriate: When the app launches, a progress view appears briefly while solar event information is fetched in order to construct a background view. If the user changes location, new data will be fetched, but since the background view is not disturbed by this, the activity is not indicated onscreen.
- Alert for failed network connection: If internet is down, a message appears onscreen. Tapping the message displays information about how long the connection has been down and what that means for the calendar data.
  
Persistent State
- Persistent state stored using CoreData: The app stores solar event information using CoreData. If solar data is unavailable online, the app uses stored data to construct a background instead. (After a few days of this a warning will appear to let the user know their sunrise and sunset information may be a bit off.)
  
App Functionality
- The app functions as described with no crashes: I believe this to be true! There are a couple of features described below that are still forthcoming, and those are identified as not yet available. But basically everything is working and the app can be useful in its present state.

# TARDIS Calendar
This is an experimental "dementia" calendar for iOS, currently in development.

Throughout this readme I will refer to:
- **The User** - this is the end user of the app, i.e. the person with dementia who may benefit from a calendar that displays events in relation to "now". It is assumed that the user knows nothing about computers or apps.
- **The Caregiver** - this is the user's family member or other caregiver. They will be responsible for setting up the app and populating it with events using Apple's Calendar App.  

## TARDIS Calendar Concept
- I've designed this calendar for my mom, who has temporal lobe epilepsy, and often cannot conceptualize time very well.
- Other "dementia clocks" or calendars all seem to work on the same principal, which is to present lots of information on a big screen about what time it is now.
- What my mom really needs is a way of anchoring herself in relation to future events.
- The TARDIS calendar represents the flow of time graphically on screen. 
- (So "Time and Relative Dimension In Space" kind of makes sense. Maybe I should change it to TARDOS - Time and Relative Dimension On Screen?)
- In addition, my mom does not work well with technology, and cannot learn to navigate a new app.
- Thus my guiding principal is that the user may need to re-learn how to use the app each time they look at it. For this reason the controls are meant to be very simple and intuitive.

## Future Plans / Please Contact Me
I imagine there are others out there whose needs are similar, so I plan to make this app available when it's ready.
If you have a loved-one who struggles with the concept of time and might benefit from my approach, please contact me. 

## Basic Features
- Current day, date, and time are prominently displayed.
- The background is a color gradient representing sunrise, sunset, day and night. Thanks to https://sunrisesunset.io/api/ for providing the necessary data!
- The "Now" icon anchors the current moment in the timeline. Caregiver may opt to display the user's own face here (this feature is not yet available).
- Future events represented on the timeline scroll toward the Now icon from the right in real time.
- Time intervals are labeled relative to Now.
- Tapping an event shows time remaining to that event.
- The user can zoom in and out by dragging a single finger.
- When many events show on screen, lower priority events shrink in size.
- The caregiver can adjust settings by triple-tapping in the upper-right-hand corner.
- The TARDIS calendar draws events from Apple's Calendar app.
- Many caregivers or family members can easily add or edit events via their shared Apple Calendars.

# Setup

This app needs to be set up by a caregiver before the user can use it.

## Install
- Download the code.
- Install using XCode.
- Minimum Deployment iOS16.0
- Apple Calendar must be installed.
- Network access required.
- Looks best on an iPhone.
- Give permissions - see below.
- Set up calendars - see below.

## Permissions
- This app will ask permission to track the user's general (non-specific) location. This capability is needed in order to display sunrise and sunset information. 
    - If you plan on traveling with the app, you should choose "Allow While Using App."
    - Alternatively, you may choose "Allow Once" to establish your location, then chose "Don't Allow" the next time it asks. 
    - You may turn "Precise" on or off - the app will work either way.
- This app will ask permission to access events in your Apple Calendar App. Please say yes. This is where the TARDIS Calendar gets events to display!

## User Calendars
- This app displays information from the user's Apple Calendar App.
- Make sure the user has Apple's Calendar App installed and that it contains one or more calendars with events.
- When you launch this app you will see a list of calendars from the Apple Calendar App.
- Select the calendars you want to display by flipping the toggle switch next to each calendar name.
- For each selected calendar, choose a type: daily, meals, special, medical, or banners.
- The type attached to a calendar will determine how its events are displayed.
    - **Daily**: Use for mundane repeated events; lowest priority
    - **Meals**: Displays a meal icon
    - **Special**: Use for special events such as visits from family; displays a smiley face; high priority
    - **Medical**: Use for doctor's appointments and the like; highest priority
    - **Banners**: Use for day-long or hours-long events such as birthdays, as well as reminders such as "You should be in bed right now!" Banners are displayed on screen for as long as they are active. (This feature is not yet available.)
- Events from the selected calendars in the user's Apple Calendar App will appear on the TARDIS calendar.
- When events from different calendars occur at the same time, the higher priority event will be displayed.
- You may connect with as many Apple Calendar App calendars as you wish.
- To edit your user's list of connected calendars, triple-tap the upper right-hand corner of the TARDIS calendar.

## Using Apple's Calendar App
- Use Apple's Calendar App to enter and edit events. 
- A Caregiver can add events via their own device by using shared calendars.
- Multiple caregivers may enter events this way using multiple devices.
- Assign each event to the correct calendar to ensure it will show up on your user's TARDIS Calendar.
- Some BEST PRACTICES 
    - Name calendars with the User's name plus the type of event, for example: "Joanie-Medical".
    - Name calendars with the source of their events, for example: "Joanie-Special-From-Jack".
    - Give each event a one-word title with a short description in the "Notes" field.
- Changes made in a connected Apple calendar will automatically appear on the user's TARDIS Calendar.
- For changes to appear instantly, a caregiver can adjust the Apple Calendar settings. Go to Calendar/Settings/Accounts and set "Refresh Calendars" to "Push."
- To change the color of an icon on the TARDIS calendar, change the corresponding calendar color in your Apple Calendar App.
- Please refer to Apple's documentation for more information on sharing calendars through the Calendar app.

## Changing Settings
- TARDIS Calendar settings are hidden to prevent the user from accidentally opening them.
- To change the TARDIS Calendar's settings, triple-tap the upper right hand corner of the TARDIS calendar.
- From here you may edit the list of Apple's Calendar App calendars connected do the TARDIS app.
- You may also personalize the "Now" icon. We recommend using a photo of the user's smiling face, to show them where they are in time. (Feature not yet available.)
- Is there something else you wish you could set or personalize? Let me know!

# Planned Improvements
Following is the to-do list for planned improvements to code and features for this app as of 12/5/23
- UI Tweaks
	- Animate expanding Event views
	- Auto return to zoom level needs to happen when app is asleep
	- OR by tapping the now button
	- Hide past events
	- Add numbers for hours and minutes in the expanded view countdown.
    - Make everything look good on an iPad
- User Settings
	- Allow user to provide their own user image.
- Banner Messages
	- Recognize banner type
	- Display banner messages at bottom of screen 
- Tweaks for Later
	- Put zIndex values into an enum so they can be referenced contextually.
	- Use async and await
	- Improve timeline efficiency by dropping the refresh rate according to inactivity and/or smallest increment visible on screen.
	- Enum for user default keys
- Things to look into
	- Refactor: timeline is an environment object, but sometimes (as in the background view) gets passed as a parameter; make it consistent as an environment object?
	- Look into relative time descriptions which Josh suggested using for event view time remaining.
	- test longitude and latitude changes
	- It’s possible I’ve overthought that background gradient. Perhaps I can create one big gradient, shared via the @StateObject wrapper, then have the view display only the needed portion at any given moment, rather than re-generate a whole new gradient once per second.
