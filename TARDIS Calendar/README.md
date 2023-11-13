# TARDIS Calendar
This is an experimental "dementia" calendar for iOS, currently in development.

# TARDIS Calendar Concept
I'm designing this calendar for my mom, who has temporal lobe epilepsy, and cannot conceptualize time very well.
Other "dementia clocks" or calendars all seem to work on the same pricipal, which is to present lots of information on a big screen about what time it is now.
However, the current time doesn't answer many of her questions. What she really needs is a way of anchoring herself in relation to future events.
The TARDIS calendar represents the flow of time graphically on screen. 
(So "Time and Relative Dimension In Space" kind of makes sense. I may change it to TARDOS - Time and Relative Dimension On Screen.)
In addition, my mom does not work well with technology, and cannot learn to navigate a new app, so 
the calendar is presented in a single view, and the user controls are very simple and intuative.

# Future Plans / Please Contact Me
I imagine there are others out there whose needs are similar, so I plan to make this app available when it's ready.
If you have a loved-one who struggles with the concept of time and might benefit from my approach, please contact me. 

# Basic Features
- Current day, date, and time are prominantly displayed.
- Backdrop is a color gradient representing sunrise, sunset, day and night.
- "Now" icon shows the user's face at the current moment in the timeline.
- Future events represented on the timeline scroll toward the Now icon from the right in real time.
- Time intervals are labeled relative to Now.
- Tapping an event shows a countdown clock to that event.
- User can zoom in and out by dragging a single finger.
- Caregiver can adjust settings with a menu not easily accessed by the user.
- The TARDIS calendar draws events from Apple's Calendar app.
- Caregivers can easily add or edit events via their shared Apple Calendar.

# Setup (not all functionality is available yet)

## User Location
- The app will ask permission to track the user's general location. Please say yes. This capability is needed in order to display sunrise and sunset information. It will not be used in any other way.

## User Calendars
- This app displays information from your Apple Calendar app.
- You will be asked to provide the name(s) of one or more calendars for this app to track.
- For each calendar, select a type: daily, meals, special, medical, or banners.
- The type attatched to a calendar will determine how its events are displayed.
        - Daily: use for mundane repeated events; lowest priority
        - Meals: displays a meal icon
        - Special: use for special events such as visits from family
        - Medical: use for doctor's appointments and the like; highest priority
        - Banners: use for day-long or hours-long events such as birthdays, as well as reminders such as "You should be in bed right now!" Banners are displayed on screen for as long as they are active.
- You may set up as many calendars as you wish.
- Use Apple's Calendar app to enter and edit events.
- Any family member or caregiver who shares a calendar with the user can add events.
- If two events are scheduled at the same time, priority will be given based on the events' calendar types.
- Changes will appear in this app according to your Apple Calendar app settings. For changes to appear instantly, go to Calendar/Settings/Accounts and set Refresh Calendars to "Push."
- For best display results give each event a one-word title, with a short description in the "Notes" field.
- To change the color of an icon in this app, change the corresponding calendar color in your Apple Calendar app.
