library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Registers is
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           wr : in STD_LOGIC;
           reg1_rd : in STD_LOGIC_VECTOR (4 downto 0);
           reg2_rd : in STD_LOGIC_VECTOR (4 downto 0);
           reg_wr : in STD_LOGIC_VECTOR (4 downto 0);
           data_wr : in STD_LOGIC_VECTOR (31 downto 0);
           data1_rd : out STD_LOGIC_VECTOR (31 downto 0);
           data2_rd : out STD_LOGIC_VECTOR (31 downto 0));
end Registers;

architecture Behavioral of Registers is
type Registros is array (0 to 31) of STD_LOGIC_VECTOR (31 downto 0);
signal reg: Registros;

begin
    process(clk,reset) begin
        if ( reset = '1' ) then
            for i in 0 to 31 loop
                reg(i) <= (others => '0');
            end loop; 
        elsif ( falling_edge(clk) and wr = '1' ) then
            reg ( conv_integer(reg_wr) ) <= data_wr;
       end if;       
    end process;

    data1_rd <= reg(conv_integer(reg1_rd));
    data2_rd <= reg(conv_integer(reg2_rd));
    
end Behavioral;