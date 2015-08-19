library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity alu is
    Port ( a       : in  STD_LOGIC_VECTOR (31 downto 0);
           b       : in  STD_LOGIC_VECTOR (31 downto 0);
           control : in  STD_LOGIC_VECTOR (2 downto 0);
           result  : out STD_LOGIC_VECTOR (31 downto 0);
           zero    : out STD_LOGIC);
end alu;

architecture Behavioral of alu is

signal aux: STD_LOGIC_VECTOR (31 downto 0);

begin
  
  process (a,b,control)
    begin
        case control is
            when "000" =>        --> AND
                aux  <= a and b;
            when "001" =>        --> OR
                aux  <= a or b;
            when "010" =>        --> SUMA
                aux  <= a + b;           
            when "110" =>        --> RESTA
                aux  <= a - b;
            when "111" =>        --> LESS
                if a < b then    
                    aux <= (0 => '1', others => '0'); --000...001 si A < B
                else
                    aux<= (others => '0');            --000...000 si A >= B
                end if;    
            when "100" =>         --> SHIFT << 16 (SHR)
                    aux <= b(15 downto 0) & x"0000";  -- AUX = B[15...0] AND x0000 (CORRO B 16 BITS A DERECHA)
            when others =>
                    aux<= (others => '0');  --DEFAULT.
            end case;        
                        
    end process;
      
    zero   <= '1' when (aux = x"00000000") else '0';
    
    result <= aux;
end Behavioral;