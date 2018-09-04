// https://stackoverflow.com/questions/7287696/moving-borderless-nswindow-fully-covered-with-web-view

#import <Cocoa/Cocoa.h>
@interface BorderlessWindow : NSWindow {
    NSPoint initialLocation;
}

- (id)initWithContentRect:(NSRect)contentRect
                styleMask:(NSUInteger)windowStyle
                  backing:(NSBackingStoreType)bufferingType
                    defer:(BOOL)deferCreation;

@property (assign) NSPoint initialLocation;

@end
