/*graphics.h - 2D and 3D graphics library

Use of graphics:
    #include "graphics.h"
    (-framework Cocoa)

What's defined:
    An Application structure
    An event structure
    Event handling

    createWindow function:
        To use the createWindow function, call it with no arguments.
            createWindow()
        It creates a new window and returns the Application.
    

    initializeWindowLoop function:
        The function can be used by passing in its application.
            initializeWindowLoop(window)
        It begins the window loop
    

    drawLabel function:
        It draws a label using the window, x, y, width, height, text, and whether it is bezeled or drawsBackground.
            drawLabel(window, 50, 40, 40, 40, "Hi", false)
        
    
    drawButton function:
        The drawButton function takes in the window, text, x, y, width, and height
            drawButton(window, "Hi", 50, 40, 40, 40)
    
    
    drawSlider function:
        The drawSlider function needs the x, y, width, height, the minimum value, maximum value and default value
            drawSlider(50, 40, 40, 40, 30.0, 80.0, 64.5)
        It draws a slider.
    
    
    drawTextField function:
        To use it, you have to pass in the window, x, y, width, height, and text.
            drawTextField(window, 50, 40, 40, 40, "Hi", "Text")
    
    
    drawTextView function:
        To use the function, pass in the window, x, y, width, height, and text
            drawTextView(window, 50, 40, 40, 40, "Hi")
    
    
    drawProgressIndicator function: 
        It uses x, y, width, height, minValue, maxValue, defaultValue
            drawProgressIndicator(50, 40, 40, 40, 30.0, 80.0, 64.5)
    
    
    setDoubleValue function:
        Sets the double value of an item. Takes in the object and the double value
            setDoubleValue(drawTextView(....), 50.0)
    
    
    drawColorPicker function:
        Draws a color picker using the x, y, width, height, and whether the alpha is included.
            drawColorPicker(50, 40, 40, 40, false)
    
    
    drawDatePicker function:
        Draws a date picker using the x, y, width, and height.
        drawDatePicker(50, 40, 40, 40)
    
    
    drawAlert function:
        Draws an alert using the x, y, width, height, the text, the defaultButton, and the textWithFormat
            drawAlert( "Alert!", "OK", "There has been an alert")
        
    drawAlertWithButtons:
        Draws an alert with more than one button with the x, y, width, height, the text 
            drawAlertWithButtons("Boo!", "You caught me", "You did not catch me", "I do not accept your rules")
    
    
    drawHTML function:
        Takes the window and the html that is to be stored.
            drawHTML(window, "<h1>Hi</h1>")
        Draws HTML into the window. Should work successfully.
    
    
    openFile function:
        Opens a widget to open a file.
            openFile()
    
    
    saveFile function:
        Takes in the file to write into and the data to write.
            saveFile("data.txt", "Text written")
    
    
    drawImage function:
        Draws an image using the image name, x, y, width, and height, but also optional stuff.
            drawImage("image.jpeg", 50, 40, 40, 40)
            ━━━━ OPTIONAL ARGUMENTS: editable, bordered ━━━
    
    
    add function:
        Draws an item to the window using the window and object.
            add(window,  object)
    
    
    textColorRGB function:
        Changes the RGB text color of text.
            textColorRGB(object, 50, 90, 90)
    
    
    textColorRGBA function:
        Version of the textColorRGB function but takes in alpha
            textColorRGBA(object, 50, 90, 90, 20)
    
    
    backgroundColorRGB function:
        Changes the RGB background color of an object
            backgroundColorRGB(object, 50, 90, 90)
    
    
    backgroundColorRGBA function:
        Changes the RGBA background color of an object
            backgroundColorRGBA(object, 50, 90, 90, 20)
    
    
    setString function:
        Sets the string that is held
            setString(object, "Greetings")
    
    getString function:
        Gets the string that is held inside of a button, text view, text field, or label.
            getString(object)
    
    addString function:
        Adds string that is held inside of button, text view, text field, or label
            addString(object, "Appended");
    
    setContinous function:
        Sets whether an object should be continous.
            setContinous(object, true)
    
    
    setBezeled function:
        Sets if an object is bezeled.
            setBezeled(object, true)
    
    
    setDrawsBackground function:
        Sets whether an object can draw a background or not.
            setDrawsBackground(object, true)
    
    
    setEditable function:
        Sets whether an object is editable or not.
            setEditable(object, true)
    
    
    setBordered function:
        Sets whether an object is bordered or not.
            setBordered(object, true)
    
    
    setWantsLayer function:
        States whether an object can have its own layer.
            setWantsLayer(object, true)
    
    
    getSliderObject function:
        Gets the value of a slider, returning an integer.
            getSliderObject(object)
    
    drawDropDown function:
        Draws a drop down widget with the x, y, width, and height.
            drawDropDown(50, 40, 40, 40)
    
    addDropDownItem function:
        Adds an item to a drop-down widget (an selection option).
            addDropDownItem(object, "Toyota")
    
    getWindowLayer function:
        Gets the layer of the window.
            getLayer(window)

    getWindowLayer function:
        Gets the layer of an object (if wantsLayer = true).
            getLayer(object)

    
    convertWindowToWidget function:
        Converts a window into a widget (so you can change text / background RGB / RGBA)
            convertWindowToWidget(window)


    setOnClick function:
        Sets onClick event with the object and the function
            setOnClick(object, buttonClickedFunction)
    

    setKeyDownEvent function:
        Sets keyDown function with the object and function
            setKeyDownEvent(object, keyDownFunction)
    
    setMouseDownEvent function:
        Sets mouseDown function with the object and function
            setMouseDownEvent(object, mouseDownFunction)
    
    setMouseUpEvent function:
        Sets mouseUp function with the object and function
            setMouseUpEvent(object, mouseUpFunction)
    
    setMouseDraggedEvent function:
        Sets mouseDragged function with the object and function
            setMouseDraggedEvent(object, mouseDraggedFunction)
        
    setMouseDraggedEvent function:
        Sets mouseDragged function with the object and function
            setMouseDraggedEvent(object, mouseDraggedFunction)
    
    setMouseMovedEvent function:
        Sets mouseMoved function with the object and function
            setMouseMovedEvent(object, mouseMovedFunction)
    
    setMouseExitedEvent function:
        Sets mouseExited function with the object and function
            setMouseExitedEvent(object, mouseExitedFunction)
    
    setMouseEnteredEvent function:
        Sets mouseEntered function with the object and function
            setMouseEnteredEvent(object, mouseEnteredFunction)

    drawRectangle function:
        Draws a rectangle with window,  x, y, width, height (use backgroundColorRGB / backgroundColorRGBA to change color).
            drawRectangle(window, 50, 40, 40, 40)
    
    drawPixel function:
        Draws a pixel using window, x, y
            drawPixel(window, 50, 40)

    drawCircle function:
        Draws a circle.
            drawCircle(window, 50, 40, 40, 40)
    
    removeItem function:
        Removes an item
            removeItem(object)
    
    getWindowHeight function:
        Gets the height of window
            getWindowHeight(window)
    
    getWindowWidth function:
        Gets the width of window
            getWindowWidth(window)

    getX function:
        Gets the x position of an object.
            getX(object)
    
    getY function:
        Gets the y position of an object.
            getY(object)
    
    getWidth function:
        Gets the width of an object.
            getWidth(object)
    
    getHeight function:
        Gets the height of an object.

    setFrame function:
        Sets the frame of an object
            setFrame(object, 0.5, 0.5, 90.0, 90.0)
    
    focusOn function:
        Focuses on a widget inside of a window
            focusOn(window, object)
    
    setFont function:
        Sets the font.
            setFont(object, "Helvetica", 16.0);
    
    
    createSceneView function:
        Creates scene view with the application, transparent
            createSceneView(window, true)
    
    createScene function:
        Creates scene with the application
            createScene(window)
    
    addSceneToSceneView function:
        Adds scene to scene view with the window, sceneView, and scene.
            addSceneToSceneView(window, sceneView, scene)
    
    color3D function:
        Changes color of 3D object with object, red, green, blue, (optional alpha)
            color3D(cube, 255, 0, 0);
            ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                   OR
            ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
            color3D(cube, 255, 0, 0, 0.5);
    
    getNodeFromScene function:
        Converts a scene into a node
            getNodeFromScene(scene)
    
    addSphere function:
        Draws a sphere using the scene and the radius.
            addSphere(scene, 0.8)
    
    addTorus function:
        Draws a torus using the scene, ring radius, and pipeRadius.
            addTorus(scene, 0.3, 0.9)
    
    addCylinder function:
        Draws a cylinder using the scene, radius, and height.
            addCylinder(scene, 0.5, 5.0)
    
    addCone function:
        Draws a cone using the scene, topRadius, bottomRadius, and height
            addCone(scene, 1.0, 5.0, 7.0)
    
    addCube function:
        Draws a cube using its width, height, length, and chamferRadius:
            addCube(scene, 5.0, 5.0, 5.0, 1.0)
    
    

    
    clearWindow function:
        Removes all elements from window
            clearWindow(window)

    
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        Current Graphics version: 1.0
    
    Advantages:
        PORTABLE (JUST USES TWO FILES)
        DOCUMENTED (LOTS OF DOCUMENTATION)
        WRITTEN IN C (FAST)
    
    Disadvantages:
        Uses a C file that uses an Objective C file
    
    Credits:
        OpenGL for inspiring me
        Tsoding Daily (Alexey Kutepov) for additional inspiration of making it advanced
        Javidx9 (One Lone Coder) also for additional inspiration of making it advanced
*/

