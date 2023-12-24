LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE std.textio.ALL;
USE std.env.ALL;

ENTITY ALU IS
    PORT (
        CLK : IN STD_LOGIC;
        DONE : OUT STD_LOGIC
    );
END ENTITY ALU;

ARCHITECTURE ALU_PRODUCT OF ALU IS
    TYPE MEM IS ARRAY (0 TO 60000000) OF STD_LOGIC_VECTOR(23 DOWNTO 0);
    SIGNAL RAM : MEM := (OTHERS => (OTHERS => '0'));
    SIGNAL PS, NS : STATE;
    TYPE HEADER_TYPE IS ARRAY (0 TO 53) OF CHARACTER;
    TYPE PIXEL IS RECORD
        R : STD_LOGIC_VECTOR(7 DOWNTO 0);
        G : STD_LOGIC_VECTOR(7 DOWNTO 0);
        B : STD_LOGIC_VECTOR(7 DOWNTO 0);
    END RECORD;
    TYPE ROW_TYPE IS ARRAY (INTEGER RANGE <>) OF PIXEL;
    TYPE ROW_PTR IS ACCESS ROW_TYPE;
    TYPE IMAGE_TYPE IS ARRAY (INTEGER RANGE <>) OF ROW_PTR;
    TYPE IMAGE_PTR IS ACCESS IMAGE_TYPE;

    SIGNAL R_in, G_in, B_in : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL R_out, G_out, B_out : STD_LOGIC_VECTOR(7 DOWNTO 0);

    SIGNAL CLK : STD_LOGIC := '0';
    COMPONENT CLK IS
        PORT (
            CLK : IN STD_LOGIC
        );
    END COMPONENT CLK;
BEGIN
    COLOR_EDIT : ENTITY work.grayscale(rtl)
        PORT MAP(
            CLK => CLK,
            R_in => R_in,
            G_in => G_in,
            B_in => B_in,
            R_out => R_out,
            G_out => G_out,
            B_out => B_out
        );

    PROCESS
        TYPE CHAR_FILE IS FILE OF CHARACTER;
        FILE R_FILE : CHAR_FILE OPEN read_mode IS "PICT.bmp";
        FILE W_FILE : CHAR_FILE OPEN write_mode IS "PICT_out.bmp";
        VARIABLE HEADER : HEADER_TYPE;
        VARIABLE ROW : ROW_PTR;
        VARIABLE IMAGE : IMAGE_PTR;
        VARIABLE IMG_W, IMG_H, PADDING, RAM_ADDR : INTEGER := 0;
        VARIABLE CHAR : CHARACTER;
    BEGIN
        DONE <= '0';

        FOR i IN HEADER_TYPE'RANGE LOOP
            read(R_FILE, header(i));
        END LOOP;

        ASSERT HEADER(0) = 'B' AND HEADER(1) = 'M'
        REPORT "Not a BMP file"
            SEVERITY FAILURE;

        ASSERT CHARACTER'pos(HEADER(10)) = 54 AND CHARACTER'pos(HEADER(11)) = 0
        AND CHARACTER'pos(HEADER(12)) = 0 AND CHARACTER'pos(HEADER(13)) = 0
        REPORT "HEADER ISN'T 54 BYTES"
            SEVERITY FAILURE;

        ASSERT CHARACTER'pos(HEADER(14)) = 40 AND CHARACTER'pos(HEADER(15)) = 0
        AND CHARACTER'pos(HEADER(16)) = 0 AND CHARACTER'pos(HEADER(17)) = 0
        REPORT "DIB HEADER ISN'T 40 BYTES"
            SEVERITY FAILURE;

        ASSERT CHARACTER'pos(HEADER(28)) = 24 AND CHARACTER'pos(HEADER(29)) = 0
        REPORT "NOT 24 BIT COLOR"
            SEVERITY FAILURE;

        IMG_H := CHARACTER'pos(HEADER(22)) + CHARACTER'pos(HEADER(23)) * 256
            + CHARACTER'pos(HEADER(24)) * 256 * 256 + CHARACTER'pos(HEADER(25)) * 256 * 256 * 256;

        IMG_W := CHARACTER'pos(HEADER(18)) + CHARACTER'pos(HEADER(19)) * 256
            + CHARACTER'pos(HEADER(20)) * 256 * 256 + CHARACTER'pos(HEADER(21)) * 256 * 256 * 256;

        PADDING := (4 - (IMG_W * 3) MOD 4) MOD 4;
        IMAGE := NEW IMAGE_TYPE(0 TO IMG_H - 1);

        FOR ROW_I IN 0 TO IMG_H - 1 LOOP
            ROW := NEW ROW_TYPE(0 TO IMG_W - 1);
            FOR COL_I IN 0 TO IMG_W - 1 LOOP
                read(R_FILE, CHAR);
                ROW(COL_I).B := STD_LOGIC_VECTOR(to_unsigned(CHARACTER'pos(CHAR), 8));
                read(R_FILE, CHAR);
                ROW(COL_I).G := STD_LOGIC_VECTOR(to_unsigned(CHARACTER'pos(CHAR), 8));
                read(R_FILE, CHAR);
                ROW(COL_I).R := STD_LOGIC_VECTOR(to_unsigned(CHARACTER'pos(CHAR), 8));
                RAM(RAM_ADDR) := ROW(COL_I).R & ROW(COL_I).G & ROW(COL_I).B;
                RAM_ADDR := RAM_ADDR + 1;
            END LOOP;
            IMAGE(ROW_I) := ROW;
            FOR i IN 1 TO PADDING LOOP
                read(R_FILE, CHAR);
            END LOOP;
        END LOOP;

        FOR i IN 0 TO RAM_ADDR - 1 LOOP
            R_in <= RAM(i)(23 DOWNTO 16);
            G_in <= RAM(i)(15 DOWNTO 8);
            B_in <= RAM(i)(7 DOWNTO 0);
            WAIT FOR 1 ns;
            RAM(i) <= R_out & G_out & B_out;
        END LOOP;

        FOR ROW_I IN 0 TO IMG_H - 1 LOOP
            FOR COL_I IN 0 TO IMG_W - 1 LOOP
                write(W_FILE, CHARACTER'val(unsigned(IMAGE(ROW_I)(COL_I).B)));
                write(W_FILE, CHARACTER'val(unsigned(IMAGE(ROW_I)(COL_I).G)));
                write(W_FILE, CHARACTER'val(unsigned(IMAGE(ROW_I)(COL_I).R)));
            END LOOP;
            FOR i IN 1 TO PADDING LOOP
                write(W_FILE, CHARACTER'val(0));
            END LOOP;
        END LOOP;
        deallocate(IMAGE);
        file_close(R_FILE);
        file_close(W_FILE);
        REPORT "DONE"
            SEVERITY NOTE;
        DONE <= '1';

    END PROCESS;
END ARCHITECTURE ALU_PRODUCT;