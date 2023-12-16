LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE STD.textio.ALL;

ENTITY readBMP IS
    PORT (
        clk : IN STD_LOGIC;
        rst : IN STD_LOGIC;
        start : IN STD_LOGIC;
        done : OUT STD_LOGIC;
        data : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        addr : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END ENTITY readBMP;

ARCHITECTURE readBITMAP OF readBMP IS
BEGIN

    PROCESS(clk, rst)
    BEGIN
        IF rst = '1' THEN
            done <= '0';
            data <= (OTHERS => '0');
            addr <= (OTHERS => '0');
        ELSIF rising_edge(clk) THEN
            IF start = '1' THEN
                done <= '0';
                data <= (OTHERS => '0');
                addr <= (OTHERS => '0');

                -- read bmp file
                file_open(1, "test.bmp", READ_MODE);
                file_read(1, data, 8);
                file_close(1);

                done <= '1';

            ELSIF done = '0' THEN
                data <= (OTHERS => '0');
                addr <= (OTHERS => '0');
            END IF;
        END IF;
    END PROCESS;

END ARCHITECTURE readBITMAP;