#define GRAPHICS_VERSION 1.00
#define GRAPHICS_VERSION_MAJOR 1
#define GRAPHICS_VERSION_MINOR 0
#define GRAPHICS_VERSION_PATCH 0


#ifndef _GRAPHICS_H
#define _GRAPHICS_H


/*
Updated versions:
None


Usages:
    Draws a slider:
        #include "graphics.h"

        void Update(struct Application application){
            ;
        };

        int main(int argc, const char *argv[]) {
            Application window = createWindow("Hi");
            void *object = drawSlider(50.0, 50.0, 80.0, 80.0, 20.0, 100.0, 50.0);
            add(window, object);
            initializeWindowLoop(window);
            return 0;
        }
    Draws a drop-down list in which you can pick an item:
        #include "graphics.h"

        void Update(struct Application application){
            ;
        };

        int main(int argc, const char *argv[]) {
            Application window = createWindow("Your Favorite Car");
            void *object = drawDropDown(50, 100, 100, 24);
            addDropDownItem(object, "Toyota");
            addDropDownItem(object, "Testla");
            addDropDownItem(object, "Volkswagon");
            addDropDownItem(object, "Audi");
            addDropDownItem(object, "Mercedez-Benz");
            addDropDownItem(object, "Volvo");
            add(window, object);
            initializeWindowLoop(window);
            return 0;
        }
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    ╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    Draw a yellow rectangle:
        #include "graphics.h"
        #include "../inout.h"


        void Update(struct Application application){
            ;
        };

        int main(int argc, const char *argv[]) {
            Application window = createWindow("Color Window");
            backgroundColorRGB(drawRectangle(window, 50,50, 50, 50), 255, 255, 0);
            initializeWindowLoop(window);
            return 0;
        }

    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    ╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    Draw a rounded yellow cube:
        #include "graphics.h"

        void Update(struct Application* application){};



        int main(int argc, const char *argv[]) {
            Application window = createWindow("Hi");
            void *sceneView = createSceneView(window, true);
            void *scene = createScene(window);
            addNode(scene, color3D(addCube(scene, 5.0, 5.0, 5.0, 1.0), 255, 255, 0));
            addSceneToSceneView(window, sceneView, scene);
            add(window, sceneView);
            initializeWindowLoop(window);
            return 0;
        };
    
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    ╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    Create a simple login page:
        #include "graphics.h"
        void Update(struct Application* application){};
        void *firstName;
        void *lastName;
        void *resultLabel;
        void OnClick(struct Application window, void *object){
            char *firstNameString = getString(firstName);
            char *lastNameString = getString(lastName);
            if (firstNameString[0] == '\0'){
                setString(resultLabel, "Enter first name field\n");
                textColorRGB(resultLabel, 204, 2, 2);
            }else if (lastNameString[0] == '\0'){
                setString(resultLabel, "Enter last name field\n");
                textColorRGB(resultLabel, 204, 2, 2);
            }
            if (firstNameString[0] != '\0' && lastNameString[0] != '\0'){
                clearWindow(window);
                resultLabel = drawLabel(window, 0, getWindowHeight(window)-300, 400, 200, "");
                setString(resultLabel, "");
                add(window, resultLabel);
                addString(resultLabel, "Welcome, ");
                addString(resultLabel, firstNameString);
                addString(resultLabel, " ");
                addString(resultLabel, lastNameString);
                setFont(resultLabel, "Helvetica", 40.0);
                backgroundColorRGBA(resultLabel, 255, 255, 255, 0.0);
            }
        }
        int main(int argc, const char *argv[]) {
            Application window = createWindow("Hi");
            add(window, drawLabel(window, 10, 670, 80, 20, "First Name:"));
            add(window, drawLabel(window, 10, 600, 80, 20, "Last Name:"));
            firstName = drawTextField(window, 90, 670, 250, 20, "", "First Name");
            add(window, firstName);
            lastName = drawTextField(window, 90, 600, 250, 20, "", "Last Name");
            add(window, lastName);
            void *button = drawButton(window, "Submit", 100, 550, 100, 20);
            setOnClick(window, button, OnClick);
            add(window, button);
            resultLabel = drawLabel(window, 10, 200, 400, 200, "");
            add(window, resultLabel);
            initializeWindowLoop(window);
            return 0;
        };
    
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    ╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    Draw an alert:
        #include "graphics.h"
        #include "../inout.h"

        void Update(struct Application* application){};


        int main(int argc, const char *argv[]) {
            char buttons[5] = {"OK", "Cancel"};
            int btn = drawAlertWithButtons( "Boo!", "1", "2", "3", "There has been an alert");
            if (btn == 0){
                print_chars("1 was pressed");
            }else if(btn == 1){
                print_chars("2 was pressed");
            }else if(btn == 2){
                print_chars("3 was pressed");
            };
            return 0;
        };
    
*/

