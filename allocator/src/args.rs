pub fn get_args() -> (bool, String, String) {
    let mut randomize = false;
    let mut paths = Vec::with_capacity(2);
    for arg in std::env::args() {
        match arg.as_str() {
            "-r" | "--randomize" => randomize = true,
            _ => paths.push(arg),
        }
    }
    // first argument is the path of the program itself
    let [_, input_db_path, output_db_path] = paths.as_slice()
        else {
            eprintln!("INVALID ARGUMENTS: arguments should be 
             \" ./allocator <input_db_path> <output_db_path> [-r | --randomize]");
            panic!("args given are {:?}", paths);
        };
    (
        randomize,
        input_db_path.to_owned(),
        output_db_path.to_owned(),
    )
}
