
// TODO: add Win32 versions for saveFile, drawImage, ...


#include <assert.h>
#include <ncurses.h>
#include <pthread.h>
#pragma comment(lib, "ncurses.lib")
#include <termios.h>
#include <unistd.h>

struct termios original_termios;

#pragma region platform_finder

    #ifdef _WIN32

        #define _GRAPHICS_PLATFORM_WIN32 1

    #elif TARGET_OS_MAC

        #define _GRAPHICS_PLATFORM_UNIX 1
    
    #elif __APPLE__

        #define _GRAPHICS_PLATFORM_UNIX 1
    
    #elif __unix
    
        #define _GRAPHICS_PLATFORM_UNIX 1
    
    #else
        #define _GRAPHICS_PLATFORM_WIN32 0
        #define _GRAPHICS_PLATFORM_UNIX 0
    #endif
#pragma endregion

#ifdef _GRAPHICS_PLATFORM_UNIX
    #import <Cocoa/Cocoa.h>
    #import <objc/runtime.h>
    #import <SceneKit/SceneKit.h>
#elif _GRAPHICS_PLATFORM_WIN32
    #import <windows.h>
    #import <Windows.h>

    LRESULT CALLBACK __WndProc(HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam){
        switch (msg){
            case WM_DESTROY:
                PostQuitMessage(0);
                break;
            default:
                return DefWindowProc(hwnd, msg, wParam, lParam);
        };
    }
#endif


// Define a struct to pass data between C and Objective-C
struct Application {
    #ifdef _GRAPHICS_PLATFORM_UNIX
        NSApplication *application;
        NSWindow *window;
    #elif _GRAPHICS_PLATFORM_WIN32
        HWND hwnd;
        WNDCLASSEX wc;
        void* toCreate[11];
        // An array of the arguments of argSize, (dxExStyle), lpClassName, lpWindowName, dwStyle, x, y, nWidth, nHeight, hMenu, lpParam;
    #endif
};

enum KeyModifiers{
    Normal,
    Control
};

// enum Keys{
//     KeyUp = 3,
//     KeyLeft = 4,
//     KeyDown = 2,
//     KeyRight = 5,
//     KeyBackspace = 127,
//     KeyEnter = 10
// };
enum Keys{
    KeyUp = 259,
    KeyLeft = 260,
    KeyDown = 258,
    KeyRight = 261,
    KeyBackspace = 127,
    KeyEnter = 10
};


struct KeyEvent{
    char character;
    int modifier;
    int nnc; // Non-numeric character
};



int __DEFAULT_FONTSIZE = 12;
char *__DEFAULT_FONTNAME = ".AppleSystemUIFont\0";

extern "C" void *setFont(void *object, char *fontName, float fontSize){
    #ifdef _GRAPHICS_PLATFORM_UNIX
        assert([(__bridge id)object isKindOfClass:[NSView class]]);
        NSString *fontNameStr = [NSString stringWithUTF8String:fontName];
        NSFont *newFont = [NSFont fontWithName:fontNameStr size:fontSize];
        [object setFont:newFont];
        return object;
    #elif _GRAPHICS_PLATFORM_WIN32

    #endif
};

extern "C" void *setString(void *object, char* text){

    assert(object);
    #ifdef _GRAPHICS_PLATFORM_UNIX
    assert([(__bridge id)object isKindOfClass:[NSButton class]] || [(__bridge id)object isKindOfClass:[NSTextField class]] || [(__bridge id)object isKindOfClass:[NSTextView class]]);
    
    NSString *resText = [NSString stringWithUTF8String:text];
    if ([object isKindOfClass:[NSButton class]]){
        [(NSButton*)object setTitle: resText];
    }else if ([object isKindOfClass:[NSTextField class]]){
        [(NSTextField*)object setStringValue: resText];
    }else if ([object isKindOfClass:[NSTextView class]]){
        [(NSTextView*)object setString: resText];
    };
    #elif _GRAPHICS_PLATFORM_WIN32
    SetWindowText((HWND)object, text);
    
    // SendMessage(object, WM_SETTEXT, 0, (LPARAM)text);
    #endif
}



extern "C" char *getString(void *object){
    assert(object);
    #ifdef _GRAPHICS_PLATFORM_UNIX
    assert([(__bridge id)object isKindOfClass:[NSButton class]] || [(__bridge id)object isKindOfClass:[NSTextField class]] || [(__bridge id)object isKindOfClass:[NSTextView class]]);

        if ([object isKindOfClass:[NSButton class]]){
            return strdup([[(NSButton *)object title] UTF8String]);
        }else if ([object isKindOfClass:[NSTextField class]]){
            return strdup([[(NSTextField *)object stringValue] UTF8String]);
        }else if ([object isKindOfClass:[NSTextView class]]){
            return strdup([[(NSTextView *)object string] UTF8String]);
        }
    #elif _GRAPHICS_PLATFORM_WIN32

    #endif
};

extern "C" void *addString(void *object, char *text){
    #ifdef _GRAPHICS_PLATFORM_UNIX
        assert([(__bridge id)object isKindOfClass:[NSButton class]] || [(__bridge id)object isKindOfClass:[NSTextField class]] || [(__bridge id)object isKindOfClass:[NSTextView class]]);
        NSString *textStr = [NSString stringWithUTF8String:text];;
        NSString *originalString = [NSString stringWithUTF8String:getString(object)];
        NSString *appendedString = [originalString stringByAppendingString:textStr];
        setString(object, (char*)[appendedString UTF8String]);
    #elif _GRAPHICS_PLATFORM_WIN32

    #endif
};

NSString *insertCharacterAtIndex(NSString *originalString, int index, char character) {
    if (index >= 0 && index <= originalString.length) {
        NSMutableString *mutableString = [NSMutableString stringWithString:originalString];
        
        // Insert the new character at the specified index
        [mutableString insertString:[NSString stringWithFormat:@"%c", character] atIndex:index];
        
        // Convert back to NSString
        return [mutableString copy];
    }
    
    return originalString; // Return original string if the index is out of bounds
}

NSString *removeCharacterAtIndex(NSString *originalString, NSUInteger index) {
    if (index < originalString.length) {
        NSMutableString *mutableString = [NSMutableString stringWithString:originalString];
        [mutableString deleteCharactersInRange:NSMakeRange(index, 1)];
        return [mutableString copy];
    }
    
    return originalString; // Return original string if the index is out of bounds
}

static void __MandatoryKeyHandle(struct Application *window, KeyEvent event){
    char ch = event.nnc;
   NSResponder *currentResponder = [window->window firstResponder];
    while (currentResponder != nil) {
        if ([currentResponder isKindOfClass:[NSTextField class]]) {
            NSTextField *focusedTextField = (NSTextField *)currentResponder;
            dispatch_async(dispatch_get_main_queue(), ^{
                if (event.modifier == Normal){
                    if (ch == KeyBackspace){
                         NSRange currentSelectedRange = [[focusedTextField currentEditor] selectedRange];
                        if (currentSelectedRange.length > 1) {
                                [[focusedTextField currentEditor] replaceCharactersInRange:currentSelectedRange withString:@""];
                        }else{
                            if ([focusedTextField.stringValue length] > 0) {
                                focusedTextField.stringValue = removeCharacterAtIndex(focusedTextField.stringValue, currentSelectedRange.location-1);
                                    NSUInteger newCursorPosition = currentSelectedRange.location - 1;
                                    [[focusedTextField currentEditor] setSelectedRange:NSMakeRange(newCursorPosition, 0)];
                            }
                        }
                    }else if(ch == KeyLeft){
                        if ([focusedTextField currentEditor]) {
                            NSRange currentSelectedRange = [[focusedTextField currentEditor] selectedRange];
                            if (currentSelectedRange.location > 0) {
                                NSUInteger newCursorPosition = currentSelectedRange.location - 1;
                                NSRange newSelectedRange = NSMakeRange(newCursorPosition, 0);
                                [[focusedTextField currentEditor] setSelectedRange:newSelectedRange];
                            }
                        }

                    }else if(ch == KeyRight){
                        if ([focusedTextField currentEditor]) {
                            NSRange currentSelectedRange = [[focusedTextField currentEditor] selectedRange];
                            if (currentSelectedRange.location > 0) {
                                NSUInteger newCursorPosition = currentSelectedRange.location + 1;
                                NSRange newSelectedRange = NSMakeRange(newCursorPosition, 0);
                                [[focusedTextField currentEditor] setSelectedRange:newSelectedRange];
                            }
                        }

                    }else{
                        NSRange range = [[focusedTextField currentEditor] selectedRange];
                        focusedTextField.stringValue = insertCharacterAtIndex(focusedTextField.stringValue, range.location, ch);
                                NSUInteger newCursorPosition = range.location + 1;
                                NSRange newSelectedRange = NSMakeRange(newCursorPosition, 0);
                                [[focusedTextField currentEditor] setSelectedRange:newSelectedRange];
                    }
                }
            });
            break;
        }
        currentResponder = [currentResponder nextResponder];
    }
};

