LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY DECODER IS
    PORT (
        PROGRAM_COUNTER : IN INTEGER;
        INSTRUCTION : IN STD_LOGIC_VECTOR(0 TO 49);
        OPCODE : OUT STD_LOGIC_VECTOR(0 TO 5)
    );
END ENTITY DECODER;

ARCHITECTURE DECODE OF DECODER IS

BEGIN

    -- This process extracts the opcode from the instruction.
    -- Inputs:
    --   PROGRAM_COUNTER: The current program counter value.
    --   INSTRUCTION: The instruction to be decoded.
    -- Outputs:
    --   OPCODE: The extracted opcode from the instruction.
    DEC : PROCESS (PROGRAM_COUNTER, INSTRUCTION)
    BEGIN
        OPCODE <= INSTRUCTION(0 TO 5);
    END PROCESS DEC;

END ARCHITECTURE DECODE;