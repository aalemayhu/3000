// https://stackoverflow.com/questions/7287696/moving-borderless-nswindow-fully-covered-with-web-view

#import "BorderlessWindow.h"


@implementation BorderlessWindow

@synthesize initialLocation;

- (id)initWithContentRect:(NSRect)contentRect
                styleMask:(NSUInteger)windowStyle
                  backing:(NSBackingStoreType)bufferingType
                    defer:(BOOL)deferCreation
{
    if((self = [super initWithContentRect:contentRect
                                styleMask:NSBorderlessWindowMask
                                  backing:NSBackingStoreBuffered
                                    defer:NO]))
    {
        return self;
    }
    
    return nil;
}

- (BOOL) canBecomeKeyWindow
{
    return YES;
}

- (BOOL) acceptsFirstResponder
{
    return YES;
}

- (NSTimeInterval)animationResizeTime:(NSRect)newWindowFrame
{
    return 0.1;
}

- (void)sendEvent:(NSEvent *)theEvent
{
    if([theEvent type] == NSKeyDown)
    {
        if([theEvent keyCode] == 36)
            return;
    }
    
    if([theEvent type] == NSLeftMouseDown)
        [self mouseDown:theEvent];
    else if([theEvent type] == NSLeftMouseDragged)
        [self mouseDragged:theEvent];
    
    [super sendEvent:theEvent];
}


- (void)mouseDown:(NSEvent *)theEvent
{
    self.initialLocation = [theEvent locationInWindow];
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    NSRect screenVisibleFrame = [[NSScreen mainScreen] visibleFrame];
    NSRect windowFrame = [self frame];
    NSPoint newOrigin = windowFrame.origin;
    
    NSPoint currentLocation = [theEvent locationInWindow];
    if(initialLocation.y > windowFrame.size.height - 40)
    {
        newOrigin.x += (currentLocation.x - initialLocation.x);
        newOrigin.y += (currentLocation.y - initialLocation.y);
        
        if ((newOrigin.y + windowFrame.size.height) > (screenVisibleFrame.origin.y + screenVisibleFrame.size.height))
        {
            newOrigin.y = screenVisibleFrame.origin.y + (screenVisibleFrame.size.height - windowFrame.size.height);
        }
        
        [self setFrameOrigin:newOrigin];
    }
}


@end
