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
            finish;
        END IF;
    END PROCESS;
END ARCHITECTURE rtl;