#include <stdbool.h>
#include <stdint.h>

// TODO: add documentary for create3DFromDae, addPyramid, addPlane, addCapsule, addTube, scale3D, move3D, addNode, setDefaultFont, setOnClickEvent, setMouseObjectMovedEvent

#pragma region platform_finder


    #define _GRAPHICS_PLATFORM_WIN32 0
    #define _GRAPHICS_PLATFORM_UNIX 0

    // Defines both modes off

    #ifdef _WIN32

        #undef __GRAPHICS_PLATFORM_WIN32
        #define _GRAPHICS_PLATFORM_WIN32 1

    #endif

    #ifdef TARGET_OS_MAC || __APPLE__ || __unix__

        #undef _GRAPHICS_PLATFORM_UNIX
        #define _GRAPHICS_PLATFORM_UNIX 1
    
    #endif


#pragma endregion





#pragma region application_struct
    // Define a struct to represent the Application
    typedef struct Application {
    #ifdef _GRAPHICS_PLATFORM_UNIX
        void *application;
        void *window;
    #elif _GRAPHICS_PLATFORM_WIN32
        void *hwnd;
        void *wc;
        void* toCreate[11];
        // An array of the arguments of argSize, (dxExStyle), lpClassName, lpWindowName, dwStyle, x, y, nWidth, nHeight, hMenu, lpParam;
    #endif
}Application;