int __DefaultKeyHandle(struct Application* window, KeyEvent event) {
    char ch = event.nnc;
    if (event.modifier == Control){
        // switch((ch+64) + ('a' - 'A')){
        switch (ch){
            case 'C': //Ctrl+C
                exit(1);
            default:{}
        }
        // }
    }
    return 0;
} 
int (*__KeyHandle)(struct Application* window, KeyEvent event);

#import <Cocoa/Cocoa.h>

@interface MouseStuff : NSView

@property (nonatomic, copy) void (^mouseDown)(NSEvent *);
@property (nonatomic, copy) void (^mouseUp)(NSEvent *);
@property (nonatomic, copy) void (^mouseDragged)(NSEvent *);
@property (nonatomic, copy) void (^mouseMoved)(NSEvent *);
@property (nonatomic, copy) void (^mouseEntered)(NSEvent *);
@property (nonatomic, copy) void (^mouseExited)(NSEvent *);

@end

@implementation MouseStuff
- (void)mouseDown:(NSEvent *)event {
    if (self.mouseDown) {
        self.mouseDown(event);
    }
}

- (void)mouseUp:(NSEvent *)event{
    if (self.mouseUp) {
        self.mouseUp(event);
    }
}

- (void)mouseDragged:(NSEvent *)event{
    if (self.mouseDragged) {
        self.mouseDragged(event);
    }
}

- (void)mouseMoved:(NSEvent *)event{
    if (self.mouseMoved) {
        self.mouseMoved(event);
    }
}

- (void)mouseEntered:(NSEvent *)event{
    if (self.mouseEntered) {
        self.mouseEntered(event);
    }
}

- (void)mouseExited:(NSEvent *)event{
    if (self.mouseExited) {
        self.mouseExited(event);
    }
}

@end


extern "C" int squash(int val, int min, int max){
    int res = val;
    if (val < min){
        res = min;
    }else if(val > max){
        res = max;
    };
    return res;
}

extern "C" float squashFloat(float val, float min, float max){
    float res = val;
    if (val < min){
        res = min;
    }else if(val > max){
        res = max;
    };
    return res;
}

extern "C" struct Application createWindow(char* title, int x=100, int y=100, int width=100, int height=100) {
    
    assert(width > 0);
    assert(height > 0);
    __KeyHandle = __DefaultKeyHandle;
    tcgetattr(STDIN_FILENO, &original_termios);
    struct termios raw = original_termios;
    cfmakeraw(&raw);
    tcsetattr(STDIN_FILENO, TCSAFLUSH, &raw);
    #ifdef _GRAPHICS_PLATFORM_UNIX
        NSString *titleString = [NSString stringWithUTF8String:title];
        
        struct Application app;
        NSApplication *application = [NSApplication sharedApplication];

        NSRect frame = NSMakeRect(x, y, width, height);
        NSWindow *window = [[NSWindow alloc] initWithContentRect:frame
                                                    styleMask:(NSWindowStyleMaskTitled |
                                                                NSWindowStyleMaskClosable |
                                                                NSWindowStyleMaskResizable)
                                                        backing:NSBackingStoreBuffered
                                                        defer:0];
        window.isVisible = true;


        [window setTitle:titleString];
        app.application = application;
        app.window = window;
    #elif _GRAPHICS_PLATFORM_WIN32
        WNDCLASSEX wc = { sizeof(WNDCLASSEX), CS_CLASSDC, __WndProc, 0L, 0L, GetModuleHandle(NULL), NULL, NULL, NULL, NULL, "SimpleWin32App", NULL };
        RegisterClassEx(&wc);
        struct Application app;
        app.wc = wc;

        // Create the window
        HWND hwnd = CreateWindow(wc.lpszClassName, "Simple Win32 Application", WS_OVERLAPPEDWINDOW, 100, 100, 500, 500, NULL, NULL, wc.hInstance, NULL);

        // Show the window
        ShowWindow(hwnd, SW_SHOWDEFAULT);
        app.hwnd = hwnd;
        UpdateWindow(hwnd);
    #endif
    return app;
}

extern "C" void *getWindowLayer(struct Application application){
    #ifdef _GRAPHICS_PLATFORM_UNIX
        return application.window.contentView.layer;
    #elif _GRAPHICS_PLATFORM_WIN32
    #endif
};

extern "C" void *getLayer(void *object){
    #ifdef _GRAPHICS_PLATFORM_UNIX
        NSView *view = (NSView*)object;
        return view.layer;
    #elif _GRAPHICS_PLATFORM_WIN32
    #endif
};

