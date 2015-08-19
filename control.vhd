library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity control is
    Port ( IF_ID_INSTR : in  STD_LOGIC_VECTOR (5 downto 0);
           RegDest     : out STD_LOGIC;
           AluSrc      : out STD_LOGIC;
           MemToReg    : out STD_LOGIC;
           ALUOp       : out STD_LOGIC_VECTOR (2 downto 0);
           Branch      : out STD_LOGIC;
           RdMem       : out STD_LOGIC;
           WrMem       : out STD_LOGIC;
           WrReg       : out STD_LOGIC);
end control;

architecture Behavioral of control is

begin

process (IF_ID_INSTR)
begin
    case IF_ID_INSTR is
        --INSTRUCCIONES TIPO R
        WHEN "000000" =>
            RegDest  <= '1';
            AluSrc   <= '0';
            MemToReg <= '0';
            WrReg    <= '1';
            RdMem    <= '0';
            WrMem    <= '0';
            Branch   <= '0';
            ALUOp(2 downto 0) <= "011"; --INDICA A ALU CONTROL SI ES TIPO R.
        --LW
        WHEN "100011" =>
            RegDest  <= '0';
            AluSrc   <= '1';
            MemToReg <= '1';
            WrReg    <= '1';
            RdMem    <= '1';
            WrMem    <= '0';
            Branch   <= '0';
            ALUOp(2 downto 0) <= "010"; --SUMA
        --SW
        WHEN "101011" =>
            RegDest  <= '0';
            AluSrc   <= '1';
            MemToReg <= '0';
            WrReg    <= '1';
            RdMem    <= '0';
            WrMem    <= '1';
            Branch   <= '0';
            ALUOp(2 downto 0) <= "010"; --SUMA
        --BEQ
        WHEN "000100" =>
            RegDest  <= '1';
            AluSrc   <= '0';
            MemToReg <= '0';
            WrReg    <= '1';
            RdMem    <= '0';
            WrMem    <= '0';
            Branch   <= '1';
            ALUOp(2 downto 0) <= "110"; --RESTA
        --LUI
        WHEN "001111" =>
            RegDest  <= '0';
            AluSrc   <= '1';
            MemToReg <= '0';
            WrReg    <= '1';
            RdMem    <= '0';
            WrMem    <= '0';
            Branch   <= '0';
            ALUOp(2 downto 0) <= "100"; --SHIFT 16
        --ADDI
        WHEN "001000" =>
            RegDest  <= '0';
            AluSrc   <= '1';
            MemToReg <= '0';
            WrReg    <= '1';
            RdMem    <= '0';
            WrMem    <= '0';
            Branch   <= '0';
            ALUOp(2 downto 0) <= "010"; --SUMA
        --ANDI
        WHEN "001100" =>
            RegDest  <= '0';
            AluSrc   <= '1';
            MemToReg <= '0';
            WrReg    <= '1';
            RdMem    <= '0';
            WrMem    <= '0';
            Branch   <= '0';
            ALUOp(2 downto 0) <= "000"; --AND
        --ORI
        WHEN "001101" =>
            RegDest  <= '0';
            AluSrc   <= '1';
            MemToReg <= '0';
            WrReg    <= '1';
            RdMem    <= '0';
            WrMem    <= '0';
            Branch   <= '0';
            ALUOp(2 downto 0) <= "001";
        WHEN others =>
            RegDest  <= '0';
            AluSrc   <= '0';
            MemToReg <= '0';
            WrReg    <= '0';
            RdMem    <= '0';
            WrMem    <= '0';
            Branch   <= '0';
            ALUOp(2 downto 0) <= "101"; --NO HACE NADA
    end case;
end process;


end Behavioral;