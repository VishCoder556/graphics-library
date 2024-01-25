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