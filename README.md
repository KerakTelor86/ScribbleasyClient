# Scribbleasy
Yet another buggy online whiteboard app.

Needs a [server](https://github.com/KerakTelor86/ScribbleasyServer) to connect to.

## Disclaimers
- The actual whiteboard does not handle differing resolutions very well. It stretches its contents to fill whatever screen ratio it's being run in.
- Fast writing may result in dashed dots instead of a smooth line due to Flutter's low input refresh rate and also the fact that there is currently no input smoothing.

## How to use
There are three different pages in the app, namely:
### Login
Fill in the server IP, and server port input boxes correctly. The app has some form of input validation, but it's still best to make sure your inputs are valid before clicking connect.
### Session List
Once a successful connection has been established, a list of sessions currently being hosted on the server will display. Click on any session to connect to it. You will be prompted for a password before entering a session. Refresh the list using the right-most button on the top app bar. The plus button lets you host a new session.
### Board
The board itself has three functionalities, two of which can be used by clicking the buttons on the rightmost side of the top app bar:
- Draw stuff

  Just draw on the screen using whatever (e.g mouse, touchscreen, tablet pen) you want.
  
- Clear board (X button)

  Used to send a request to the server to reset the board. Every user must have clicked the button before a board reset is performed.
  
- Sync board (refresh button)

  Used to sync board when you experience desync or whatever. Do not spam, the server **WILL** die.

## Implementation notes
- The board bakes all drawing points to a dart.ui.Image object once the amount of drawing points have exceeded 50. This is done asynchronously and does not interrupt live drawing.

  Why: Most other whiteboard implementations on Flutter do not bake the points to a bitmap format. This gives in better image quality at the cost of having to redraw each point every frame. This significantly slows down the frame rate of the app, especially when the board has been used for a while. Baking the points to an image is in my opinion an acceptable compromise to mitigate this problem.
