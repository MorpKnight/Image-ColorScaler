library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity grayscale is
  port (
    clk : in std_logic;

    r_in_gray : in std_logic_vector(7 downto 0);
    g_in_gray : in std_logic_vector(7 downto 0);
    b_in_gray : in std_logic_vector(7 downto 0);

    r_out_gray : out std_logic_vector(7 downto 0);
    g_out_gray : out std_logic_vector(7 downto 0);
    b_out_gray : out std_logic_vector(7 downto 0)
  );
end entity grayscale; 

architecture rtl of grayscale is

  signal luma : std_logic_vector(7 downto 0);

  signal r_weighted : unsigned(7 downto 0);
  signal g_weighted : unsigned(7 downto 0);
  signal b_weighted : unsigned(7 downto 0);

begin

  process(clk)
  begin
    -- This process converts an RGB image to grayscale by calculating the weighted sum of the red, green, and blue components.
    -- The weighted sum is then assigned to the 'luma' signal.
    -- Inputs:
    --   - clk: Clock signal
    --   - r_in_gray: 8-bit input signal representing the red component of the RGB image in grayscale
    --   - g_in_gray: 8-bit input signal representing the green component of the RGB image in grayscale
    --   - b_in_gray: 8-bit input signal representing the blue component of the RGB image in grayscale
    -- Outputs:
    --   - luma: 8-bit output signal representing the grayscale value of the image
    if rising_edge(clk) then
      r_weighted <= unsigned("00" & r_in_gray(7 downto 2));
      g_weighted <= unsigned("0" & g_in_gray(7 downto 1));
      b_weighted <= unsigned("0000" & b_in_gray(7 downto 4));

      luma <= std_logic_vector(r_weighted + g_weighted + b_weighted);
    end if;
  end process;

  -- This code assigns the grayscale value to the red, green, and blue output signals.
  -- The luma value is converted to a std_logic_vector and assigned to r_out_gray, g_out_gray, and b_out_gray.
  r_out_gray <= std_logic_vector(luma);
  g_out_gray <= std_logic_vector(luma);
  b_out_gray <= std_logic_vector(luma);

end architecture;