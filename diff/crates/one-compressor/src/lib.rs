use anyhow::{anyhow, Result};
use ethers::utils::hex;

/// Compress a byte array
/// Run Length Encode only zeros in the byte array
pub fn compress<T: AsRef<[u8]>>(bytes: T) -> Result<String> {
    let mut result = Vec::default();

    let mut num_zeros = 0;
    hex::decode(bytes)?.into_iter().for_each(|byte| {
        if byte == 0 {
            // If we have reached the max number of zeros, add them to the result
            // and continue counting.
            if num_zeros == u8::MAX {
                fill_zeros(&mut result, &mut num_zeros);
                println!();
            }
            num_zeros += 1;
            print!("{}-{},", byte, num_zeros);
        } else {
            if num_zeros > 0 {
                println!();
            }
            // If we have zeros to add, add them to the result
            fill_zeros(&mut result, &mut num_zeros);
            // Copy `byte` into the result array
            result.push(byte);
            print!("{}-{},", byte, num_zeros);
            println!();
        }
    });
    // If we have zeros to add, add them to the result
    fill_zeros(&mut result, &mut num_zeros);

    Ok(hex::encode(result))
}

/// Decompress a byte array
/// Take compressed bytes and return the original bytes with zeros added back in
pub fn decompress<T: AsRef<[u8]>>(bytes: T) -> Result<String> {
    let bytes = hex::decode(bytes)?;
    let mut result = Vec::default();
    let mut iter = bytes.into_iter();
    while let Some(byte) = iter.next() {
        if byte == 0 {
            // Expand the result array by `length` zeros
            let length = iter.next().ok_or(anyhow!("Invalid input"))?;
            result.resize(result.len() + length as usize, 0);
        } else {
            // Copy `byte` into the result array
            result.push(byte);
        }
    }
    Ok(hex::encode(result))
}

/// Append RLE zeros to the vector if necessary
fn fill_zeros(v: &mut Vec<u8>, num_zeros: &mut u8) {
    if *num_zeros > 0 {
        v.push(0);
        v.push(*num_zeros);
        *num_zeros = 0;
    }
}

#[cfg(test)]
mod test {
    #[test]
    pub fn test_compress_middle() {
        let input_value = String::from("7f6b590c000000000000220000ff");
        let output_value = super::compress(input_value).unwrap();
        let expected_value = String::from("7f6b590c0006220002ff");
        assert_eq!(output_value, expected_value);
    }

    #[test]
    pub fn test_compress_edge_end() {
        let input_value = String::from("00000000ff");
        let output_value = super::compress(input_value).unwrap();
        let expected_value = String::from("0004ff");
        assert_eq!(output_value, expected_value);
    }

    #[test]
    pub fn test_compress_edge_start() {
        let input_value = String::from("ff00000000");
        let output_value = super::compress(input_value).unwrap();
        let expected_value = String::from("ff0004");
        assert_eq!(output_value, expected_value);
    }

    #[test]
    pub fn test_compress_zero_rollover() {
        let input_value = String::from("00").repeat(260);
        let output_value = super::compress(input_value).unwrap();
        let expected_value = String::from("00ff0005");
        assert_eq!(output_value, expected_value);
    }

    #[test]
    pub fn test_compress_zero_rollover_multiple() {
        let input_value = String::from("00").repeat(255 * 2 + 5);
        let output_value = super::compress(input_value).unwrap();
        let expected_value = String::from("00ff00ff0005");
        assert_eq!(output_value, expected_value);
    }

    #[test]
    pub fn test_decompress_middle() {
        let input_value = String::from("7f6b590c0006220002ff");
        let output_value = super::decompress(input_value).unwrap();
        let expected_value = String::from("7f6b590c000000000000220000ff");
        assert_eq!(output_value, expected_value);
    }

    #[test]
    pub fn test_decompress_edge_end() {
        let input_value = String::from("0004ff");
        let output_value = super::decompress(input_value).unwrap();
        let expected_value = String::from("00000000ff");
        assert_eq!(output_value, expected_value);
    }

    #[test]
    pub fn test_decompress_edge_start() {
        let input_value = String::from("ff0004");
        let output_value = super::decompress(input_value).unwrap();
        let expected_value = String::from("ff00000000");
        assert_eq!(output_value, expected_value);
    }

    #[test]
    pub fn test_decompress_zero_rollover() {
        let input_value = String::from("00ff0005");
        let output_value = super::decompress(input_value).unwrap();
        let expected_value = String::from("00").repeat(260);
        assert_eq!(output_value, expected_value);
    }

    #[test]
    pub fn test_decompress_zero_rollover_multiple() {
        let input_value = String::from("00ff00ff0005");
        let output_value = super::decompress(input_value).unwrap();
        let expected_value = String::from("00").repeat(255 * 2 + 5);
        assert_eq!(output_value, expected_value);
    }
}
