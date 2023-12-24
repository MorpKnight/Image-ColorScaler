LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE std.textio.ALL;
USE std.env.ALL;

ENTITY ALU IS
    PORT (
        CLK : IN STD_LOGIC;
        OPCODE : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
        DONE : OUT STD_LOGIC
    );
END ENTITY ALU;

ARCHITECTURE rtl OF ALU IS
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

    SIGNAL r_in, g_in, b_in : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL r_out, g_out, b_out : STD_LOGIC_VECTOR(7 DOWNTO 0);
BEGIN

    COLOR : ENTITY work.greenscale(rtl)
        PORT MAP(
            CLK => clk,
            R_IN => r_in,
            G_IN => g_in,
            B_IN => b_in,
            R_OUT => r_out,
            G_OUT => g_out,
            B_OUT => b_out
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
        FOR i IN HEADER_TYPE'RANGE LOOP
            read(SOURCE_FILE, HEADER(i));
        END LOOP;

        ASSERT HEADER(0) = 'B' AND HEADER(1) = 'M'
        REPORT "Not a BMP file" SEVERITY FAILURE;

        ASSERT CHARACTER'pos(HEADER(10)) = 54 AND CHARACTER'pos(HEADER(11)) = 0 AND
        CHARACTER'pos(HEADER(12)) = 0 AND CHARACTER'pos(HEADER(13)) = 0
        REPORT "Not a 24-bit BMP file" SEVERITY FAILURE;

        ASSERT CHARACTER'pos(HEADER(14)) = 40 AND CHARACTER'pos(HEADER(15)) = 0 AND
        CHARACTER'pos(HEADER(16)) = 0 AND CHARACTER'pos(HEADER(17)) = 0
        REPORT "Not a 24-bit BMP file" SEVERITY FAILURE;

        ASSERT CHARACTER'pos(HEADER(28)) = 24 AND CHARACTER'pos(HEADER(29)) = 0
        REPORT "Not a 24-bit BMP file" SEVERITY FAILURE;

        IMG_W := CHARACTER'pos(HEADER(18)) + CHARACTER'pos(HEADER(19)) * 256 +
            CHARACTER'pos(HEADER(20)) * 256 * 256 + CHARACTER'pos(HEADER(21)) * 256 * 256 * 256;

        IMG_H := CHARACTER'pos(HEADER(22)) + CHARACTER'pos(HEADER(23)) * 256 +
            CHARACTER'pos(HEADER(24)) * 256 * 256 + CHARACTER'pos(HEADER(25)) * 256 * 256 * 256;

        PADDING := (4 - (IMG_W * 3) MOD 4) MOD 4;

        IMG := NEW IMAGE_TYPE(0 TO IMG_H - 1);

        REPORT "Image width: " & INTEGER'image(IMG_W) & " px" SEVERITY NOTE;
        REPORT "Image height: " & INTEGER'image(IMG_H) & " px" SEVERITY NOTE;

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

        FOR ROW_I IN 0 TO IMG_H - 1 LOOP
            ROW := IMG(ROW_I);
            FOR COL_I IN 0 TO IMG_W - 1 LOOP
                r_in <= ROW(COL_I).R;
                g_in <= ROW(COL_I).G;
                b_in <= ROW(COL_I).B;
                WAIT UNTIL rising_edge(clk);
                ROW(COL_I).R := r_out;
                ROW(COL_I).G := g_out;
                ROW(COL_I).B := b_out;
            END LOOP;
        END LOOP;

        FOR i IN HEADER_TYPE'RANGE LOOP
            write(DEST_FILE, HEADER(i));
        END LOOP;

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

        deallocate(IMG);
        file_close(SOURCE_FILE);
        file_close(DEST_FILE);
        DONE <= '1';
        REPORT "Done" SEVERITY NOTE;
        WAIT;
    END PROCESS;
END ARCHITECTURE rtl;