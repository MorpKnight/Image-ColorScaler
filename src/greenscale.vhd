library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity greenscale is
    port (
        clk : in std_logic;
        r_in_green : in std_logic_vector(7 downto 0);
        g_in_green : in std_logic_vector(7 downto 0);
        b_in_green : in std_logic_vector(7 downto 0);

        r_out_green : out std_logic_vector(7 downto 0);
        g_out_green : out std_logic_vector(7 downto 0);
        b_out_green : out std_logic_vector(7 downto 0)
    );
end entity greenscale;

architecture rtl of greenscale is

    signal r_weighted : unsigned(7 downto 0);
    signal g_weighted : unsigned(7 downto 0);
    signal b_weighted : unsigned(7 downto 0);

begin
    process(clk)
    begin
        if rising_edge(clk) then
            r_weighted <= resize(unsigned(r_in_green) * to_unsigned(28, 8)/255, r_weighted'length);
            g_weighted <= resize(unsigned(g_in_green) * to_unsigned(255, 8)/255, g_weighted'length);
            b_weighted <= resize(unsigned(b_in_green) * to_unsigned(28, 8)/255, b_weighted'length);
        end if;
    end process;

    r_out_green <= std_logic_vector(r_weighted);
    g_out_green <= std_logic_vector(g_weighted);
    b_out_green <= std_logic_vector(b_weighted);

end architecture;
