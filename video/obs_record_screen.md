# How to record screen with OBS Studio
* https://obsproject.com/
* OBS Studio is a great software for recording any online meeting, instruction video, etc...
* The software works with Windows, macOS 10.13+ and Linux.

## Configuration
1. Download and install from https://obsproject.com/
1. During the initial configuration set the video **Base (Canvas) Resolution** to the size of screen that you're going to record.
   * In this guide **1920x1080** with **Aspect Ration 16:9** was used. The **Output (Scaled) Resolution** is determined automatically.
   * These settings can be changed afterwards via:
      * Settings -> Video
1. If one is editing with a computer which has multiple GPUs, one might need to select the correct GPU for OBS to use.
   * Windows instructions: https://obsproject.com/kb/gpu-selection-guide
    
### Recording an online meeting
1. Add new source
   1. Click Add (plus sign) on Sources
   1. Select Window Capture and Create new
   1. Select Window and Hide or show cursor.
1. Set the Audio levels that volume does not go to red (this would mean that the sound gets distorted).
    * Notice that at least with Windows there's Desktop Audio and Mic/Aux "devices".
    * If you have head set and Desktop Audio is not showing signal when listening for example youtube.com:
        * Select Desktop Audio's Properties from the cog wheel -> change Device to headset.
        * Note that Mic/Aux will record you own microphone and disabling mic from online meeting software doesn't stop OBS from recording, so one needs to mute the Mic/Aux if muting is required.
1. click Start Recording.

### MacOS recording internal audio
* With Big Sur 11.1 it was possible to record internal browser audio from Chrome with these instructions
  * https://obsproject.com/forum/resources/os-x-capture-audio-with-ishowu-audio-capture.505/
* *Desktop audio on Mac currently requires a second program to help OBS capture it, since macOS does not provide a way to capture audio built-in. You can accomplish this with a program called iShowU.*
  * iShowU https://support.shinywhitebox.com/hc/en-us/articles/204161459-Installing-iShowU-Audio-Capture
  * Source https://obsproject.com/forum/threads/how-to-capture-desktop-audio-on-mac.16491/
