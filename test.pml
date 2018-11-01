
ltl p0 { <> (state == 2) -> <> (state == 3) }

byte state;

active proctype test() {
    state = 2;
    state = 3;
}
