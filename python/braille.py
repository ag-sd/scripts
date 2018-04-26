reference = 'the quick brown fox jumps over the lazy dog'
conversion = '0000010111101100101000100000001111101010010101001001001010000000001100001110101010100101111011100' \
             '0000011010010101010110100000001011010100110110011110001110000000010101011100110001011101000000001' \
             '1110110010100010000000111000100000101011101111000000100110101010110110'


# Function to convert a single character to braille
def convert_char(char):
    # Blank string
    braille = ''
    # If UPPER case, add the upper case marker and convert char to lower
    if char.isupper():
        braille = conversion[:6]
        char = char.lower()
    # Find character in reference
    index = reference.find(char)
    # Each character is 6 spaces, with the first 6 chars indicating the capitalization
    # So the braille text will be at 6 + (index * 6) for the next 6 chars
    code_location = 6 + (index * 6)
    braille += conversion[code_location:code_location + 6]
    # Return the string
    return braille


# Function to convert a string to braille. The string should be valid alphabets or space
def answer(plaintext):
    # Initialize response
    braille = ''
    # For each character in plaintext
    for char in plaintext:
        # Convert it to braille and append to response
        braille += convert_char(char)
    return braille


print(convert_char('c') == '100100')
print(convert_char('o') == '101010')
print(convert_char('d') == '100110')
print(convert_char('e') == '100010')
print(convert_char(' ') == '000000')

print(answer('Braille') == '000001110000111010100000010100111000111000100010')
print(answer('The quick brown fox jumps over the lazy dog') == conversion)
print(answer('the quick brown fox jumps over the lazy dog') != conversion)