#ifdef ThreeDimensional


    extern "C" void *createSceneView(struct Application application, bool transparent){
        #ifdef _GRAPHICS_PLATFORM_UNIX
            SCNView *sceneView = [[SCNView alloc] initWithFrame:application.window.contentView.bounds];
            sceneView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
            sceneView.pointOfView.camera.fieldOfView = 1.0;
            sceneView.pointOfView.camera.automaticallyAdjustsZRange = NO;
            sceneView.autoenablesDefaultLighting = YES;
            SCNNode *parentNode = [SCNNode node];
            SCNScene *combinedScene = [SCNScene scene];
            [combinedScene.rootNode addChildNode:parentNode];
            sceneView.scene = combinedScene;
            if (transparent){
                sceneView.backgroundColor = NSColor.clearColor;
            };
            return sceneView;
        #elif _GRAPHICS_PLATFORM_WIN32

        #endif
    }

    extern "C" void *createScene(struct Application application){
        #ifdef _GRAPHICS_PLATFORM_UNIX
        SCNScene *scene = [SCNScene scene];
        return scene;
        #elif _GRAPHICS_PLATFORM_WIN32

        #endif

    };


    extern "C" void addSceneToSceneView(struct Application application, SCNView *sceneView, SCNScene *scene){
        #ifdef _GRAPHICS_PLATFORM_UNIX
        SCNNode *rootNode = sceneView.scene.rootNode;
        SCNNode *rootNode1 = [rootNode.childNodes firstObject];
        [rootNode1 addChildNode: scene.rootNode];
        sceneView.allowsCameraControl = YES;
        #elif _GRAPHICS_PLATFORM_WIN32

        #endif
    }

    extern "C" void *addCube(SCNScene *scene, float width, float height, float length, float chamferRadius){
        #ifdef _GRAPHICS_PLATFORM_UNIX
        SCNBox *cube = [SCNBox boxWithWidth:width height:height length:length chamferRadius:chamferRadius];
            SCNNode *cubeNode = [SCNNode nodeWithGeometry:cube];
        return cubeNode;
        #elif _GRAPHICS_PLATFORM_WIN32

        #endif
    }

    extern "C" void *color3D(SCNNode *node, int r, int g, int b, float a=1.0){
        #ifdef _GRAPHICS_PLATFORM_UNIX
        SCNGeometry *geometry = node.geometry;
        SCNMaterial *material = [SCNMaterial material];
        material.diffuse.contents = [NSColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0];
        geometry.materials = @[material];
        SCNNode *newNode = [SCNNode nodeWithGeometry:geometry];
        return newNode;
        #elif _GRAPHICS_PLATFORM_WIN32

        #endif
    }

    extern "C" void *create3DFromDae(SCNScene *scene, char *text){
        #ifdef _GRAPHICS_PLATFORM_UNIX
        NSString *fileName = [NSString stringWithUTF8String:text];
            NSURL *daeURL = [[NSBundle mainBundle] URLForResource:fileName withExtension:@"dae"];
            SCNScene *daeScene = [SCNScene sceneWithURL:daeURL options:nil error:nil];
            SCNNode *node = [daeScene.rootNode clone];
            [scene.rootNode addChildNode:node];
            return node;
        #elif _GRAPHICS_PLATFORM_WIN32

        #endif
    }

    extern "C" void *create3DFromStl(SCNScene *scene, char* file){
        NSString *fileName = [NSString stringWithUTF8String:file];
        NSURL *stlURL = [[NSBundle mainBundle] URLForResource:fileName withExtension:@"stl"];
        SCNNode *node = [SCNNode nodeWithGeometry:[SCNGeometry geometryWithSTLAtURL:stlURL]];
        [scene.rootNode addChildNode:node];
        return node;
    };

    extern "C" void* create3DFromPly(SCNScene *scene, char *file){
        NSString *fileName = [NSString stringWithUTF8String:file];
        NSURL *plyURL = [[NSBundle mainBundle] URLForResource:fileName withExtension:@"ply"];
        SCNNode *node = [SCNNode nodeWithGeometry:[SCNGeometry geometryWithPLYAtURL:plyURL]];
        [scene.rootNode addChildNode:node];
        return node;
    };
    
    // extern "C" void *load3DFromWaveFront(SCNScene *scene, char *file){
    //     NSString *fileName = [NSString stringWithUTF8String:file];
    //     NSURL *objURL = [[NSBundle mainBundle] URLForResource:fileName withExtension:@"obj"];
    //     MDLAsset *asset = [[MDLAsset alloc] initWithURL:objURL];
    //     SCNNode *node = [SCNNode nodeWithMDLObject:[asset objectAtIndex:0]];
    //     [scene.rootNode addChildNode:node];
    //     return node;
    // };

    extern "C" void *addSphere(SCNScene *scene, float radius){
        #ifdef _GRAPHICS_PLATFORM_UNIX
        SCNSphere *sphereGeometry = [SCNSphere sphereWithRadius:radius];
        SCNNode *sphereNode = [SCNNode nodeWithGeometry:sphereGeometry];
        return sphereNode;
        #elif _GRAPHICS_PLATFORM_WIN32

        #endif
    }

    extern "C" void *addTorus(SCNScene *scene, float ringRadius, float pipeRadius){
        #ifdef _GRAPHICS_PLATFORM_UNIX
        SCNTorus *torusGeometry = [SCNTorus torusWithRingRadius:ringRadius pipeRadius:pipeRadius];
            SCNNode *torusNode = [SCNNode nodeWithGeometry:torusGeometry];

        return torusNode;
        #elif _GRAPHICS_PLATFORM_WIN32

        #endif
    }

    extern "C" void *addCylinder(SCNScene *scene, float radius, float height){
        #ifdef _GRAPHICS_PLATFORM_UNIX
        SCNCylinder *cylinderGeometry = [SCNCylinder cylinderWithRadius:radius height:height];
            SCNNode *cylinderNode = [SCNNode nodeWithGeometry:cylinderGeometry];
            return cylinderNode;
        #elif _GRAPHICS_PLATFORM_WIN32

        #endif
    }

    extern "C" void *addCone(SCNScene *scene, float topRadius, float bottomRadius, float height){
    #ifdef _GRAPHICS_PLATFORM_UNIX
        SCNCone *coneGeometry = [SCNCone coneWithTopRadius:topRadius bottomRadius:bottomRadius height:height];
        SCNNode *coneNode = [SCNNode nodeWithGeometry:coneGeometry];
            
            return coneNode;
        #elif _GRAPHICS_PLATFORM_WIN32

        #endif
    }

    extern "C" void *addPyramid(SCNScene *scene, float width, float height, float length){
        #ifdef _GRAPHICS_PLATFORM_UNIX
        SCNPyramid *pyramidGeometry = [SCNPyramid pyramidWithWidth:width height:height length:length];
            
        SCNNode *pyramidNode = [SCNNode nodeWithGeometry:pyramidGeometry];
            
            return pyramidNode;
        
        #elif _GRAPHICS_PLATFORM_WIN32

        #endif

    }

    extern "C" void *addPlane(SCNScene *scene, float width, float height){
        #ifdef _GRAPHICS_PLATFORM_UNIX
        SCNPlane *planeGeometry = [SCNPlane planeWithWidth:width height:height];
            SCNNode *planeNode = [SCNNode nodeWithGeometry:planeGeometry];
            
        
            return planeNode;
        #elif _GRAPHICS_PLATFORM_WIN32

        #endif
    }

    extern "C" void *addCapsule(SCNScene *scene, float capRadius, float height){
        #ifdef _GRAPHICS_PLATFORM_UNIX
        SCNCapsule *capsuleGeometry = [SCNCapsule capsuleWithCapRadius:capRadius height:height];
            
            SCNNode *capsuleNode = [SCNNode nodeWithGeometry:capsuleGeometry];
            
            return capsuleNode;
        #elif _GRAPHICS_PLATFORM_WIN32

        #endif
    }

    extern "C" void *addTube(SCNScene *scene, float innerRadius, float outerRadius, float height){
        #ifdef _GRAPHICS_PLATFORM_UNIX
        SCNTube *tubeGeometry = [SCNTube tubeWithInnerRadius:innerRadius outerRadius:outerRadius height:height];
        
            SCNNode *tubeNode = [SCNNode nodeWithGeometry:tubeGeometry];
            return tubeNode;
        #elif _GRAPHICS_PLATFORM_WIN32
        #endif
    }

    extern "C" void *scale3D(SCNNode *node, float width, float height, float thickness){
        #ifdef _GRAPHICS_PLATFORM_UNIX
        node.transform = SCNMatrix4Identity;
        node.scale = SCNVector3Make(width, height, thickness);
        return node;
        #elif _GRAPHICS_PLATFORM_WIN32

        #endif
    }

    extern "C" void *move3D(SCNNode *node, int x, int y, int z){
        #ifdef _GRAPHICS_PLATFORM_UNIX
        node.position = SCNVector3Make(x, y, z);
        return node;
        #elif _GRAPHICS_PLATFORM_WIN32

        #endif
    };

    extern "C" void *addNode(SCNScene *scene, SCNNode *node){
        #ifdef _GRAPHICS_PLATFORM_UNIX
        [scene.rootNode addChildNode:node];
        #elif _GRAPHICS_PLATFORM_WIN32
        #endif
    }

    extern "C" SCNNode *getNodeFromScene(SCNScene *scene){
        return scene.rootNode;
    }
#endif




extern "C" void Update(struct Application *app);
pthread_t __PUBLIC__KEYTHREAD;
pthread_t __NEXT_PUBLIC__KEYTHREAD;

#import <Foundation/Foundation.h>


static void *__UpdateHigher(void *vargp) 
{ 
    int ch;
    while (true) {
        ch = getchar();
        KeyEvent event;
            event.nnc = ch;
        if (isalpha(ch)){
            event.character = ch;
        }else if(isalpha(ch+64)){
            event.modifier = Control;
            event.character = (ch+64);
            event.nnc = event.character;
        };
        if (event.modifier == Control && event.character == 74){
            event.modifier = Normal;
            event.character = KeyEnter;
            event.nnc = event.character;
        }else if(event.modifier == Control && event.character == 'l'){
            event.modifier = Normal;
            event.character = ',';
            event.nnc = event.character;
        };
        if (event.modifier == Control && event.character == 'n'){
            event.modifier = Normal;
            event.character = '.';
            event.nnc = event.character;
        };
        if (event.modifier == Control && event.character == ' '){
            event.modifier = Normal;
            event.character = ' ';
            event.nnc = event.character;
        };
        // switch((ch+64) + ('a' - 'A')){
        struct Application* app = static_cast<struct Application*>(vargp);
        if (__KeyHandle(app, event) == 0){
            __MandatoryKeyHandle(app, event);
        }
    }
}



