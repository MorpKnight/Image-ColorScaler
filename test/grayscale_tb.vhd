LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

USE std.textio.ALL;
USE std.env.finish;

ENTITY grayscale_tb IS
  PORT (
    clk : IN STD_LOGIC
  );
END grayscale_tb;

ARCHITECTURE sim OF grayscale_tb IS
  TYPE RAM_TYPE IS ARRAY (0 TO 6000000) OF STD_LOGIC_VECTOR(23 DOWNTO 0);
  SIGNAL RAM : RAM_TYPE := (OTHERS => (OTHERS => '0'));
  SIGNAL PresentState, NextState : INTEGER RANGE 0 TO 2;

  TYPE header_type IS ARRAY (0 TO 53) OF CHARACTER;

  TYPE pixel_type IS RECORD
    red : STD_LOGIC_VECTOR(7 DOWNTO 0);
    green : STD_LOGIC_VECTOR(7 DOWNTO 0);
    blue : STD_LOGIC_VECTOR(7 DOWNTO 0);
  END RECORD;

  TYPE row_type IS ARRAY (INTEGER RANGE <>) OF pixel_type;
  TYPE row_pointer IS ACCESS row_type;
  TYPE image_type IS ARRAY (INTEGER RANGE <>) OF row_pointer;
  TYPE image_pointer IS ACCESS image_type;

  SIGNAL r_in : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL g_in : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL b_in : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL r_out : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL g_out : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL b_out : STD_LOGIC_VECTOR(7 DOWNTO 0);

BEGIN

  UUT : ENTITY work.grayscale(rtl)
    PORT MAP(
      clk => clk,
      r_in => r_in,
      g_in => g_in,
      b_in => b_in,
      r_out => r_out,
      g_out => g_out,
      b_out => b_out
    );

  PROCESS
    TYPE char_file IS FILE OF CHARACTER;
    FILE bmp_file : char_file OPEN read_mode IS "GBS5CWEaQAAi70W.bmp";
    FILE out_file : char_file OPEN write_mode IS "output.bmp";
    VARIABLE header : header_type;
    VARIABLE image_width, image_width_swap : INTEGER;
    VARIABLE image_height, image_height_swap : INTEGER;
    VARIABLE row : row_pointer;
    VARIABLE image : image_pointer;
    VARIABLE padding : INTEGER;
    VARIABLE char : CHARACTER;
    VARIABLE ram_address, haha_RAM_FUNNY : INTEGER := 0;
  BEGIN

    FOR i IN header_type'RANGE LOOP
      read(bmp_file, header(i));
    END LOOP;

    PresentState <= 0;
    NextState <= 1;

    ASSERT header(0) = 'B' AND header(1) = 'M'
    REPORT "NOT A BMP FILE"
      SEVERITY failure;

    ASSERT CHARACTER'pos(header(10)) = 54 AND
    CHARACTER'pos(header(11)) = 0 AND
    CHARACTER'pos(header(12)) = 0 AND
    CHARACTER'pos(header(13)) = 0
    REPORT "Header is not 54 bytes"
      SEVERITY failure;

    ASSERT CHARACTER'pos(header(14)) = 40 AND
    CHARACTER'pos(header(15)) = 0 AND
    CHARACTER'pos(header(16)) = 0 AND
    CHARACTER'pos(header(17)) = 0
    REPORT "DIB headers size is not 40 bytes"
      SEVERITY failure;

    ASSERT CHARACTER'pos(header(28)) = 24 AND
    CHARACTER'pos(header(29)) = 0
    REPORT "Bits per pixel is not 24" SEVERITY failure;

    image_width := CHARACTER'pos(header(18)) +
      CHARACTER'pos(header(19)) * 2 ** 8 +
      CHARACTER'pos(header(20)) * 2 ** 16 +
      CHARACTER'pos(header(21)) * 2 ** 24;

    image_height := CHARACTER'pos(header(22)) +
      CHARACTER'pos(header(23)) * 2 ** 8 +
      CHARACTER'pos(header(24)) * 2 ** 16 +
      CHARACTER'pos(header(25)) * 2 ** 24;

    REPORT "image_width: " & INTEGER'image(image_width) &
      ", image_height: " & INTEGER'image(image_height);

    padding := (4 - image_width * 3 MOD 4) MOD 4;

    image := NEW image_type(0 TO image_height - 1);

    PresentState <= 1;
    NextState <= 2;

    FOR row_i IN 0 TO image_height - 1 LOOP

      row := NEW row_type(0 TO image_width - 1);

      FOR col_i IN 0 TO image_width - 1 LOOP

        read(bmp_file, char);
        row(col_i).blue :=
        STD_LOGIC_VECTOR(to_unsigned(CHARACTER'pos(char), 8));

        read(bmp_file, char);
        row(col_i).green :=
        STD_LOGIC_VECTOR(to_unsigned(CHARACTER'pos(char), 8));

        read(bmp_file, char);
        row(col_i).red :=
        STD_LOGIC_VECTOR(to_unsigned(CHARACTER'pos(char), 8));

        RAM(ram_address) <= row(col_i).red & row(col_i).green & row(col_i).blue;
        ram_address := ram_address + 1;
      END LOOP;

      FOR i IN 1 TO padding LOOP
        read(bmp_file, char);
      END LOOP;

      image(row_i) := row;

    END LOOP;

    REPORT "image read";

    FOR i IN 0 TO ram_address LOOP
      r_in <= RAM(i)(23 DOWNTO 16);
      g_in <= RAM(i)(15 DOWNTO 8);
      b_in <= RAM(i)(7 DOWNTO 0);
      WAIT FOR 10 ns;

      RAM(i) <= r_out & g_out & b_out;
    END LOOP;

    PresentState <= 2;
    nextstate <= 0;

    --Tulis header ke file output
    FOR i IN header_type'RANGE LOOP
      write(out_file, header(i));
    END LOOP;

    FOR i IN 0 TO ram_address LOOP
      -- haha_RAM_FUNNY := ram_address - i;
      -- write(out_file, CHARACTER'val(to_integer(unsigned(RAM(haha_RAM_FUNNY)(7 DOWNTO 0)))));
      -- write(out_file, CHARACTER'val(to_integer(unsigned(RAM(haha_RAM_FUNNY)(15 DOWNTO 8)))));
      -- write(out_file, CHARACTER'val(to_integer(unsigned(RAM(haha_RAM_FUNNY)(23 DOWNTO 16)))));

      write(out_file, CHARACTER'val(to_integer(unsigned(RAM(i)(7 DOWNTO 0)))));
      write(out_file, CHARACTER'val(to_integer(unsigned(RAM(i)(15 DOWNTO 8)))));
      write(out_file, CHARACTER'val(to_integer(unsigned(RAM(i)(23 DOWNTO 16)))));

      -- if i MOD 2 = 0 then
      --   write(out_file, CHARACTER'val(0));
      -- end if;

      FOR i IN 1 TO padding LOOP
        write(out_file, CHARACTER'val(0));
      END LOOP;

    END LOOP;
    deallocate(image);

    file_close(bmp_file);
    file_close(out_file);

    REPORT "Simulation done. Check ""output.bmp"" image.";
    finish;
  END PROCESS;

END ARCHITECTURE;