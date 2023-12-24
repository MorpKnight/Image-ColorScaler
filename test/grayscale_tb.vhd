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

  -- UUT signals
  SIGNAL r_in : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL g_in : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL b_in : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL r_out : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL g_out : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL b_out : STD_LOGIC_VECTOR(7 DOWNTO 0);

  -- Clock signal
  -- signal clk : std_logic := '0';

  -- -- Clock generator
  -- component clock_gen is
  --   port (
  --     clk : out std_logic
  --   );
  -- end component;

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
    FILE bmp_file : char_file OPEN read_mode IS "PICT.bmp";
    FILE out_file : char_file OPEN write_mode IS "PICT_out.bmp";
    VARIABLE header : header_type;
    VARIABLE image_width : INTEGER;
    VARIABLE image_height : INTEGER;
    VARIABLE row : row_pointer;
    VARIABLE image : image_pointer;
    VARIABLE padding : INTEGER;
    VARIABLE char : CHARACTER;
  BEGIN

    --Baca header
    FOR i IN header_type'RANGE LOOP
      read(bmp_file, header(i));
    END LOOP;

    PresentState <= 0;
    NextState <= 1;

    --Cek header, jika bukan BMP, keluar
    ASSERT header(0) = 'B' AND header(1) = 'M'
    REPORT "NOT A BMP FILE"
      SEVERITY failure;

    --Cek header, jika bukan 54-byte, keluar
    ASSERT CHARACTER'pos(header(10)) = 54 AND
    CHARACTER'pos(header(11)) = 0 AND
    CHARACTER'pos(header(12)) = 0 AND
    CHARACTER'pos(header(13)) = 0
    REPORT "Header is not 54 bytes"
      SEVERITY failure;

    --Cek header, jika bukan 40-byte dib header, keluar
    ASSERT CHARACTER'pos(header(14)) = 40 AND
    CHARACTER'pos(header(15)) = 0 AND
    CHARACTER'pos(header(16)) = 0 AND
    CHARACTER'pos(header(17)) = 0
    REPORT "DIB headers size is not 40 bytes"
      SEVERITY failure;

    --Cek header, jika bukan 24-bit dib header, keluar
    ASSERT CHARACTER'pos(header(28)) = 24 AND
    CHARACTER'pos(header(29)) = 0
    REPORT "Bits per pixel is not 24" SEVERITY failure;

    --Dapatkan ukuran gambar
    --Lebar
    image_width := CHARACTER'pos(header(18)) +
      CHARACTER'pos(header(19)) * 2 ** 8 +
      CHARACTER'pos(header(20)) * 2 ** 16 +
      CHARACTER'pos(header(21)) * 2 ** 24;

    --Tinggi
    image_height := CHARACTER'pos(header(22)) +
      CHARACTER'pos(header(23)) * 2 ** 8 +
      CHARACTER'pos(header(24)) * 2 ** 16 +
      CHARACTER'pos(header(25)) * 2 ** 24;

    REPORT "image_width: " & INTEGER'image(image_width) &
      ", image_height: " & INTEGER'image(image_height);

    --Padding didapat dengan 4 - (lebar * 3) mod 4
    padding := (4 - image_width * 3 MOD 4) MOD 4;

    --Untuk persiapan menulis ke image output
    image := NEW image_type(0 TO image_height - 1);

    PresentState <= 1;
    NextState <= 2;

    --Baca pixel dalam tinggi gambar
    FOR row_i IN 0 TO image_height - 1 LOOP

      --Buat row baru
      row := NEW row_type(0 TO image_width - 1);

      --Baca pixel dalam tinggi gambar
      FOR col_i IN 0 TO image_width - 1 LOOP

        --Baca pixel biru
        read(bmp_file, char);
        row(col_i).blue :=
        STD_LOGIC_VECTOR(to_unsigned(CHARACTER'pos(char), 8));

        --Baca pixel hijau
        read(bmp_file, char);
        row(col_i).green :=
        STD_LOGIC_VECTOR(to_unsigned(CHARACTER'pos(char), 8));

        --Baca pixel merah
        read(bmp_file, char);
        row(col_i).red :=
        STD_LOGIC_VECTOR(to_unsigned(CHARACTER'pos(char), 8));

      END LOOP;

      --Baca padding
      FOR i IN 1 TO padding LOOP
        read(bmp_file, char);
      END LOOP;

      image(row_i) := row;

    END LOOP;

    FOR row_i IN 0 TO image_height - 1 LOOP
      row := image(row_i);

      FOR col_i IN 0 TO image_width - 1 LOOP

        r_in <= row(col_i).red;
        g_in <= row(col_i).green;
        b_in <= row(col_i).blue;
        WAIT FOR 10 ns;

        row(col_i).red := r_out;
        row(col_i).green := g_out;
        row(col_i).blue := b_out;

      END LOOP;
    END LOOP;

    PresentState <= 2;
    nextstate <= 0;

    --Tulis header ke file output
    FOR i IN header_type'RANGE LOOP
      write(out_file, header(i));
    END LOOP;

    FOR row_i IN 0 TO image_height - 1 LOOP
      row := image(row_i);

      FOR col_i IN 0 TO image_width - 1 LOOP

        --Tulis pixel biru ke file output
        write(out_file,
        CHARACTER'val(to_integer(unsigned(row(col_i).blue))));

        --Tulis pixel hijau ke file output
        write(out_file,
        CHARACTER'val(to_integer(unsigned(row(col_i).green))));

        --Tulis pixel merah ke file output
        write(out_file,
        CHARACTER'val(to_integer(unsigned(row(col_i).red))));

      END LOOP;

      deallocate(row);

      --Tulis padding ke file output
      FOR i IN 1 TO padding LOOP
        write(out_file, CHARACTER'val(0));
      END LOOP;

    END LOOP;

    deallocate(image);

    file_close(bmp_file);
    file_close(out_file);

    REPORT "Simulation done. Check ""output.bmp"" image.";
    -- finish;
  END PROCESS;

END ARCHITECTURE;