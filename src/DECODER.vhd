library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity DECODER is
    port (
        PROGRAM_COUNTER : in integer;
        INS : in std_logic_vector(49 downto 0);
        OPCODE : out std_logic_vector(5 downto 0);
        FILENAME: out 
    );
end entity DECODER;

architecture DECODE of DECODER is
    
begin
    
    DEC: process(PROGRAM_COUNTER)
    begin
        OPCODE <= INS(49 downto 44);
        FIRST_ADDRESS <= INS(43 downto 21);
        LAST_ADDRESS <= INS(20 downto 0);
    end process DEC;
    
end architecture DECODE;