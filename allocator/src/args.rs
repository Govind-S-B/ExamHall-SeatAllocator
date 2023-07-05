// TODO: delta as an argument
pub struct Arguments {
    pub randomize: Option<usize>,
    pub input_db_path: String,
    pub output_db_path: String,
}

pub fn get() -> Arguments {
    let mut delta = None;
    let mut paths = Vec::with_capacity(3);
    let mut args = std::env::args().into_iter();
    while let Some(arg) = args.next() {
        match arg.as_str() {
            "-r" | "--randomize" => {
                delta = Some(
                    args.next()
                        .expect("[ no argument after -r flag ]")
                        .parse()
                        .expect("[ invalid argument for delta ]"),
                )
            }
            _ => paths.push(arg),
        }
    }
    // first argument is the path of the program itself
    let [_, input_db_path, output_db_path] = paths.as_slice()
    else {
        eprintln!("args given are {paths:?}");
        panic!("[ INVALID ARGUMENTS: arguments should be \" ./allocator <input_db_path> <output_db_path> [-r | --randomize] ]");
    };

    Arguments {
        randomize: delta,
        input_db_path: input_db_path.to_owned(),
        output_db_path: output_db_path.to_owned(),
    }
}