enum KeyModifiers{
    None,
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


typedef struct KeyEvent{
    char character;
    int modifier;
    int nnc; // Non-numeric character
}KeyEvent;


struct MouseEvent{
    int mouseX;
    int mouseY;
    int buttonType;
};


enum MouseType{
    MouseLeft,
    MouseRight
};

#pragma endregion

#pragma region application_work
    // Creates a window
    Application createWindow(char* title, ...); // Optional x, y, width, height

    // Gets layer of application
    void *getWindowLayer(struct Application application);

    // Gets layer of object
    void *getLayer(void *object);

    // Convert a window into a widget
    void *convertWindowToWidget(struct Application application);
    
    // Starts window loop
    void initializeWindowLoop(Application application);
    
    // Adds an object
    void add(Application application, void *object);

    // Removes an object
    void removeItem(void *object);

    // Gets the window height
    int getWindowHeight(Application window);

    // Gets the window width
    int getWindowWidth(Application window);

    // Clears the window
    void *clearWindow(struct Application window);
#pragma endregion

#ifndef NO_TEXT
    #pragma region text
        // Draws a label
        void *drawLabel(Application application, float x, float y, float width, float height, const char *text, ...);
        
        // Draws a button
        void *drawButton(Application application, const char *text, int x, int y, int width, int height);
        
