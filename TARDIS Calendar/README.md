# TARDIS Calendar
This is an experimental "dementia" calendar for iOS, currently in development.

Throughout this readme I will refer to:
    - The User; this is the end user of the app, i.e. the person with dementia who may benefit from a calendar that displays events in relation to "now". It is assumed that the user knows nothing about computers or apps.
    - The Caregiver; this is the user's family member or other caregiver. They will be responsible for setting up the app and populating it with events using Apple's Calendar App.

# TARDIS Calendar Concept
I've designed this calendar for my mom, who has temporal lobe epilepsy, and often cannot conceptualize time very well.
Other "dementia clocks" or calendars all seem to work on the same pricipal, which is to present lots of information on a big screen about what time it is now.
However, the current time doesn't answer many of my Mom's questions. What she really needs is a way of anchoring herself in relation to future events.
The TARDIS calendar represents the flow of time graphically on screen. 
(So "Time and Relative Dimension In Space" kind of makes sense. Maybe I should change it to TARDOS - Time and Relative Dimension On Screen?)
In addition, my mom does not work well with technology, and cannot learn to navigate a new app. Thus my guiding principal is that the user may need to re-learn how to use the app each time they look at it. For this reason the controls are meant to be very simple and intuitive.

# Future Plans / Please Contact Me
I imagine there are others out there whose needs are similar, so I plan to make this app available when it's ready.
If you have a loved-one who struggles with the concept of time and might benefit from my approach, please contact me. 

# Basic Features
- Current day, date, and time are prominantly displayed.
- The background is a color gradient representing sunrise, sunset, day and night. Thanks to https://sunrisesunset.io/api/ for providing the necessary data!
- The "Now" icon anchors the current moment in the timeline. Caregiver may opt to display the user's own face here (this feature is not yet available).
- Future events represented on the timeline scroll toward the Now icon from the right in real time.
- Time intervals are labeled relative to Now.
- Tapping an event shows time remaining to that event.
- The user can zoom in and out by dragging a single finger.
- When many events show on screen, lower priority events shrink in size.
- The caregiver can adjust settings by tripple-tapping in the upper-right-hand corner.
- The TARDIS calendar draws events from Apple's Calendar app.
- Many caregivers or family members can easily add or edit events via their shared Apple Calendars.

# Setup

This app needs to be set up by a caregiver before the user can use it.

## Permissions
- This app will ask permission to track the user's general (non-specific) location. This capability is needed in order to display sunrise and sunset information. 
        - If you plan on travelling with the app, you should choose "Allow While Using App."
        - Alternatively, you may choose "Allow Once" to establish your location, then chose "Don't Allow" the next time it asks. 
        - You may turn "Precise" on or off - the app will work either way.
- This app will ask permission to access events in your Apple Calendar App. Please say yes. This is where the TARDIS Calendar gets events to display!

## User Calendars
- This app displays information from the user's Apple Calendar App.
- Make sure the user has Apple's Calendar App installed and that it contains one or more calendars with events.
- When you launch this app you will see a list of calendars from the Apple Calendar App.
- Select the calendars you want to display by flipping the toggle switch next to each calendar name.
- For each selected calendar, choose a type: daily, meals, special, medical, or banners.
- The type attatched to a calendar will determine how its events are displayed.
        - Daily: use for mundane repeated events; lowest priority
        - Meals: displays a meal icon
        - Special: use for special events such as visits from family; displays a smiley face; high priority
        - Medical: use for doctor's appointments and the like; highest priority
        - Banners: use for day-long or hours-long events such as birthdays, as well as reminders such as "You should be in bed right now!" Banners are displayed on screen for as long as they are active. (This feature is not yet available.)
- Events from the selected calendars in the user's Apple Calendar App will appear on the TARDIS calendar.
- When events from different calendars occur at the same time, the higher priority event will be displayed.
- You may connect with as many Apple Calendar App calendars as you wish.
- To edit your user's list of connected calendars, triple-tap the upper right-hand corner of the TARDIS calendar.

## Using Apple's Calendar App
- Use Apple's Calendar App to enter and edit events. 
- A Caregiver can add events via their own device by using shared calendars.
- Multiple caregivers may enter events this way using multiple devices.
- Assign each event to the correct calendar to ensure it will show up on your user's TARDIS Calendar.
- som BEST PRACTICES 
    - Name calendars with the User's name plus the type of event, for example: "Joanie-Medical".
    - Name calendars with the source of thier events, for example: "Joanie-Special-From-Jack".
    - Give each event a one-word title with a short description in the "Notes" field.
- Changes made in a connected Apple calendar will automatically appear on the user's TARDIS Calendar.
- For changes to appear instantly, a caregiver can adjust the Apple Calendar settings. Go to Calendar/Settings/Accounts and set "Refresh Calendars" to "Push."
- To change the color of an icon on the TARDIS calendar, change the corresponding calendar color in your Apple Calendar App.
- Please refer to Apple's documentation for more information on sharing calendars through the Calendar app.

## Changing Settings
- TARDIS Calendar settings are hidden to prevent the user from accidentally opening them.
- To change the TARDIS Calendar's settings, tripple-tap the upper right hand corner of the TARDIS calendar.
- From here you may edit the list of Apple's Calendar App calendars connected do the TARDIS app.
- You may also personalize the "Now" icon. We recommend using a photo of the user's smiling face, to show them where they are in time. (Feature not yet available.)
- Is there something else you wish you could set or personalize? Let me know!