extern "C" void setDefaultFont(int fontSize, char *fontName){
    __DEFAULT_FONTSIZE = fontSize;
    __DEFAULT_FONTNAME = fontName;
};

static void *__UpdateLoop(void *vargp){
    // dispatch_async(dispatch_get_main_queue(), ^{
    struct Application* app = static_cast<struct Application*>(vargp);
    while (true){
        NSArray *subviews = [[app->window contentView] subviews];
        for (NSView *view in subviews) {
            if ([view isKindOfClass:[MouseStuff class]] == NO){
            NSFont *font = [view font];
            if ([font.fontName isEqualToString: @".AppleSystemUIFont"] && font.pointSize == 12.00000){
                setFont(view, __DEFAULT_FONTNAME, __DEFAULT_FONTSIZE);
            }
            }
        }
        Update(app);
    };
    // });
}


extern "C" void initializeWindowLoop(struct Application application) {
    pthread_create(&__PUBLIC__KEYTHREAD, NULL, __UpdateHigher, &application); 
    pthread_create(&__NEXT_PUBLIC__KEYTHREAD, NULL, __UpdateLoop, &application); 
    #ifdef _GRAPHICS_PLATFORM_UNIX
        // [application.window makeKeyAndOrderFront:nil];
        [application.application run];
    #elif _GRAPHICS_PLATFORM_WIN32
        MSG msg;
        while (GetMessage(&msg, NULL, 0, 0) > 0){
            TranslateMessage(&msg);
            DispatchMessage(&msg);
        };
        UnregisterClass(application.wc.lpszClassName, application.wc.hInstance);
    #endif
    tcsetattr(STDIN_FILENO, TCSAFLUSH, &original_termios);
    // pthread_create(&__PUBLIC__KEYTHREAD, NULL, __UpdateLoop, &application); 
}

extern "C" NSTextField *drawLabel(struct Application application, float x, float y, float width, float height, const char *text, bool bezeled = 1, bool drawsBackground = 1) {
    
    
    assert(width > 0);
    assert(height > 0);
    #ifdef _GRAPHICS_PLATFORM_UNIX
        NSString *resText = [NSString stringWithUTF8String:text];
        NSTextField *textField = [[NSTextField alloc] initWithFrame:NSMakeRect(x, y, width, height)];
        [textField setStringValue:resText];
        [textField setEditable:0];
        [textField setBezeled:bezeled];
        [textField setDrawsBackground:drawsBackground];
        [textField setBackgroundColor:NSColor.clearColor];
        setFont(textField, __DEFAULT_FONTNAME, __DEFAULT_FONTSIZE);
        return textField;
    #elif _GRAPHICS_PLATFORM_WIN32
        // Problem: Gray Background around it. Search : How to create transparent static text in win32 c

        
        application.toCreate[0] = (void*)10;
        application.toCreate[1] = (void*)"STATIC";
        application.toCreate[2] = (void*)text;
        application.toCreate[3] = (void*)(WS_VISIBLE | WS_CHILD);
        application.toCreate[4] = (void*)x;
        application.toCreate[5] = (void*)y;
        application.toCreate[6] = (void*)(width+x);
        application.toCreate[7] = (void*)(height+y);
        application.toCreate[8] = (void*)NULL;
        application.toCreate[9] = (void*)NULL;
        // HWND hwndLabel = CreateWindow(
        //     "STATIC"
        //     , text
        //     , WS_VISIBLE | WS_CHILD,
        //      x,
        //       y,
        //        width+x,
        //         height+y,
        //          application.hwnd, 
        //          NULL, 
        //          application.wc.hInstance, 
        //          NULL);
    #endif
}

extern "C" void *setBezeled(void *object, bool bezeled){
    assert(object);
    #ifdef _GRAPHICS_PLATFORM_UNIX
        assert([(__bridge id)object isKindOfClass:[NSView class]]);
        [(NSView*)object setBezeled:bezeled];
        return object;
    #elif _GRAPHICS_PLATFORM_WIN32
    #endif
}
extern "C" void *setDrawsBackground(void *object, bool drawsBackground){
    assert(object);
    #ifdef _GRAPHICS_PLATFORM_UNIX
        assert([(__bridge id)object isKindOfClass:[NSView class]]);
        [(NSView*)object setDrawsBackground:drawsBackground];
        return object;
    #elif _GRAPHICS_PLATFORM_WIN32
    #endif
}



extern "C" void *drawButton(struct Application application, const char *text, int x, int y, int width, int height) {
    
    ;
    
    assert(width > 0);
    assert(height > 0);
    
    #ifdef _GRAPHICS_PLATFORM_UNIX
        NSString *resText = [NSString stringWithUTF8String:text];
        NSButton *button = [[NSButton alloc] initWithFrame:NSMakeRect(x, y, width, height)];
        [button setTitle:resText];
        [button setBezelStyle:NSBezelStyleRounded];

        // Add the button to the window's content view
        return (void *)button;
    #elif _GRAPHICS_PLATFORM_WIN32
    application.toCreate[0] = (void*)10;
    application.toCreate[1] = (void*)TEXT("BUTTON");
    application.toCreate[2] = (void*)TEXT(text);
    application.toCreate[3] = (void*)(WS_TABSTOP | WS_VISIBLE | WS_CHILD | BS_DEFPUSHBUTTON);
    application.toCreate[4] = (void*)x;
    application.toCreate[5] = (void*)y;
    application.toCreate[6] = (void*)(width+x);
    application.toCreate[7] = (void*)(height+y);
    application.toCreate[8] = (void*)NULL;
    application.toCreate[9] = (void*)NULL;
    #endif
}



extern "C" void *drawSlider(int x, int y, int width, int height, float minValue, float maxValue, float defaultValue, bool continuous = 1){
    
    ;
    
    assert(width > 0);
    assert(height > 0);
    assert(defaultValue > minValue);


    #ifdef _GRAPHICS_PLATFORM_UNIX
        NSRect sliderFrame = NSMakeRect(x, y, width, height);
        NSSlider *slider = [[NSSlider alloc] initWithFrame:sliderFrame];

        // Set the slider's minimum and maximum values
        [slider setMinValue:minValue];
        [slider setMaxValue:maxValue];

        // Set an initial value for the slider
        [slider setDoubleValue:defaultValue];

        // Set whether the slider sends continuous update events
        [slider setContinuous:continuous];

        // Add the slider to your view
        return (void*)slider;
    #elif _GRAPHICS_PLATFORM_WIN32
    // 0t implemented
    #endif
}

extern "C" void *setContious(void *object, bool shouldUse){
    assert(object);
    #ifdef _GRAPHICS_PLATFORM_UNIX
        assert([(__bridge id)object isKindOfClass:[NSView class]]);
        [(NSView*)object setContinuous:shouldUse];
    #elif _GRAPHICS_PLATFORM_WIN32
    #endif
};

// extern "C" void *drawTextField(struct Application window, int x, int y, int width, int height, char *placeholder, char* defaultText){
    
// }

extern "C" void *drawTextField(struct Application application, int x, int y, int width, int height, char* text, char *placeHolder){
    
    assert(width > 0);
    assert(height > 0);
    #ifdef _GRAPHICS_PLATFORM_UNIX
        

        
        NSTextField *textField = drawLabel(application, x, y, width, height, text, 1);
        NSString *placeHolderStr = [NSString stringWithUTF8String:placeHolder];
        [textField setPlaceholderString:placeHolderStr];
        return textField;

        
    #elif _GRAPHICS_PLATFORM_WIN32

    application.toCreate[0] = (void*)11;
    application.toCreate[1] = (void*)WS_EX_CLIENTEDGE;
    application.toCreate[2] = (void*)TEXT("EDIT");
    application.toCreate[3] = (void*)TEXT(text);
    application.toCreate[4] = (void*) (WS_VISIBLE | WS_CHILD);
    application.toCreate[5] = (void*)x;
    application.toCreate[6] = (void*)y;
    application.toCreate[7] = (void*)(width+x);
    application.toCreate[8] = (void*)(height+y);
    application.toCreate[9] = (void*)NULL;
    application.toCreate[10] = (void*)NULL;
    #endif
}

