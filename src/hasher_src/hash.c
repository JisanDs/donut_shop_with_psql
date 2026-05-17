#include <ctype.h>
#include <stdio.h>
#include <string.h>

// this array give value depending index number
int VALUES[] = {1, 3, 3, 2, 1, 4, 2, 4, 1, 8, 5, 1, 3, 1, 1, 3, 10, 1, 1, 1, 1, 4, 4, 8, 4, 10};

int make_hased(char *pass)
{
    int hased_value = 0;

    for (int i = 0, n = strlen(pass); i < n; i++) {
        if (isupper(*(pass + i))) {
            hased_value += *(VALUES + *(pass + i) - 'A'); // if char upper subtract with upper char
        } else if (islower(*(pass + i))) {
            hased_value += *(VALUES + *(pass + i) - 'a'); // if char lower subtract with lower char
        } else {
            hased_value += (int)*(pass + i);  // else extract ascii value and add the number
        }
    }

    return hased_value;
}
