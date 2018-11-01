
#define GATE_OPEN 0
#define GATE_CLOSED 1
#define OS_CLEAR 2
#define OS_BUSY 3

byte gateState;
bool debrisExists;

ltl p0 { !(gate_state == GATE_OPEN U gate_state == GATE_CLOSED) }

proctype RemoteController(chan In, Out) {

    printf("Started remote controller\n")

    byte signal;
 
    // Wait for signals from in
    In?signal;

    printf("RC: Signalling Gate Sensor to open / close the gate\n")

    // Forward the signal to the Gate Sensor 
    Out!signal;
}

proctype GateSensor(chan RCIn, OSIn, OSOut) {

    printf("Started gate sensor\n")

    byte gateState;
    byte signal;

    // Select a starting state randomly
    if
    :: true -> 
        gateState = GATE_OPEN;
        printf("GS: Started with OPEN gate\n")
    :: true -> 
        gateState = GATE_CLOSED;
        printf("GS: Started with CLOSED gate\n")
    fi

    // Wait for signals from the remote controller
    RCIn?signal;

    printf("GS: Received signal from the remote controller\n")

    if
    :: gateState == GATE_CLOSED -> 
        printf("GS: Gate is now open\n")
        gateState = GATE_OPEN;
    :: gateState == GATE_OPEN ->
        
        // Wait for the debris to be clear
        do
        :: true -> 

            printf("GS: Notifying the Obstacle Sensor to check for debris\n")

            // Signal the Obstacle Sensor to check for objects
            OSOut!1;
            
            // Wait for the Obstacle Sensor to signal that everything is ok
            byte osState;
            
            OSIn?osState;

            if
            :: osState == OS_CLEAR ->
                printf("GS: No debris. Gate is now open\n")
                state = GATE_OPEN;
                break;
            :: osState == OS_BUSY ->
                printf("GS: Debris detected. Attempting again\n")
            fi
        od

    fi
}

proctype ObstacleSensor(chan GateRequests, GateReplies) {

    printf("Started obstacle sensor\n")

    byte signal;

    // Wait for a signal
    GateRequests?signal;
    
    // Checking for debris
    if
    :: true ->
        debrisExists = true
    :: true ->
        debrisExists = false
    fi

    // Randomly return there being debris or not
    if
    :: !debrisExists -> 
        printf("Sending OS_CLEAR message\n")
        GateReplies!OS_CLEAR
    :: debrisExists -> 
        printf("Sending OS_BUSY message\n")
        GateReplies!OS_BUSY
    fi
}

init {
    chan RCIn = [0] of {byte};
    chan RCOut = [0] of {byte};

    chan GateRequests = [0] of {byte};
    chan GateReplies = [0] of {byte};

    atomic {
        run RemoteController(RCIn, RCOut);
        run GateSensor(RCOut, GateReplies, GateRequests);
        run ObstacleSensor(GateRequests, GateReplies);

        RCIn!1;
    }
}