        // Draws a text field
        void *drawTextField(struct Application application, int x, int y, int width, int height, char* text, char *placeHolder);
        
        // Draw a text view
        void *drawTextView(Application application, int x, int y, int width, int height, char* text);
        
        // Draws HTML
        void *drawHTML( Application application, char* html); 
        
        // Sets a string
        void *setString(void *object, char* text); 

        // Adds a string
        void *addString(void *object, char *text);

        // Gets a string
        char *getString(void *object);

        // Sets the font
        void *setFont(void *object, ...); // (OPTIONAL fontName, fontSize)

        // Sets default font
        void setDefaultFont(int fontSize, char *fontName);
    #pragma endregion
#endif

#ifndef NO_DROPDOWN

    #pragma region dropdown

        void *drawDropDown(int x, int y, int width, int height);

        void *addDropDownItem(void *object, char* title);

    #pragma endregion

#endif

#ifndef NO_DRAW

    #pragma region draw

        void *drawRectangle(Application application, float x, float y, float width, float height);

        void *drawCircle(struct Application window, int x, int y, int width, int height);

        void *drawPixel(Application application, int x, int y);

    #pragma endregion

#endif

#ifndef NO_MINMAXDOUBLE

    #pragma region minMaxDouble
        // Draws a slider
        void *drawSlider(int x, int y, int width, int height, float minValue, float maxValue, float defaultValue);
        
        // Draw a progress indicator
        void *drawProgressIndicator(int x, int y, int width, int height, int minValue, int maxValue, int doubleValue);
        
        // Sets a double value
        void *setDoubleValue(void *object, float doubleValue);
        
        // Get the slider double value
        double getSliderValue(void *object);
    #pragma endregion
#endif

#ifndef NO_PICKERS
    #pragma region pickers
        // Draw color picker
        void *drawColorPicker(int x, int y, int width, int height, bool alphaIncluded);
        
        // Draw date picker
        void *drawDatePicker( int x, int y, int width, int height);
    #pragma endregion
#endif

#ifndef NO_POP_UP
    #pragma region pop-up
        // Opens a file
        void *openFile();
        
        // Saves a file
        void *saveFile(char* fileName, char* dataToWrite);
        
        // Draws an alert
        int drawAlert(char* text, char* defaultButton, char* textWithFormat);

        // Draws an alert with buttons.
        int drawAlertWithButtons(char* text, char* button1, char *button2, char* button3, char* textWithFormat);
    #pragma endregion
#endif

#ifndef NO_FRAME

    #pragma region frame
        void *setFrame(void *object, float x, float y, float width, float height);

        int getX(void *object);
        
        int getY(void *object);

