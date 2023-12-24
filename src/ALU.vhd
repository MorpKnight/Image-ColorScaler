LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE std.textio.ALL;
USE std.env.ALL;

ENTITY ALU IS
    PORT (
        CLK : IN STD_LOGIC;
        PC_ALU : INTEGER;
        OPCODE_ALU : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
        DONE : OUT STD_LOGIC
    );
END ENTITY ALU;

ARCHITECTURE rtl OF ALU IS
    COMPONENT grayscale IS
        PORT (
            clk : IN STD_LOGIC;

            r_in_gray : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            g_in_gray : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            b_in_gray : IN STD_LOGIC_VECTOR(7 DOWNTO 0);

            r_out_gray : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            g_out_gray : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            b_out_gray : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
        );
    END COMPONENT grayscale;

    COMPONENT greenscale IS
        PORT (
            clk : IN STD_LOGIC;
            r_in_green : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            g_in_green : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            b_in_green : IN STD_LOGIC_VECTOR(7 DOWNTO 0);

            r_out_green : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            g_out_green : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            b_out_green : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
        );
    END COMPONENT greenscale;

    COMPONENT redscale IS
        PORT (
            clk : IN STD_LOGIC;
            r_in_red : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            g_in_red : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            b_in_red : IN STD_LOGIC_VECTOR(7 DOWNTO 0);

            r_out_red : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            g_out_red : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            b_out_red : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
        );
    END COMPONENT redscale;

    COMPONENT bluescale IS
        PORT (
            clk : IN STD_LOGIC;
            r_in_blue : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            g_in_blue : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            b_in_blue : IN STD_LOGIC_VECTOR(7 DOWNTO 0);

            r_out_blue : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            g_out_blue : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            b_out_blue : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
        );
    END COMPONENT bluescale;

    TYPE HEADER_TYPE IS ARRAY (0 TO 53) OF CHARACTER;
    TYPE PIXEL_TYPE IS RECORD
        R : STD_LOGIC_VECTOR(7 DOWNTO 0);
        G : STD_LOGIC_VECTOR(7 DOWNTO 0);
        B : STD_LOGIC_VECTOR(7 DOWNTO 0);
    END RECORD;
    TYPE ROW_TYPE IS ARRAY (INTEGER RANGE <>) OF PIXEL_TYPE;
    TYPE ROW_PTR IS ACCESS ROW_TYPE;
    TYPE IMAGE_TYPE IS ARRAY (INTEGER RANGE <>) OF ROW_PTR;
    TYPE IMAGE_PTR IS ACCESS IMAGE_TYPE;

    SIGNAL r_in_gray, g_in_gray, b_in_gray, r_in_green, g_in_green, b_in_green : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL r_in_red, g_in_red, b_in_red, r_in_blue, g_in_blue, b_in_blue : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL r_out_gray, g_out_gray, b_out_gray, r_out_green, g_out_green, b_out_green : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL r_out_red, g_out_red, b_out_red, r_out_blue, g_out_blue, b_out_blue : STD_LOGIC_VECTOR(7 DOWNTO 0);
