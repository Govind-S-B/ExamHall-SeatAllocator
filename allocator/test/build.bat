set ORIGINAL_DIR=%CD%

cd ..
cargo build
move target\debug\allocator.exe test\bin

chdir /d %ORIGINAL_DIR%
