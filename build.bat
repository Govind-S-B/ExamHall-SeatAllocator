echo off
cd allocator
cargo build
move target\debug\allocator.exe ../V3
rd /s /q target
