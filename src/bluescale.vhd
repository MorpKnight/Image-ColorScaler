library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bluescale is
    port (
        clk : in std_logic;
        r_in_blue : in std_logic_vector(7 downto 0);
        g_in_blue : in std_logic_vector(7 downto 0);
        b_in_blue : in std_logic_vector(7 downto 0);

        r_out_blue : out std_logic_vector(7 downto 0);
        g_out_blue : out std_logic_vector(7 downto 0);
        b_out_blue : out std_logic_vector(7 downto 0)
    );
end entity bluescale;

architecture rtl of bluescale is

    signal r_weighted : unsigned(7 downto 0);
    signal g_weighted : unsigned(7 downto 0);
    signal b_weighted : unsigned(7 downto 0);

begin
    process(clk)
    begin
        -- This process is triggered on the rising edge of the clk signal. It performs blue scaling by multiplying the input blue color values (r_in_blue, g_in_blue, b_in_blue) with the corresponding weights and then resizing the result to match the length of the weighted signals (r_weighted, g_weighted, b_weighted).
        if rising_edge(clk) then
            r_weighted <= resize(unsigned(r_in_blue) * to_unsigned(28, 8)/255, r_weighted'length);
            g_weighted <= resize(unsigned(g_in_blue) * to_unsigned(72, 8)/255, g_weighted'length);
            b_weighted <= resize(unsigned(b_in_blue) * to_unsigned(255, 8)/255, b_weighted'length);
        end if;
    end process;

    -- Assign the weighted values of red, green, and blue to the output signals
        r_out_blue <= std_logic_vector(r_weighted);
        g_out_blue <= std_logic_vector(g_weighted);
        b_out_blue <= std_logic_vector(b_weighted);

end architecture;
