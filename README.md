# Scribbleasy
Yet another buggy online whiteboard app.

Needs a [server](https://github.com/KerakTelor86/ScribbleasyServer) to connect to.

## Disclaimers
- The actual whiteboard does not handle differing resolutions very well. It stretches its contents to fill whatever screen ratio it's being run in.
- Fast writing may result in dashed dots instead of a smooth line due to Flutter's low input refresh rate and also the fact that there is no smoothing. This is a design choice to preserve the "live" feeling of the whiteboard.

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

  Used to send a request to the server to reset the board. Every user must have clicked the button before a board reset can be performed.
  
- Sync board (refresh button)

  Used to sync board when you experience desync or whatever. Do not spam, the server **WILL** die.
