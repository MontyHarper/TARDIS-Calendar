
# Table of Contents
- TARDIS Calendar: explains the purpose of the app, along with a list of major features
- Setup: explains how to install the app and how to set it up for daily use
- Planned Improvements: my to-do list for adding features and improving code

# TARDIS Calendar
This is an experimental iOS calendar for people with cognitive impairment, currently in development. 

Throughout this readme I will refer to:
- **The User** - this is the end user of the app, i.e. the person who may benefit from a calendar that displays events in relation to "now.”
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
I am currently in the testing stage; My mom has the app on an iPad in her room and is getting use to it. I’ve already made many adjustments based on her interactions. 
You are welcome to try the app out to see if it might be helpful for you. If you do install and use it,  I just ask that you contact me with your feedback. 

## Basic Features
- Current day, date, and time are prominently displayed.
- The background is a color gradient representing sunrise, sunset, day and night. Thanks to https://sunrisesunset.io/api/ for providing the necessary data!
- The "Now" icon anchors the current moment in the timeline. A caregiver may opt to display the user's own face here (this feature is not yet available).
- Future events represented on the timeline scroll toward the Now icon from the right in real time.
- Time intervals are labeled relative to Now.
- Tapping an event shows time remaining to that event.
- The user can zoom in and out by dragging a single finger.
- When many events show on screen, lower priority events shrink in size.
- The caregiver can adjust settings by triple-tapping in the upper-right-hand corner.
- The TARDIS calendar draws events from Apple's Calendar app.
- Many caregivers or family members can easily add or edit events via their shared Apple Calendars.
- “Banner” events show as a scrolling banner at the top of the screen. These messages appear and disappear according to their schedule.

# Setup
This app needs to be set up by a caregiver before the user can use it.

## Install
- Download the code.
- Install using XCode.
- Minimum Deployment iOS16.0
- Apple Calendar must be installed.
- Network access required.
- Looks best on an iPad.
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
    - **Special**: Use for special events such as visits from family; high priority
    - **Medical**: Use for doctor's appointments and the like; highest priority
    - **Banners**: Use for day-long or hours-long events such as birthdays, as well as reminders such as "You should be in bed right now!" Banners are displayed on screen for as long as they are active. 
- Events from the selected calendars in the user's Apple Calendar App will appear on the TARDIS calendar.
- When events from different calendars occur at the same time, the higher priority event will be displayed.
- You may connect with as many Apple Calendar App calendars as you wish.
- To edit your user's list of connected calendars, triple-tap the upper right-hand corner of the TARDIS calendar screen.

## Using Apple's Calendar App
- Use Apple's Calendar App to enter and edit events. 
- A Caregiver can add events via their own device by using shared calendars.
- Multiple caregivers may enter events this way using multiple devices.
- Assign each event to the correct calendar to ensure it will show up on your user's TARDIS Calendar.
- Some BEST PRACTICES 
    - Name calendars with the User's name plus the type of event, for example: "Joanie-Medical".
    - Name calendars with the source of their events, for example: "Joanie-Special-From-Jack".     
    - Certain calendar colors will show up better than others; yellow is a poor choice. 
    - Give each event a one or two word title with a short description in the "Notes" field.
- Changes made in a connected Apple calendar will automatically appear on the user's TARDIS Calendar.
- For changes to appear instantly, a caregiver can adjust the Apple Calendar settings. Go to Calendar/Settings/Accounts and set "Refresh Calendars" to “Every Minute.”
- To change the color of an icon on the TARDIS calendar, change the corresponding calendar color in your Apple Calendar App.
- Please refer to Apple's documentation for more information on sharing calendars through the Calendar app.

## Changing Settings
- TARDIS Calendar settings are hidden to prevent the user from accidentally opening them.
- To change the TARDIS Calendar's settings, triple-tap the upper right hand corner of the TARDIS calendar.
- From here you may edit the list of Apple's Calendar App calendars connected do the TARDIS app.
- You may also personalize the "Now" icon. We recommend using a photo of the user's smiling face, to show them where they are in time. (This feature is not yet available.)
- Is there something else you wish you could set or personalize? Let me know!

# Planned Improvements
Following is the to-do list for planned improvements and new features for this app as of 1/6/23
- Known Issues
    - App crashes when permission to access Calendar is switched from on to off. "Terminated due to signal 9"
- User Settings
	- Allow user to provide their own user image.

## Refactoring
For anyone interested in the code itself, this is my first significant app. I wrote it on my own while learning SwiftUI. I’m sure there are probably some anti-patterns happening in here! I will continue to re-factor as I learn more. Any feedback is appreciated. 

### On my to-do list:
- Refactor the content view using a TimeLine view?
- Improve timeline efficiency by dropping the refresh rate of the content view according to inactivity and/or smallest increment visible on screen.
- Don’t recalculate the solar event information every second; that should help smooth out the scroll
- Enum for user default keys
- Put zIndex values into an enum so they can be referenced contextually.
- timeline, eventManager, and size have evolved to become environment objects attached to the content view; make sure they are used consistently as such in all subviews. 
- Test longitude and latitude changes
- If internet is down; updateSolarDays should be called when connection resumes
- It’s possible I’ve overthought my background gradient. Can I create one big gradient, shared via the @StateObject wrapper, then have the view display only the needed portion at any given moment, rather than re-generate a whole new gradient once per second?  
- Use async and await rather than completions?
