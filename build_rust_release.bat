echo off
cd allocator
cargo build --release
move target\release\allocator.exe ../EHSA_V3\bin
rd /s /q target 
