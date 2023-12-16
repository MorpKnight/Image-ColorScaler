library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity grayscale is
  port (
    -- Clock Input
    clk : in std_logic;

    -- RGB input
    r_in : in std_logic_vector(7 downto 0);
    g_in : in std_logic_vector(7 downto 0);
    b_in : in std_logic_vector(7 downto 0);

    -- RGB output
    r_out : out std_logic_vector(7 downto 0);
    g_out : out std_logic_vector(7 downto 0);
    b_out : out std_logic_vector(7 downto 0)
  );
end grayscale; 

architecture rtl of grayscale is

  signal luma : std_logic_vector(7 downto 0);

  signal r_weighted : unsigned(7 downto 0);
  signal g_weighted : unsigned(7 downto 0);
  signal b_weighted : unsigned(7 downto 0);

begin

  process(clk)
  begin
    if rising_edge(clk) then
      r_weighted <= unsigned("00" & r_in(7 downto 2));
      g_weighted <= unsigned("0" & g_in(7 downto 1));
      b_weighted <= unsigned("0000" & b_in(7 downto 4));

      -- Referensi en.wikipedia.org/wiki/Grayscale
      luma <= std_logic_vector(r_weighted + g_weighted + b_weighted);
    end if;
  end process;

  r_out <= std_logic_vector(luma);
  g_out <= std_logic_vector(luma);
  b_out <= std_logic_vector(luma);

end architecture;