cd allocator
cargo build
move target\debug\allocator.exe ../V3
rd /s /q target
cd ../V3
.\allocator.exe
.\pdf_generator.py