        int getWidth(void *object);

        int getHeight(void *object);
    #pragma endregion

#endif

#ifndef NO_IMAGE
    #pragma region image
        // Draws an image
        void *drawImage(const char *imageName, float x, float y, float width, float height, ...);
    #pragma endregion
#endif

#ifndef NO_CLRBACK
    #pragma region clrBackground
        // Changes text color with RGB
        void *textColorRGB(void *object, int r, int g, int b);
        
        // Changes text color with RGBA
        void *textColorRGBA(void *object, int r, int g, int b, float a);
        
        // Changes background color with RGB
        void *backgroundColorRGB(void *object, int r, int g, int b);
        
        // Changes background color with RGBA
        void *backgroundColorRGBA(void *object, int r, int g, int b, float a);
    #pragma endregion
#endif

#ifndef _3D
    #pragma region ThreeD
        void *createSceneView(struct Application application, bool transparent);
        
        void *createScene(struct Application application);

        void addSceneToSceneView(struct Application application, void *sceneView, void *scene);

        void *addCube(void *scene, float width, float height, float length, float chamferRadius);

        void *color3D(void *geometry, int r, int g, int b, ...); // Optional alpha

        void *getNodeFromScene(void *scene);

        void *addSphere(void *scene, float radius);

        void *create3DFromDae(void *scene, char *text);

        void *addTorus(void *scene, float ringRadius, float pipeRadius);

        void *addCylinder(void *scene, float radius, float height);

        void *addCone(void *scene, float topRadius, float bottomRadius, float height);

        void *addPyramid(void *scene, float width, float height, float length);

        void *addPlane(void *scene, float width, float height);

        void *addCapsule(void *scene,  float capRadius, float height);

        void *addTube(void *scene, float innerRadius, float outerRadius, float height);
        
        void *scale3D(void *geometry, float width, float height, float thickness);
        
        void *move3D(void *geometry, int x, int y, int z);

        void *addNode(void *scene, void *node);
    #pragma endregion

#endif

#ifndef NO_EVENT
    #pragma region event
        void *setOnClick(Application application, void *object, void (*buttonClicked)(Application, void*));

        void setKeyDownEvent(struct Application application, int (*handleKeyEvent)(struct KeyEvent));
        
        void setMouseDownEvent(struct Application application, void (*handleMouseEvent)(struct Application window, struct MouseEvent event));

        void *setOnClickEvent(struct Application application, void *object, void (*handleMouseEvent)(struct Application window, void *object, struct MouseEvent event));
        
        void setMouseUpEvent(struct Application application, void (*handleMouseEvent)(struct Application window, struct MouseEvent event));

        void setMouseDraggedEvent(struct Application application, void (*handleMouseEvent)(struct Application window, struct MouseEvent event));

        void setMouseMovedEvent(struct Application application, void (*handleMouseEvent)(struct Application window, struct MouseEvent event));

        void *setMouseObjectMovedEvent(struct Application application, void *object, void (*handleMouseEvent)(struct Application window, void *object, struct MouseEvent event));

        void setMouseExitedEvent(struct Application application, void (*handleMouseEvent)(struct Application window, struct MouseEvent event));

        void setMouseEnteredEvent(struct Application application, void (*handleMouseEvent)(struct Application window, struct MouseEvent event));
    #pragma endregion
#endif

#ifndef NO_SETDATA
    #pragma region setData

    // Sets continous
    void *setContinous(void *object, bool shouldUse);
    
    // Sets bezeled
    void *setBezeled(void *object, bool bezeled); 
    
    // Sets drawBackground
    void *setDrawsBackground(void *object, bool drawsBackground);
    
    // Sets editable
    void *setEditable(void *object, bool editable); 
    
    // Sets bordered
    void *setBordered(void *object, bool bordered);
    
    // Sets wantsLayer
    void *setWantsLayer(void *object, bool wantsLayer);

    // Focuses on an object
    void focusOn(struct Application window, void *object);

    #pragma endregion
#endif

#endif
