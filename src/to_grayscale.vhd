library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity to_grayscale is
  port(
    input : in  STD_LOGIC_VECTOR(23 downto 0);
    output_r : out STD_LOGIC_VECTOR(7 downto 0);
    output_g : out STD_LOGIC_VECTOR(7 downto 0);
    output_b : out STD_LOGIC_VECTOR(7 downto 0)
  );
end entity to_grayscale;

architecture behavioral of to_grayscale is
begin
  alu_process : process (input)
    variable gray_int : integer := 0;
    variable gray : STD_LOGIC_VECTOR(23 downto 0) := (others => '0');
  begin
    -- Calculate grayscale intensity using standard formula
    gray_int := ((to_integer(unsigned(input))) * 299 +
                  to_integer(unsigned(input(22 downto 15))) * 587 +
                  to_integer(unsigned(input(14 downto 7))) * 114) / 1000;

    -- Convert integer to unsigned 24-bit value
    gray := std_logic_vector(to_unsigned(gray_int, gray'length));

    -- Output grayscale value
    output_r <= gray(23 downto 16);
    output_g <= gray(15 downto 8);
    output_b <= gray(7 downto 0);
  end process alu_process;
end architecture behavioral;
