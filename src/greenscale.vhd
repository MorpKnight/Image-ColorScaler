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
        -- This process is triggered on the rising edge of the clk signal. It performs green scaling by multiplying the green component of the input RGB values with the corresponding weight and then resizing the result to match the length of the weighted signal. The weights used are 28/255 for the red component, 255/255 for the green component, and 28/255 for the blue component.
        if rising_edge(clk) then
            r_weighted <= resize(unsigned(r_in_green) * to_unsigned(28, 8)/255, r_weighted'length);
            g_weighted <= resize(unsigned(g_in_green) * to_unsigned(255, 8)/255, g_weighted'length);
            b_weighted <= resize(unsigned(b_in_green) * to_unsigned(28, 8)/255, b_weighted'length);
        end if;
    end process;

    -- This code assigns the weighted values of the green channel to the output signals.
    -- r_out_green: Output signal for the red channel after green scaling.
    -- g_out_green: Output signal for the green channel after green scaling.
    -- b_out_green: Output signal for the blue channel after green scaling.
    r_out_green <= std_logic_vector(r_weighted);
    g_out_green <= std_logic_vector(g_weighted);
    b_out_green <= std_logic_vector(b_weighted);

end architecture;