extern "C" void *drawTextView(struct Application application, int x, int y, int width, int height, char* text){
    ;
    
    assert(width > 0);
    assert(height > 0);
    #ifdef _GRAPHICS_PLATFORM_UNIX
    NSString *resText = [NSString stringWithUTF8String:text];
    NSTextView *textView = [[NSTextView alloc] initWithFrame:NSMakeRect(x, y, width, height)];
    [textView setString:resText];
    [textView becomeFirstResponder];
    [application.window makeFirstResponder:textView];

    // Add it to your view
    return (void*)textView;
    #elif _GRAPHICS_PLATFORM_WIN32
    drawLabel(application, x, y, width, height, text);
    #endif
}




extern "C" void *drawProgressIndicator(int x, int y, int width, int height, int minValue, int maxValue, int doubleValue){
    
    
    assert(width > 0);
    assert(height > 0);

    #ifdef _GRAPHICS_PLATFORM_UNIX
        // Create an NSProgressIndicator programmatically
        NSProgressIndicator *progressIndicator = [[NSProgressIndicator alloc] initWithFrame:NSMakeRect(x, y, width, height)];
        [progressIndicator setStyle:NSProgressIndicatorStyleBar];
        [progressIndicator setMinValue:minValue];
        [progressIndicator setMaxValue:maxValue];
        [progressIndicator setDoubleValue:doubleValue]; // Set the current progress value

        // Add it to your view
        return (void*)progressIndicator;
    #elif _GRAPHICS_PLATFORM_WIN32
    // 0t implemented
    #endif
}

extern "C" void *setDoubleValue(void *object, float doubleValue){
    assert(object);
    #ifdef _GRAPHICS_PLATFORM_UNIX
    assert([(__bridge id)object isKindOfClass:[NSView class]]);
        [(NSView*)object setDoubleValue:doubleValue];
        return object;
    #elif _GRAPHICS_PLATFORM_WIN32
    // 0t implemented
    #endif
}

extern "C" void *drawDropDown(int x, int y, int width, int height){
    
    assert(width > 0);
    assert(height > 0);
    
    NSPopUpButton *dropDownMenu = [[NSPopUpButton alloc] initWithFrame:NSMakeRect(x, y, width, height)];
    return dropDownMenu;
}

extern "C" void *addDropDownItem(void *object, char* title){
    assert(object);
    #ifdef _GRAPHICS_PLATFORM_UNIX
        assert([(__bridge id)object isKindOfClass:[NSPopUpButton class]]);
        
        [object addItemWithTitle:[NSString stringWithUTF8String:title]];
        return object;
    #elif _GRAPHICS_PLATFORM_WIN32
    #endif
}

// Add drop dpwms
// For drawing graphics, use drawHTML and html's canvas

extern "C" void *drawColorPicker(int x, int y, int width, int height, bool alphaIncluded=1){
    
    assert(width > 0);
    assert(height > 0);
    
    #ifdef _GRAPHICS_PLATFORM_UNIX
        // Create an NSColorWell programmatically
        NSApplication *app = [NSApplication sharedApplication];
        
        // Create the color panel
        NSColorPanel *colorPanel = [NSColorPanel sharedColorPanel];
        [colorPanel setShowsAlpha:alphaIncluded]; // If you want to include alpha (transparency) in color selection
        
        // Show the color panel modally
        NSInteger result = [NSApp runModalForWindow:colorPanel];
        
        // Check if the user selected a color
        if (result == NSModalResponseOK) {
            NSColor *selectedColor = [colorPanel color];
            return selectedColor;
        } else {
            return nil; // User canceled color selection
        }
    #elif _GRAPHICS_PLATFORM_WIN32
    // 0t implemented
    #endif

}



extern "C" void *drawDatePicker(int x, int y, int width, int height){
    
    assert(width > 0);
    assert(height > 0);


    #ifdef _GRAPHICS_PLATFORM_UNIX
        // Create an NSDatePicker programmatically
        NSDatePicker *datePicker = [[NSDatePicker alloc] initWithFrame:NSMakeRect(x, y, width, height)];
        [datePicker setDatePickerStyle:NSTextFieldAndStepperDatePickerStyle];

        // Add it to your view
        return (void*)datePicker;
    #elif _GRAPHICS_PLATFORM_WIN32
    //0t implemented
    #endif

}


extern "C" int drawAlert(char* text, char* defaultButton, char* textWithFormat){
    


    #ifdef _GRAPHICS_PLATFORM_UNIX
    
        NSString *resText = [NSString stringWithUTF8String:text];
        NSString *defaultButtonString = [NSString stringWithUTF8String:defaultButton];
        NSString *textWithFormatString = [NSString stringWithUTF8String:textWithFormat];
        
        NSAlert *alert = [NSAlert alertWithMessageText:resText
                                    defaultButton:defaultButtonString
                                alternateButton:nil
                                    otherButton:nil
                        informativeTextWithFormat:textWithFormatString];
        return [alert runModal]-1000;
    #elif _GRAPHICS_PLATFORM_WIN32
        UINT num = 0;
        if (defaultButton == "OK"){
            num = MB_OK;
        };
        MessageBoxA((HWND)NULL, (LPCTSTR)text, (LPCTSTR)textWithFormat, (UINT)num);
    #endif

}

extern "C" int drawAlertWithButtons(char* text, char* button1, char *button2, char* button3, char* textWithFormat) {
    @autoreleasepool {
        #ifdef _GRAPHICS_PLATFORM_UNIX
                // fprintf(stderr, "(%d)", 1);
                NSString *resText = [NSString stringWithUTF8String:text];
                NSString *textWithFormatString = [NSString stringWithUTF8String:textWithFormat];

                NSAlert *alert = [[NSAlert alloc] init];
                [alert setMessageText:resText];
                [alert setInformativeText:textWithFormatString];
                if (button1) {
                    [alert addButtonWithTitle:[NSString stringWithUTF8String:button1]];
                }
                if (button2) {
                    [alert addButtonWithTitle:[NSString stringWithUTF8String:button2]];
                }
                if (button3) {
                    [alert addButtonWithTitle:[NSString stringWithUTF8String:button3]];
                }
                NSInteger result = [alert runModal];
                return result - 1000;
        #elif _GRAPHICS_PLATFORM_WIN32
                // Windows-specific code here
                UINT num = 0;
                if (strcmp(defaultButton, "OK") == 0) {
                    num = MB_OK;
                }
                MessageBoxA((HWND)NULL, (LPCTSTR)text, (LPCTSTR)textWithFormat, (UINT)num);
                // You might need to return a value here, depending on your requirements
                return -1;  // Adjust the return value for Windows
        #endif
    }
}

extern "C" void *drawHTML(struct Application application, char* html){
    ;
    #ifdef _GRAPHICS_PLATFORM_UNIX
        NSString *htmlString = [NSString stringWithUTF8String:html];
    if (htmlString) {
        NSTextView *textView = [[NSTextView alloc] initWithFrame:[application.window.contentView bounds]];
        [textView setEditable:NO];

        NSAttributedString *attributedText = [[NSAttributedString alloc] initWithHTML:[htmlString dataUsingEncoding:NSUTF8StringEncoding]
                                                                            documentAttributes:NULL];
        if (attributedText) {
            [[textView textStorage] setAttributedString:attributedText];
            [application.window.contentView addSubview:textView];
            return (void*)textView;
        } else {
            NSLog(@"Error: Failed to create attributed text from HTML.");
        }
    } else {
        NSLog(@"Error: Failed to convert HTML to NSString.");
    }
    return NULL;
    #elif _GRAPHICS_PLATFORM_WIN32
    // To add later
    #endif
}



