#define GATE_OPEN 0
#define GATE_CLOSED 1

#define OS_CLEAR 0
#define OS_BUSY 1

byte osState = OS_BUSY;
byte gsState = GATE_CLOSED;

ltl p1 { gsState == GATE_CLOSED U gsState == GATE_OPEN }
ltl p2 { osState == OS_BUSY U osState == OS_CLEAR }
ltl p3 { <> (gsState == GATE_CLOSED && osState == OS_CLEAR) U gsState == GATE_OPEN }

proctype RemoteController(chan In, Out) {
    
    byte signal;
    
    In?signal;

    Out!signal;

    printf("RC: Done\n")
}

proctype GateSensor(chan RIn, OIn, OOut) {
    
    byte signal;

    RIn?signal;
 
    do
    ::
        OOut!1
        
        OIn?signal

        if 
        :: signal == OS_CLEAR -> 
            printf("GS: Received OS_CLEAR\n")
            printf("GS: Switching gate state\n")
            
            if
            :: gsState == GATE_CLOSED -> gsState = GATE_OPEN
            :: gsState == GATE_OPEN -> gsState = GATE_CLOSED
            fi

            break
        :: signal == OS_BUSY ->
            printf("GS: Received OS_BUSY\n")
        fi
    od

    printf("GS: Done\n")
}

proctype ObstacleSensor(chan In, Out) {

    byte signal;

    do
    ::
        In?signal;

        if
        :: osState == OS_BUSY -> 
            
            osState = OS_CLEAR
            Out!osState
            break
        :: osState == OS_CLEAR -> 
            
            osState = OS_BUSY
            Out!osState
        fi

    od

    printf("OS: Done\n")
}

init {

    chan OSOut = [0] of {byte};
    chan OSIn = [0] of {byte};

    chan ROut = [0] of {byte};
    chan RIn = [0] of {byte};

    run RemoteController(RIn, ROut)
    run GateSensor(ROut, OSOut, OSIn)
    run ObstacleSensor(OSIn, OSOut)

    printf("Running main\n")

    RIn!1

    printf("Done\n");
}
