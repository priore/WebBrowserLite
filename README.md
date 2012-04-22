**WebBrowserLite 2012**

a nice Web Browser with basic UI not invasive functions

example:


    #import "WebBrowserLite.h"

    ...

    WebBrowserLite *webBrowser;

    ...

    NSURL *url = [NSURL URLWithString:@"https://www.facebook.com/pages/Prioregroupcom/161635751419"];
    webBrowser = [[WebBrowserLite alloc] initWithURL:url];
    [webBrowser show]; 

    ...

    [webBrowser release];


sample screen-shot :

![Screenshot](http://www.prioregroup.com/images/github/webbrowserlite/twoscreen.png)

[Prioregroup.com Home Page](http://www.prioregroup.com)