extern "C" void *openFile(){

    #ifdef _GRAPHICS_PLATFORM_UNIX
        NSOpenPanel *openPanel = [NSOpenPanel openPanel];
            [openPanel setCanChooseFiles:1];
            [openPanel setCanChooseDirectories:0];
            if ([openPanel runModal] == NSModalResponseOK) {
                NSURL *selectedFileURL = [openPanel URL];
                return (void*)selectedFileURL;
            }
    #elif _GRAPHICS_PLATFORM_WIN32
    OPENFILENAME ofn;
    char szFileName[500] = {0};
    ZeroMemory(&ofn, sizeof(ofn));
    ofn.lStructSize = sizeof(ofn);
    ofn.hwndOwner = 0;
    ofn.lpstrFilter = "All Files\0*.*\0";
    ofn.lpstrFile = szFileName;
    ofn.nMaxFile = 500;
    ofn.Flags = OFN_EXPLORER | OFN_FILEMUSTEXIST | OFN_HIDEREADONLY;
    if (GetOpenFileName(&ofn) == TRUE){
        MessageBox(NULL, ofn.lpstrFile, "File Name", MB_OK);
    }else {
        MessageBox(NULL, TEXT("Open File Dialog Error"), TEXT("There has been an error"), MB_OK);
    };
    return szFileName;
    #endif
}
extern "C" void *saveFile(char* fileName, char* dataToWrite){
    #ifdef _GRAPHICS_PLATFORM_UNIX
            NSString *fileNameString = [NSString stringWithUTF8String:fileName];
            NSString *dataToWriteString = [NSString stringWithUTF8String:dataToWrite];
            NSSavePanel *savePanel = [NSSavePanel savePanel];
            [savePanel setNameFieldStringValue:fileNameString]; // Set the default file name
            if ([savePanel runModal] == NSModalResponseOK) {
                NSURL *saveURL = [savePanel URL];
                NSError *error = nil;
                [dataToWriteString writeToURL:saveURL atomically:1 encoding:NSUTF8StringEncoding error:&error];
                
                if (error) {
                    NSLog(@"Error saving file: %@", error.localizedDescription);
                    return (void*)-1;
                } else {
                    NSLog(@"Saved to file: %@", saveURL.path);
                    return (void*)0;
                }
            }
    #elif _GRAPHICS_PLATFORM_WIN32
    // TODO
    #endif
}

extern "C" void *convertWindowToWidget(struct Application window){
    return window.window;
};

extern "C" void *drawImage(const char *imageName, float x, float y, float width, float height, bool editable = 0, bool bordered = 0) {
    
    assert(width > 0);
    assert(height > 0);
    #ifdef _GRAPHICS_PLATFORM_UNIX
        // Construct the full image file path
        NSString *imagePath = [NSString stringWithUTF8String:imageName];
        
        // Load the image using NSData
        NSData *imageData = [NSData dataWithContentsOfFile:imagePath];

        if (imageData) {
            NSImage *image = [[NSImage alloc] initWithData:imageData];
            
            // Calculate the aspect-ratio-preserving size that fits within the specified width and height
            NSSize imageSize = [image size];
            NSSize scaledSize = NSMakeSize(width, height);
            if (imageSize.width > imageSize.height) {
                scaledSize.height = (height / width) * imageSize.width;
            } else {
                scaledSize.width = (width / height) * imageSize.height;
            }

            // Calculate the position to center the image
            NSRect frameRect = NSMakeRect(x, y, scaledSize.width, scaledSize.height);
            frameRect.origin.x += (width - scaledSize.width) / 2;
            frameRect.origin.y += (height - scaledSize.height) / 2;

            // Create an NSImageView for the image with the calculated frame
            NSImageView *imageView = [[NSImageView alloc] initWithFrame:frameRect];
            [imageView setImage:image];
            [imageView setImageScaling:NSImageScaleProportionallyUpOrDown];
            [[imageView cell] setImageScaling:NSImageScaleProportionallyUpOrDown];
            [imageView setImageAlignment:NSImageAlignCenter];
            
            // Set other properties as needed
            [imageView setEditable:editable];

            // Check if bordered is set to true and set a border if needed
            if (bordered) {
                [imageView setWantsLayer:1];
                [imageView setLayerContentsRedrawPolicy:NSViewLayerContentsRedrawOnSetNeedsDisplay];
                [[imageView layer] setBorderColor:[NSColor blackColor].CGColor];
                [[imageView layer] setBorderWidth:1.0];
            }

            return (void *)CFBridgingRetain(imageView); // Return the NSImageView
        } else {
            NSLog(@"Failed to load image data from path: %@", imagePath);
        }

        return nullptr; // Handle the error case gracefully
    #elif _GRAPHICS_PLATFORM_WIN32

    // TODO
    #endif
}


extern "C" void *setEditable(void *object, bool editable){
    assert(object);
    #ifdef _GRAPHICS_PLATFORM_UNIX
        assert([(__bridge id)object isKindOfClass:[NSView class]]);
        [(NSView*) object setEditable:editable];
    #elif _GRAPHICS_PLATFORM_WIN32
    #endif
};

extern "C" void *setBordered(void *object, bool bordered){
    assert(object);
    #ifdef _GRAPHICS_PLATFORM_UNIX
        assert([(__bridge id)object isKindOfClass:[NSView class]]);
        [(NSView*) object setBordered:bordered];
    #elif _GRAPHICS_PLATFORM_WIN32
    #endif
};

extern "C" void *setWantsLayer(void *object, bool wantsLayer){
    assert(object);
    #ifdef _GRAPHICS_PLATFORM_UNIX
        assert([(__bridge id)object isKindOfClass:[NSView class]]);
        [(NSView*) object setWantsLayer:YES];
    #elif _GRAPHICS_PLATFORM_WIN32
    #endif
};

extern "C" void *add(Application window, void *object){
    assert(object);
    
    #ifdef _GRAPHICS_PLATFORM_UNIX
        assert([(__bridge id)object isKindOfClass:[NSView class]]);
        [[window.window contentView] addSubview:(NSView*)object];
        return object;
    #elif _GRAPHICS_PLATFORM_WIN32
    HWND hwnd;
    if (((int)window.toCreate[0]) == 10){ // CreateWindow
        hwnd = CreateWindow((LPCSTR)window.toCreate[1], (LPCSTR)window.toCreate[2], (DWORD)window.toCreate[3], (int)window.toCreate[4], (int)window.toCreate[5], (int)window.toCreate[6], (int)window.toCreate[7], (HWND)window.hwnd, (HMENU)window.toCreate[8], (HINSTANCE)window.wc.hInstance, (LPVOID)window.toCreate[9]);
    }else if ((int)(application.toCreate[0]) == 11){ // CreateWindowEx
     
        hwnd = CreateWindowEx((DWORD)window.toCreate[1], (LPCSTR)window.toCreate[2], (LPCSTR)window.toCreate[3], (DWORD)window.toCreate[4], (int)window.toCreate[5], (int)window.toCreate[6], (int)window.toCreate[7], (int)window.toCreate[8], (HWND)window.hwnd, (HMENU)window.toCreate[9], (HINSTANCE)window.wc.hInstance, (LPVOID)window.toCreate[10]);
    };
    return hwnd;
    #endif
}

extern "C" void removeItem(void *object){
    assert(object);
    #ifdef _GRAPHICS_PLATFORM_UNIX
        assert([(__bridge id)object isKindOfClass:[NSView class]]);
        [(NSView*)object removeFromSuperview];
        free(object);
    #elif _GRAPHICS_PLATFORM_WIN32
    #endif
}

@interface CircleView : NSView

@property (nonatomic, copy) void (^__Draw)();
@property (nonatomic) CGFloat currentCircleX;
@property (nonatomic) CGFloat currentCircleY;
@property (nonatomic) CGFloat currentCircleWidth;
@property (nonatomic) CGFloat currentCircleHeight;

@end

@implementation CircleView

- (void)drawRect:(NSRect)dirtyRect {
    self.__Draw();
}

@end

