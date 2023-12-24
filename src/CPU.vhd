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
            INSTRUCTION : IN STD_LOGIC_VECTOR(49 DOWNTO 0);
            OPCODE : OUT STD_LOGIC_VECTOR(5 DOWNTO 0)
        );
    END COMPONENT DECODER;

    COMPONENT ALU IS
        PORT (
            CLK : IN STD_LOGIC;
            OPCODE : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
            DONE : OUT STD_LOGIC
        );
    END COMPONENT ALU;

    -- SIGNAL opcode : STD_LOGIC_VECTOR(5 DOWNTO 0);
    -- SIGNAL filename : STD_LOGIC_VECTOR(44 DOWNTO 0);
    -- SIGNAL ram_addr : INTEGER RANGE 0 TO 2073600;
    -- SIGNAL done : STD_LOGIC;
    SIGNAL opcode : STD_LOGIC_VECTOR(5 DOWNTO 0);
    SIGNAL done : STD_LOGIC := '0';

    TYPE State_type IS (IDLE, FETCH, DECODE, READ, EXECUTE, COMPLETE);
    SIGNAL state : State_type := IDLE;
    SIGNAL PC : INTEGER := 0;

BEGIN

    DECODER_HAHA : ENTITY WORK.DECODER
        PORT MAP(
            PROGRAM_COUNTER => counter,
            INSTRUCTION => INSTRUCTION_IN,
            OPCODE => opcode
        );

    ALU_HAHA : ENTITY WORK.ALU
        PORT MAP(
            CLK => CPU_CLK,
            OPCODE => opcode,
            DONE => done
        );

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