echo off
cd allocator
cargo build --release
move target\release\allocator.exe ../EHSA_V3
rd /s /q target 