extern "C" void *drawCircle(struct Application window, float x, float y, float width, float height){
    NSRect frame = NSMakeRect(0, 0, 400, 400);
    CircleView *customView = [[CircleView alloc] initWithFrame:frame];
    customView.currentCircleX = 0;
    customView.currentCircleY = 0;
    customView.currentCircleHeight = 40.0;
    customView.currentCircleWidth = 40.0;
    customView.__Draw = ^(){
        NSBezierPath *circlePath = [NSBezierPath bezierPath];
        NSRect circleFrame = NSMakeRect(customView.currentCircleX, customView.currentCircleY, customView.currentCircleWidth, customView.currentCircleHeight);
        [circlePath appendBezierPathWithOvalInRect:circleFrame];
        [[NSColor redColor] setFill];
        [circlePath fill];
    };
    [window.window.contentView addSubview:customView];
    return customView;
};

extern "C" void *setFrame(CircleView *object, float x, float y, float width, float height){
    NSRect circleFrame = NSMakeRect(x, y, width, height);
    [object setNeedsDisplay:YES];
    [object setFrame:circleFrame];
    [object setNeedsDisplay:YES];
    // object.__Draw();
};

extern "C" int getX(CircleView *object){
    return object.frame.origin.x;
}

extern "C" int getY(CircleView *object){
    return object.frame.origin.y;
}

extern "C" int getWidth(CircleView *object){
    return object.frame.size.width / 8.0;
}

extern "C" int getHeight(CircleView *object){
    return object.frame.size.height / 8.0;
}


extern "C" void setKeyDownEvent(struct Application application, int (*handleKeyEvent)(struct Application *window, KeyEvent event)){
    pthread_kill(__PUBLIC__KEYTHREAD, 0);
    __KeyHandle = handleKeyEvent;
    pthread_create(&__PUBLIC__KEYTHREAD, NULL, __UpdateHigher, &application); 
};

enum MouseType{
    MouseLeft,
    MouseRight
};

struct MouseEvent{
    int mouseX;
    int mouseY;
    int buttonType;
};


extern "C" void setMouseDownEvent(struct Application application, void (*handleMouseEvent)(struct Application window, struct MouseEvent event)){
    MouseStuff* mouseStuff;
    mouseStuff = [ [MouseStuff alloc] initWithFrame:[application.window frame]];
    [mouseStuff setFrame:[application.window.contentView frame]];
    mouseStuff.mouseDown = ^(NSEvent *event){
        NSPoint point = [event locationInWindow];
        struct MouseEvent mouseEvent;
        mouseEvent.mouseX = point.x;
        mouseEvent.mouseY = point.y;
        mouseEvent.buttonType = NSEvent.pressedMouseButtons-1;
        handleMouseEvent(application, mouseEvent);
    };
    [application.window.contentView addSubview:mouseStuff];

};


extern "C" void *setOnClickEvent(struct Application application, NSView *object, void (*handleMouseEvent)(struct Application window, NSView *object, struct MouseEvent event)){
    MouseStuff* mouseStuff;
    mouseStuff = [ [MouseStuff alloc] initWithFrame:[object frame]];
    [mouseStuff setFrame:[object frame]];
    mouseStuff.mouseDown = ^(NSEvent *event){
        NSPoint point = [event locationInWindow];
        struct MouseEvent mouseEvent;
        mouseEvent.mouseX = point.x;
        mouseEvent.mouseY = point.y;
        mouseEvent.buttonType = NSEvent.pressedMouseButtons-1;
        handleMouseEvent(application, object, mouseEvent);
    };
    [application.window.contentView addSubview:mouseStuff];
    return object;

};

extern "C" void setMouseUpEvent(struct Application application, void (*handleMouseEvent)(struct Application window, struct MouseEvent event)){
    MouseStuff* mouseStuff;
    mouseStuff = [ [MouseStuff alloc] initWithFrame:[application.window frame]];
    [mouseStuff setFrame:[application.window.contentView frame]];
    mouseStuff.mouseUp = ^(NSEvent *event){
        NSPoint point = [event locationInWindow];
        struct MouseEvent mouseEvent;
        mouseEvent.mouseX = point.x;
        mouseEvent.mouseY = point.y;
        mouseEvent.buttonType = NSEvent.pressedMouseButtons-1;
        handleMouseEvent(application, mouseEvent);
    };
    [application.window.contentView addSubview:mouseStuff];
}

extern "C" void setMouseDraggedEvent(struct Application application, void (*handleMouseEvent)(struct Application window, struct MouseEvent event)){
    MouseStuff* mouseStuff;
    mouseStuff = [ [MouseStuff alloc] initWithFrame:[application.window frame]];
    [mouseStuff setFrame:[application.window.contentView frame]];
    mouseStuff.mouseDragged = ^(NSEvent *event){
        NSPoint point = [event locationInWindow];
        struct MouseEvent mouseEvent;
        mouseEvent.mouseX = point.x;
        mouseEvent.mouseY = point.y;
        mouseEvent.buttonType = NSEvent.pressedMouseButtons-1;
        handleMouseEvent(application, mouseEvent);
    };
    [application.window.contentView addSubview:mouseStuff];
}
extern "C" void setMouseMovedEvent(struct Application application, void (*handleMouseEvent)(struct Application window, struct MouseEvent event)){
    MouseStuff* mouseStuff;
    mouseStuff = [ [MouseStuff alloc] initWithFrame:[application.window frame]];
    [mouseStuff setFrame:[application.window.contentView frame]];
    mouseStuff.mouseMoved = ^(NSEvent *event){
        NSPoint point = [event locationInWindow];
        struct MouseEvent mouseEvent;
        mouseEvent.mouseX = point.x;
        mouseEvent.mouseY = point.y;
        mouseEvent.buttonType = NSEvent.pressedMouseButtons-1;
        handleMouseEvent(application, mouseEvent);
    };
    [application.window.contentView addSubview:mouseStuff];
}
extern "C" void *setMouseObjectMovedEvent(struct Application application, NSView *object, void (*handleMouseEvent)(struct Application window, NSView *object, struct MouseEvent event)){
    MouseStuff* mouseStuff;
    mouseStuff = [ [MouseStuff alloc] initWithFrame:[application.window frame]];
    [mouseStuff setFrame:[object frame]];
    mouseStuff.mouseMoved = ^(NSEvent *event){
        NSPoint point = [event locationInWindow];
        struct MouseEvent mouseEvent;
        mouseEvent.mouseX = point.x;
        mouseEvent.mouseY = point.y;
        mouseEvent.buttonType = NSEvent.pressedMouseButtons-1;
        handleMouseEvent(application, object, mouseEvent);
    };
    [application.window.contentView addSubview:mouseStuff];
    return object;
}

extern "C" void setMouseExitedEvent(struct Application application, void (*handleMouseEvent)(struct Application window, struct MouseEvent event)){
    MouseStuff* mouseStuff;
    mouseStuff = [ [MouseStuff alloc] initWithFrame:[application.window frame]];
    [mouseStuff setFrame:[application.window.contentView frame]];
    mouseStuff.mouseExited = ^(NSEvent *event){
        NSPoint point = [event locationInWindow];
        struct MouseEvent mouseEvent;
        mouseEvent.mouseX = point.x;
        mouseEvent.mouseY = point.y;
        mouseEvent.buttonType = NSEvent.pressedMouseButtons-1;
        handleMouseEvent(application, mouseEvent);
    };
    [application.window.contentView addSubview:mouseStuff];
}

extern "C" void setMouseEnteredEvent(struct Application application, void (*handleMouseEvent)(struct Application window, struct MouseEvent event)){
    MouseStuff* mouseStuff;
    mouseStuff = [ [MouseStuff alloc] initWithFrame:[application.window frame]];
    [mouseStuff setFrame:[application.window.contentView frame]];
    mouseStuff.mouseEntered = ^(NSEvent *event){
        NSPoint point = [event locationInWindow];
        struct MouseEvent mouseEvent;
        mouseEvent.mouseX = point.x;
        mouseEvent.mouseY = point.y;
        mouseEvent.buttonType = NSEvent.pressedMouseButtons-1;
        handleMouseEvent(application, mouseEvent);
    };
    [application.window.contentView addSubview:mouseStuff];
}




