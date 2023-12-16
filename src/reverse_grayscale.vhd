library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity reverse_grayscale is
    port(
        input : in STD_LOGIC_VECTOR(23 downto 0)
    );
end entity reverse_grayscale;

architecture behavioral of reverse_grayscale is
begin
    alu_process : process (input)
        variable r, g, b : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
        variable r_int, g_int, b_int : integer := 0;
    begin
        r := input(23 downto 16);
        g := input(15 downto 8);
        b := input(7 downto 0);

        r_int := ((to_integer(unsigned(r)))*1000)/299;
        g_int := ((to_integer(unsigned(g)))*1000)/587;
        b_int := ((to_integer(unsigned(b)))*1000)/114; 

        r := std_logic_vector(to_unsigned(r_int, r'length));
        g := std_logic_vector(to_unsigned(g_int, g'length));
        b := std_logic_vector(to_unsigned(b_int, b'length));
    end process alu_process;
end architecture behavioral;