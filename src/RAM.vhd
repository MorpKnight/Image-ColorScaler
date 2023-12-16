library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity RAM is
    port (
        PROGRAM_COUNTER: out integer;
        RAM_WRITE: in std_logic;
        RAM_ADDR: in integer range 0 to 2073600
    );
end entity RAM;

architecture RAMCOMP of RAM is
    type RAM_TYPE is array (0 to 2073600) of std_logic_vector(23 downto 0);
    signal RAM: RAM_TYPE := (others => (others => '0'));
begin
    
    process (RAM_WRITE)
    begin
        if RAM_WRITE = '1' then
            for i in 0 to 2073600 loop
                RAM(i) <= std_logic_vector(to_unsigned(i, 24));
            end loop;
        end if;
    end process;
    
end architecture RAMCOMP;