LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY invert IS
    PORT (
        -- Clock Input
        clk : IN STD_LOGIC;

        -- RGB input
        r_in : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        g_in : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        b_in : IN STD_LOGIC_VECTOR(7 DOWNTO 0);

        -- RGB output
        r_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        g_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        b_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
    );
END invert;

ARCHITECTURE rtl OF invert IS

    SIGNAL luma : STD_LOGIC_VECTOR(7 DOWNTO 0);

    SIGNAL r_weighted : unsigned(7 DOWNTO 0);
    SIGNAL g_weighted : unsigned(7 DOWNTO 0);
    SIGNAL b_weighted : unsigned(7 DOWNTO 0);

BEGIN

    PROCESS (clk)
    BEGIN
        IF rising_edge(clk) THEN
            r_weighted <= 255 - unsigned(r_in(7 DOWNTO 0));
            g_weighted <= 255 - unsigned(g_in(7 DOWNTO 0));
            b_weighted <= 255 - unsigned(b_in(7 DOWNTO 0));

            luma <= STD_LOGIC_VECTOR(r_weighted + g_weighted + b_weighted);
        END IF;
    END PROCESS;

    r_out <= STD_LOGIC_VECTOR(luma);
    g_out <= STD_LOGIC_VECTOR(luma);
    b_out <= STD_LOGIC_VECTOR(luma);

END ARCHITECTURE;