extern "C" void *setOnClick(struct Application application, void *object, void (*buttonClicked)(struct Application, void*)) {

    void (^middleMan)(id, SEL, id) = ^(id self, SEL _cmd, id sender) {
        NSValue* value = objc_getAssociatedObject(sender, "application");
        struct Application additionalElement;
        [value getValue:&additionalElement];
        void *customObject = (void*)objc_getAssociatedObject(sender, "object");

        buttonClicked(additionalElement, customObject);
    };
    // void (^middleManCopy)(id, SEL, id) = [middleMan copy];
    id buttonDelegate = [[NSObject alloc] init];
    class_addMethod([buttonDelegate class], @selector(middleMan:), imp_implementationWithBlock(middleMan), "v@:@");
    [(__bridge id)object setTarget:buttonDelegate];
    if (object != nil && [object isKindOfClass:[NSView class]]) {
        [(NSView *)object setAction:@selector(middleMan:)];
    } else {
        NSLog(@"Object is nil or not an instance of NSView");
    }
    // [middleManCopy release];
    NSValue *value = [NSValue value:&application withObjCType:@encode(struct Application)];
    objc_setAssociatedObject((__bridge id)object, "application", value, OBJC_ASSOCIATION_RETAIN);
    objc_setAssociatedObject((__bridge id)object, "object", (__bridge id)object, OBJC_ASSOCIATION_RETAIN);
    return object;
}





extern "C" void *drawRectangle(struct Application application, float x, float y, float width, float height){
    ;
    
    assert(width > 0);
    assert(height > 0);
    
    void *object = drawLabel(application, x, y, width, height, "");
    add(application, object);
    return object;
};


extern "C" void *drawPixel(struct Application application, int x, int y){
    ;
    
    return drawRectangle(application, x, y, 1, 1);
};

extern "C" void *textColorRGB(void *object, int r, int g, int b){
    assert(object);
    r = squash(r, 0, 255);
    g = squash(g, 0, 255);
    b = squash(b, 0, 255);
    #ifdef _GRAPHICS_PLATFORM_UNIX
        assert([(__bridge id)object isKindOfClass:[NSView class]]);
        if ([(__bridge id)object isKindOfClass:[NSView class]]){
            [(NSView*)object setTextColor:[NSColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0]];
        }
    #elif _GRAPHICS_PLATFORM_WIN32
    #endif
}
extern "C" void *textColorRGBA(void *object, int r, int g, int b, float a){
    assert(object);
    r = squash(r, 0, 255);
    g = squash(g, 0, 255);
    b = squash(b, 0, 255);
    a = squashFloat(a, 0.0, 1.0);
    #ifdef _GRAPHICS_PLATFORM_UNIX
        assert([(__bridge id)object isKindOfClass:[NSView class]]);
        if ([(__bridge id)object isKindOfClass:[NSView class]]){
            [(NSView*)object setTextColor:[NSColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]];
        }
    #elif _GRAPHICS_PLATFORM_WIN32
    #endif
}



extern "C" void *backgroundColorRGB(void *object, int r, int g, int b){
    assert(object);
    r = squash(r, 0, 255);
    g = squash(g, 0, 255);
    b = squash(b, 0, 255);
    #ifdef _GRAPHICS_PLATFORM_UNIX
        bool isALayer = strcmp(class_getName(object_getClass((__bridge id)object)), "NSTextLayer")==0||strcmp(class_getName(object_getClass((__bridge id)object)), "NSShapeLayer")==0||strcmp(class_getName(object_getClass((__bridge id)object)), "NSGradientLayer")==0||strcmp(class_getName(object_getClass((__bridge id)object)), "NSTransformLayer")==0||strcmp(class_getName(object_getClass((__bridge id)object)), "NSEmitterLayer")==0||strcmp(class_getName(object_getClass((__bridge id)object)), "NSReplicatorLayer")==0||strcmp(class_getName(object_getClass((__bridge id)object)), "NSEAGLLayer")==0||strcmp(class_getName(object_getClass((__bridge id)object)), "AvPlayerLayer")==0;
        assert([(__bridge id)object isKindOfClass:[NSView class]] | isALayer || [(__bridge id)object isKindOfClass:[NSWindow class]]);
        if ([(__bridge id)object isKindOfClass:[NSView class]]){
            NSView *view = (NSView*)object;
            [view setBackgroundColor:[NSColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0]];
        }else if([(__bridge id)object isKindOfClass:[NSWindow class]]){
            NSWindow *window = (NSWindow*)object;
            window.backgroundColor = [NSColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0];
        }else{
            [(CALayer*)object setBackgroundColor:[NSColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0].CGColor];
        }
        return object;
    #elif _GRAPHICS_PLATFORM_WIN32
    #endif
}

extern "C" void *backgroundColorRGBA(void *object, int r, int g, int b, float a){
    assert(object);
    r = squash(r, 0, 255);
    g = squash(g, 0, 255);
    b = squash(b, 0, 255);
    a = squashFloat(a, 0.0, 1.0);
    #ifdef _GRAPHICS_PLATFORM_UNIX
        bool isALayer = strcmp(class_getName(object_getClass((__bridge id)object)), "NSTextLayer")==0||strcmp(class_getName(object_getClass((__bridge id)object)), "NSShapeLayer")==0||strcmp(class_getName(object_getClass((__bridge id)object)), "NSGradientLayer")==0||strcmp(class_getName(object_getClass((__bridge id)object)), "NSTransformLayer")==0||strcmp(class_getName(object_getClass((__bridge id)object)), "NSEmitterLayer")==0||strcmp(class_getName(object_getClass((__bridge id)object)), "NSReplicatorLayer")==0||strcmp(class_getName(object_getClass((__bridge id)object)), "NSEAGLLayer")==0||strcmp(class_getName(object_getClass((__bridge id)object)), "AvPlayerLayer")==0;
        assert([(__bridge id)object isKindOfClass:[NSView class]] | isALayer || [(__bridge id)object isKindOfClass:[NSWindow class]]);
        if ([(__bridge id)object isKindOfClass:[NSView class]]){
            NSView *view = (NSView*)object;
            [view setBackgroundColor:[NSColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]];
        }else if([(__bridge id)object isKindOfClass:[NSWindow class]]){
            NSWindow *window = (NSWindow*)object;
            window.backgroundColor = [NSColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a];
        }else{
            [(CALayer*)object setBackgroundColor:[NSColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a].CGColor];
        }
    #elif _GRAPHICS_PLATFORM_WIN32
    #endif
}

extern "C" double getSliderValue(void *object){
    assert(object);
    #ifdef _GRAPHICS_PLATFORM_UNIX
        assert([(__bridge id)object isKindOfClass:[NSSlider class]]);
        return [object doubleValue];
    #elif _GRAPHICS_PLATFORM_WIN32
    #endif
};

extern "C" int getWindowHeight(struct Application window){
        CGFloat windowHeight = NSHeight(((NSWindow*)window.window).frame);
        return windowHeight;
}

extern "C" int getWindowWidth(struct Application window){
        CGFloat windowWidth = NSWidth(((NSWindow*)window.window).frame);
        return windowWidth;
}


extern "C" void focusOn(struct Application window, NSView *object){
    #ifdef _GRAPHICS_PLATFORM_UNIX
        assert([(__bridge id)object isKindOfClass:[NSView class]]);
        [object mouseDown:[window.application currentEvent]];
        [window.window makeFirstResponder:(NSView*)object];
    #elif _GRAPHICS_PLATFORM_WIN32

    #endif
};

extern "C" void *clearWindow(struct Application window){
    #ifdef _GRAPHICS_PLATFORM_UNIX
        [[window.window contentView] setSubviews:@[]];
    #elif _GRAPHICS_PLATFORM_WIN32
    #endif
};

// Copyright Unknown People Inc.
