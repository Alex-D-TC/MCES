enum state {
    SCANNING = 0,
    TRAPPED = 1,
};

struct system_tracker {
    state st;
    void (*scanning_func)(system_tracker*);
    void (*trapped_func)(system_tracker*);
};

system_tracker tracker_init(void (*scanning_func)(system_tracker*), void (*trapped_func)(system_tracker*)) {

    system_tracker syst;
    syst.st = SCANNING;
    syst.scanning_func = scanning_func;
    syst.trapped_func = trapped_func;

    return syst;
}

void system_loop(system_tracker* syst) {
    switch (syst->st) {
        case SCANNING:
            syst->scanning_func(syst);
        break;
        case TRAPPED:
            syst->trapped_func(syst);
        break;
    }
}

void scanning_handler(system_tracker* st) {
    // Read data from the IR sensor
    // If something is 'caught', switch to TRAPPED state
}

void trapped_handler(system_tracker* st) {
    // Send signal to alarm to make it sing
    // Await for the button press to reset the alarm and go to the SCANNING state
}

// Move the code from the main function to the main function of the embedded system c file
int main() {
    
    system_tracker syst = tracker_init(scanning_handler, trapped_handler);
    system_loop(&syst);

}
