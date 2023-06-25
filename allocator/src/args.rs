pub struct Arguments {
    pub randomize: bool,
    pub input_db_path: String,
    pub output_db_path: String,
}

pub fn get_args() -> Arguments {
    let mut randomize = false;
    let mut args = Vec::with_capacity(3);
    for arg in std::env::args() {
        match arg.as_str() {
            "-r" | "--randomize" => randomize = true,
            _ => args.push(arg),
        }
    }
    // first argument is the path of the program itself
    let [_, input_db_path, output_db_path] = args.as_slice()
        else {
            eprintln!("INVALID ARGUMENTS: arguments should be 
             \" ./allocator <input_db_path> <output_db_path> [-r | --randomize]");
            panic!("args given are {:?}", args);
        };
    Arguments {
        randomize,
        input_db_path: input_db_path.to_owned(),
        output_db_path: output_db_path.to_owned(),
    }
}