BEGIN

    GYSCL : grayscale
    PORT MAP(
        clk => clk,

        r_in_gray => r_in_gray,
        g_in_gray => g_in_gray,
        b_in_gray => b_in_gray,

        r_out_gray => r_out_gray,
        g_out_gray => g_out_gray,
        b_out_gray => b_out_gray
    );

    GRN : greenscale
    PORT MAP(
        clk => clk,
        r_in_green => r_in_green,
        g_in_green => g_in_green,
        b_in_green => b_in_green,

        r_out_green => r_out_green,
        g_out_green => g_out_green,
        b_out_green => b_out_green
    );

    RD : redscale
    PORT MAP(
        clk => clk,
        r_in_red => r_in_red,
        g_in_red => g_in_red,
        b_in_red => b_in_red,

        r_out_red => r_out_red,
        g_out_red => g_out_red,
        b_out_red => b_out_red
    );

    BL : bluescale
    PORT MAP(
        clk => clk,
        r_in_blue => r_in_blue,
        g_in_blue => g_in_blue,
        b_in_blue => b_in_blue,

        r_out_blue => r_out_blue,
        g_out_blue => g_out_blue,
        b_out_blue => b_out_blue
    );

    PROCESS
        TYPE CHAR_FILE IS FILE OF CHARACTER;
        FILE SOURCE_FILE : CHAR_FILE OPEN read_mode IS "PICT.bmp";
        FILE DEST_FILE : CHAR_FILE OPEN write_mode IS "PICT_out.bmp";
        VARIABLE HEADER : HEADER_TYPE;
        VARIABLE IMG_W, IMG_H, PADDING : INTEGER;
        VARIABLE ROW : ROW_PTR;
        VARIABLE IMG : IMAGE_PTR;
        VARIABLE CHAR : CHARACTER;
    BEGIN
        IF PC_ALU = 5 THEN
            DONE <= '0';
            FOR i IN HEADER_TYPE'RANGE LOOP
                read(SOURCE_FILE, HEADER(i));
            END LOOP;
            
            -- This assertion checks if the first two elements of the HEADER array are 'B' and 'M'.
            -- If they are not, it reports an error message indicating that the file is not a BMP file.
            ASSERT HEADER(0) = 'B' AND HEADER(1) = 'M'
            REPORT "Not a BMP file" SEVERITY FAILURE;

            -- This assertion checks if the given BMP file is a 24-bit BMP file.
            -- It verifies that the values at positions 10, 11, 12, and 13 in the HEADER array are equal to 54, 0, 0, and 0 respectively.
            -- If the condition is not met, it reports a failure with the message "Not a 24-bit BMP file".
            ASSERT CHARACTER'pos(HEADER(10)) = 54 AND CHARACTER'pos(HEADER(11)) = 0 AND
                CHARACTER'pos(HEADER(12)) = 0 AND CHARACTER'pos(HEADER(13)) = 0
                REPORT "Not a 24-bit BMP file" SEVERITY FAILURE;

            -- This assertion checks if the 14th, 15th, 16th, and 17th bytes of the HEADER array represent the values 40, 0, 0, and 0 respectively. If they do not, it reports a failure with the message "Not a 24-bit BMP file".
            ASSERT CHARACTER'pos(HEADER(14)) = 40 AND CHARACTER'pos(HEADER(15)) = 0 AND
                CHARACTER'pos(HEADER(16)) = 0 AND CHARACTER'pos(HEADER(17)) = 0
            REPORT "Not a 24-bit BMP file" SEVERITY FAILURE;

            -- This assertion checks if the 24th and 25th bytes of the HEADER array represent a 24-bit BMP file. 
            -- If the condition is not met, it reports a failure with the message "Not a 24-bit BMP file".
            ASSERT CHARACTER'pos(HEADER(28)) = 24 AND CHARACTER'pos(HEADER(29)) = 0
            REPORT "Not a 24-bit BMP file" SEVERITY FAILURE;

            -- Calculate the width of the image based on the values stored in the HEADER array.
            -- The width is calculated by converting the bytes at positions 18, 19, 20, and 21 of the HEADER array to their corresponding integer values.
            -- The resulting width is stored in the IMG_W variable.
            IMG_W := CHARACTER'pos(HEADER(18)) + CHARACTER'pos(HEADER(19)) * 256 +
                CHARACTER'pos(HEADER(20)) * 256 * 256 + CHARACTER'pos(HEADER(21)) * 256 * 256 * 256;

            -- Calculate the value of IMG_H by converting the bytes from HEADER(22) to HEADER(25) to an integer.
            -- The bytes are multiplied by powers of 256 and summed together.
            IMG_H := CHARACTER'pos(HEADER(22)) + CHARACTER'pos(HEADER(23)) * 256 +
                CHARACTER'pos(HEADER(24)) * 256 * 256 + CHARACTER'pos(HEADER(25)) * 256 * 256 * 256;

            -- Calculate the padding required for the image data.
            -- The padding is calculated as the difference between the nearest multiple of 4 and the width of the image multiplied by 3.
            -- The result is then taken modulo 4 to ensure that the padding is always a multiple of 4.
            PADDING := (4 - (IMG_W * 3) MOD 4) MOD 4;

            -- Description: Initialize a new image with a specified height and set all pixel values to 0.
            -- Parameters:
            --   - IMG: The image to be initialized.
            --   - IMG_H: The height of the image.
            IMG := NEW IMAGE_TYPE(0 TO IMG_H - 1);

            -- This code reports the width and height of an image.
            -- It uses the IMG_W and IMG_H constants to display the image dimensions.
            -- The width is displayed as "Image width: <width> px" and the height is displayed as "Image height: <height> px".
            -- This information is logged with a severity level of NOTE.
            REPORT "Image width: " & INTEGER'image(IMG_W) & " px" SEVERITY NOTE;
            REPORT "Image height: " & INTEGER'image(IMG_H) & " px" SEVERITY NOTE;

            -- This loop reads pixel data from a source file and stores it in a 2D array called IMG.
            -- It iterates over each row and column of the image, reading the blue, green, and red color components of each pixel.
            -- The pixel data is stored in a custom record type called ROW_TYPE, and each row of the image is represented by an instance of this record type.
            -- The pixel data is read from the source file as characters and converted to unsigned integers before being assigned to the corresponding color component of the current pixel.
            -- After reading the pixel data for each row, the loop skips over a specified number of characters (padding) in the source file.
            -- Finally, the current row is assigned to the corresponding row in the IMG array.
            -- This loop continues until all rows of the image have been processed.
            FOR ROW_I IN 0 TO IMG_H - 1 LOOP
                ROW := NEW ROW_TYPE(0 TO IMG_W - 1);
                FOR COL_I IN 0 TO IMG_W - 1 LOOP
                    read(SOURCE_FILE, CHAR);
                    ROW(COL_I).B := STD_LOGIC_VECTOR(to_unsigned(CHARACTER'pos(CHAR), 8));
                    read(SOURCE_FILE, CHAR);
                    ROW(COL_I).G := STD_LOGIC_VECTOR(to_unsigned(CHARACTER'pos(CHAR), 8));
                    read(SOURCE_FILE, CHAR);
                    ROW(COL_I).R := STD_LOGIC_VECTOR(to_unsigned(CHARACTER'pos(CHAR), 8));
                END LOOP;

                FOR i IN 1 TO PADDING LOOP
                    read(SOURCE_FILE, CHAR);
                END LOOP;
                IMG(ROW_I) := ROW;
            END LOOP;

            -- This selection statement is used to perform different operations on each pixel of an image.
            -- It iterates over each row and column of the image and based on the value of OPCODE_ALU,
            -- it performs the corresponding operation on the pixel values.
            -- The operations include converting the pixel to grayscale, extracting the green, red, or blue channel,
            -- or leaving the pixel unchanged if the opcode is not recognized.
            -- The pixel values are stored in the ROW variable, and the result of the operation is stored back in the same location.
            -- The WAIT UNTIL statement ensures that the operation is synchronized with the rising edge of the clock signal.
            FOR ROW_I IN 0 TO IMG_H - 1 LOOP
                ROW := IMG(ROW_I);
                FOR COL_I IN 0 TO IMG_W - 1 LOOP
                    CASE OPCODE_ALU IS
                        WHEN "000000" =>
                            r_in_gray <= ROW(COL_I).R;
                            g_in_gray <= ROW(COL_I).G;
                            b_in_gray <= ROW(COL_I).B;
                            WAIT UNTIL rising_edge(clk);
                            ROW(COL_I).R := r_out_gray;
                            ROW(COL_I).G := g_out_gray;
                            ROW(COL_I).B := b_out_gray;
                        WHEN "000001" =>
                            r_in_green <= ROW(COL_I).R;
                            g_in_green <= ROW(COL_I).G;
                            b_in_green <= ROW(COL_I).B;
                            WAIT UNTIL rising_edge(clk);
                            ROW(COL_I).R := r_out_green;
                            ROW(COL_I).G := g_out_green;
                            ROW(COL_I).B := b_out_green;
                        WHEN "000010" =>
                            r_in_red <= ROW(COL_I).R;
                            g_in_red <= ROW(COL_I).G;
                            b_in_red <= ROW(COL_I).B;
                            WAIT UNTIL rising_edge(clk);
                            ROW(COL_I).R := r_out_red;
                            ROW(COL_I).G := g_out_red;
                            ROW(COL_I).B := b_out_red;
                        WHEN "000011" =>
                            r_in_blue <= ROW(COL_I).R;
                            g_in_blue <= ROW(COL_I).G;
                            b_in_blue <= ROW(COL_I).B;
                            WAIT UNTIL rising_edge(clk);
                            ROW(COL_I).R := r_out_blue;
                            ROW(COL_I).G := g_out_blue;
                            ROW(COL_I).B := b_out_blue;
                        WHEN OTHERS =>
                            NULL;
                    END CASE;
                END LOOP;
            END LOOP;

            -- Writes the header data to the destination file.
            -- 
            -- Parameters:
            --   - DEST_FILE: The destination file handle.
            --   - HEADER: The header data to be written.
            --
            -- Returns: None
            FOR i IN HEADER_TYPE'RANGE LOOP
                write(DEST_FILE, HEADER(i));
            END LOOP;

            -- This loop iterates over each row of the IMG array and writes the color values of each pixel to the DEST_FILE.
            -- It first retrieves the current row from the IMG array and then iterates over each column of the row.
            -- For each pixel, it converts the blue, green, and red color components to integers and writes them to the DEST_FILE.
            -- After writing the color values of all pixels in a row, it adds padding to the DEST_FILE by writing zeros.
            -- This process is repeated for each row of the IMG array.
            FOR ROW_I IN 0 TO IMG_H - 1 LOOP
                ROW := IMG(ROW_I);
                FOR COL_I IN 0 TO IMG_W - 1 LOOP
                    CHAR := CHARACTER'val(to_integer(unsigned(ROW(COL_I).B)));
                    write(DEST_FILE, CHAR);
                    CHAR := CHARACTER'val(to_integer(unsigned(ROW(COL_I).G)));
                    write(DEST_FILE, CHAR);
                    CHAR := CHARACTER'val(to_integer(unsigned(ROW(COL_I).R)));
                    write(DEST_FILE, CHAR);
                END LOOP;

                FOR i IN 1 TO PADDING LOOP
                    CHAR := CHARACTER'val(0);
                    write(DEST_FILE, CHAR);
                END LOOP;
            END LOOP;

            -- Deallocate the memory allocated for IMG.
            deallocate(IMG);

            -- Close the source file.
            file_close(SOURCE_FILE);

            -- Close the destination file.
            file_close(DEST_FILE);

            -- Set the DONE signal to '1' to indicate completion.
            DONE <= '1';

            -- Report "Done" as a note severity message.
            REPORT "Done" SEVERITY NOTE;

            -- Finish the process.
            finish;
        END IF;
    END PROCESS;
END ARCHITECTURE rtl;