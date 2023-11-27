cd ..
cargo build
move target\debug\allocator.exe test\bin
del test\logs\logs.txt
cd test
