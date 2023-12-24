LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY CPU IS
    PORT (
        CPU_CLK : IN STD_LOGIC;
        ENABLE : IN STD_LOGIC;
        INSTRUCTION_IN : IN STD_LOGIC_VECTOR(49 DOWNTO 0)
    );
END ENTITY CPU;

ARCHITECTURE rtl OF CPU IS
    COMPONENT DECODER IS
        PORT (
            PROGRAM_COUNTER : IN INTEGER;
            INSTRUCTION : IN STD_LOGIC_VECTOR(0 TO 49);
            OPCODE : OUT STD_LOGIC_VECTOR(0 TO 5)
        );
    END COMPONENT DECODER;

    COMPONENT ALU IS
        PORT (
            CLK : IN STD_LOGIC;
            PC_ALU : IN INTEGER;
            OPCODE_ALU : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
            DONE : OUT STD_LOGIC
        );
    END COMPONENT ALU;

    TYPE State_type IS (IDLE, FETCH, DECODE, READ, EXECUTE, COMPLETE);
    SIGNAL state : State_type := IDLE;

    SIGNAL PC : INTEGER := 0;
    SIGNAL opcode, opcode_in : STD_LOGIC_VECTOR(5 DOWNTO 0);
    SIGNAL done : STD_LOGIC;

BEGIN

    DECODER_HAHA : DECODER PORT MAP(PC, INSTRUCTION_IN, opcode);

    PROCESS (CPU_CLK) IS
    BEGIN
        IF rising_edge(CPU_CLK) THEN
            IF ENABLE = '1' THEN
                CASE state IS
                    WHEN IDLE =>
                        PC <= PC + 1;
                        IF PC = 1 THEN
                            state <= FETCH;
                        END IF;
                    WHEN FETCH =>
                        PC <= PC + 1;
                        IF PC = 2 THEN
                            state <= DECODE;
                        END IF;
                    WHEN DECODE =>
                        PC <= PC + 1;
                        IF PC = 3 THEN
                            state <= READ;
                        END IF;
                    WHEN READ =>
                        opcode_in <= opcode;
                        PC <= PC + 1;
                        IF PC = 4 THEN
                            state <= EXECUTE;
                        END IF;
                    WHEN EXECUTE =>
                        PC <= PC + 1;
                        IF PC = 5 THEN
                            state <= COMPLETE;
                        END IF;
                    WHEN COMPLETE =>
                        PC <= 0;
                        state <= IDLE;
                END CASE;
            END IF;
        END IF;
    END PROCESS;
END ARCHITECTURE rtl;