# Fuzzer regression corpus

Every `*.hex` / `*.bin` here is replayed through every parser target on each push and must
parse cleanly (a clean outcome or a typed `EBaseTlsLibException`, never a crash/hang). The
scheduled discovery soak persists new crashers here; each is then fixed. Don't delete an
entry unless its parser surface is removed.
