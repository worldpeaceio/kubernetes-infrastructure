extern crate haikunator;

use haikunator::Haikunator;

fn main() {
    let mut haikunator = Haikunator::default();
    haikunator.token_length = 0;
    println!("{}", haikunator.haikunate());
}
