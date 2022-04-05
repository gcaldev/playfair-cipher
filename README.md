# Playfair cipher
## How it works
This cipher method is based in playfair cipher, it receives a string to be ciphered or deciphered depending on the operation choosed in the terminal. The program takes chars in pairs and depending on their position in the matrix that is stored inside a matriz.dat file, it will replace the chars with others in the matrix.
- In the case the pair is positioned in a same column of the matrix, the program will be choosing the chars that are one position below (for encoding) or above (for decoding).
- If they are in the same row it will be choosing the chars that are one position right (for encoding) or left (for decoding).
- In case row and column are different, supposing we have A = (row1,col1) for char1 and B = (row2,col2) for char2, then the program will rotate their x positions, resulting A = (row1,col2) and B = (row2,col1). 

## Output example

Considering the following matrix:
abcde
fghik
lmnop
qrstu
vwxyz

Input1: C // Cipher
Input2: vlhksio
Output: aqiftho