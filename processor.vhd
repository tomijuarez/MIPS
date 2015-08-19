library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity processor is
port(
	Clk         : in  std_logic;
	Reset       : in  std_logic;
	-- Instruction memory
	--SI EN EL TESTBENCH NO ESTA LA ENTRADA CONSTANTEMENTE EN CERO, PONERLO PARA ASEGURARME DE WARNINGS
	I_Addr      : out std_logic_vector(31 downto 0);
	I_RdStb     : out std_logic;
	I_WrStb     : out std_logic;
	I_DataOut   : out std_logic_vector(31 downto 0);
	I_DataIn    : in  std_logic_vector(31 downto 0);
	-- Data memory
	D_Addr      : out std_logic_vector(31 downto 0);
	D_RdStb     : out std_logic;
	D_WrStb     : out std_logic;
	D_DataOut   : out std_logic_vector(31 downto 0);
	D_DataIn    : in  std_logic_vector(31 downto 0)
);
end processor;

architecture processor_arq of processor is 
    --declaracion control
    component control
        Port ( IF_ID_INSTR : in  STD_LOGIC_VECTOR (5 downto 0);
               RegDest     : out STD_LOGIC;
               AluSrc      : out STD_LOGIC;
               MemToReg    : out STD_LOGIC;
               ALUOp       : out STD_LOGIC_VECTOR (2 downto 0);
               Branch      : out STD_LOGIC;
               RdMem       : out STD_LOGIC;
               WrMem       : out STD_LOGIC;
               WrReg       : out STD_LOGIC);
    end component;    
    
    --Declaracion del banco de registros
    component Registers
    Port ( clk : in STD_LOGIC;
               reset : in STD_LOGIC;
               wr : in STD_LOGIC;
               reg1_rd : in STD_LOGIC_VECTOR (4 downto 0);
               reg2_rd : in STD_LOGIC_VECTOR (4 downto 0);
               reg_wr : in STD_LOGIC_VECTOR (4 downto 0);
               data_wr : in STD_LOGIC_VECTOR (31 downto 0);
               data1_rd : out STD_LOGIC_VECTOR (31 downto 0);
               data2_rd : out STD_LOGIC_VECTOR (31 downto 0));
      end component; 
      
      --Alu
    component alu
          Port ( a       : in  STD_LOGIC_VECTOR (31 downto 0);
                 b       : in  STD_LOGIC_VECTOR (31 downto 0);
                 control : in  STD_LOGIC_VECTOR (2 downto 0);
                 result  : out STD_LOGIC_VECTOR (31 downto 0);
                 zero    : out STD_LOGIC);
      end component;          

    --Etapa 1
        --PC
        signal PC_IN: std_logic_vector(31 downto 0);
        signal PC_OUT: std_logic_vector(31 downto 0);
        --Sumar PC
        signal PC_4: std_logic_vector(31 downto 0);
        --Mux
        signal PC_SRC: std_logic;
        --BORRAR signal EXMEM_ADDRES: std_logic_vector (31 downto 0); --Resultado de la suma (add) que se guarda en el tercer registro, al final de la etapa 3
        --Reg IF/ID
        signal IFID_PC4: std_logic_vector(31 downto 0);
        signal  IFID_MEM_OUT: std_logic_vector (31 downto 0);
      
 	--Etapa 2
 		--Control
 		signal COD_OP: std_logic_vector (5 downto 0);	
		signal RW: std_logic; -- write enable para registro
 		signal MEMAREG: std_logic; --memareg para ultima etapa
 		signal B: std_logic; --para el branch
 		signal MR: std_logic; -- read en memoria
 		signal MW: std_logic; --write en memoria
 		signal ALUOP: std_logic_vector (2 downto 0); --a control de alu op
 		signal ALUSRC: std_logic; -- para el inmediato va 1 y el otro 0
 		signal REGDST: std_logic; 		
 		--Reg ID/EX
			--lo que guardo del control
			signal IDEX_RW: std_logic; -- write enable para registro
			signal IDEX_MEMAREG: std_logic; --memareg para ultima etapa
			signal IDEX_B: std_logic; --para el branch
			signal IDEX_MR: std_logic; -- read en memoria
			signal IDEX_MW: std_logic; --write en memoria
			signal IDEX_ALUOP: std_logic_vector (2 downto 0); --a control de alu op
			signal IDEX_ALUSRC: std_logic; -- para el inmediato va 1 y el otro 0
			signal IDEX_REGDST: std_logic; -- registro donde se guarda, cambia en el imd
			--lo que guarda de los registros
			signal IDEX_READ1: std_logic_vector (31 downto 0);
			signal IDEX_READ2: std_logic_vector (31 downto 0);		
			--guardado del signo extendido
			signal IDEX_SE: std_logic_vector (31 downto 0);
			--registros para operar 
			signal IDEX_RT: std_logic_vector (4 downto 0); --de 20 a 16
			signal IDEX_RD: std_logic_vector (4 downto 0); --de 15 a 11
			--pc+4
			signal IDEX_PC4: std_logic_vector (31 downto 0); --copia el de IFID
			
		--extension de signo 	
		signal INMEDIATO: std_logic_vector (15 downto 0); -- valor inmediato que viene en la instruccion
 		signal SE: std_logic_vector (31 downto 0); 
 		--Registros
 		signal READ1: std_logic_vector (31 downto 0); --salida 1
 		signal READ2: std_logic_vector (31 downto 0); --salida 2
 		
 		
 	
 	--Etapa 3
 	  signal MUX_REGDEST: std_logic_vector(4 downto 0);
 	  signal MUX_ALU: std_logic_vector (31 downto 0);
 	  signal SHIFTL2: std_logic_vector (31 downto 0);
 	  signal RESADD: std_logic_vector (31 downto 0);
 	  
 	  --ALU
 	  signal ALUCTR: std_logic_vector (2 downto 0); --SALE DE ALU CONTROL
 	  signal ALU_OUT: std_logic_vector (31 downto 0);
 	  signal ZERO: std_logic;

      --Registro EX_MEM
      signal EXMEM_MW : std_logic;
      signal EXMEM_MR: std_logic;
      signal EXMEM_MEMAREG: std_logic;
      signal EXMEM_RW: std_logic;
      signal EXMEM_B: std_logic;
      signal EXMEM_ALURES: std_logic_vector (31 downto 0);
      signal EXMEM_ZERO: std_logic;
      signal EXMEM_ADDRES: std_logic_vector (31 downto 0);
      signal EXMEM_READ2: std_logic_vector (31 downto 0);
      signal EXMEM_REGDEST: std_logic_vector (4 downto 0);
      
    --Etapa 4
      --Registro Mem_WB
      signal MEMWB_RW: std_logic;
      signal MEMWB_MEMAREG: std_logic;
      signal MEMWB_READMEM: std_logic_vector (31 downto 0);
      signal MEMWB_ALURES: std_logic_vector (31 downto 0);
      signal MEMWB_REGDEST: std_logic_vector (4 downto 0);
      
      --Salida del mux final
      signal DATAW: std_logic_vector (31 downto 0);
              
begin 	
    --Etapa 1
        --Pc
        process (Clk, Reset)
        begin
            if Reset = '1' then
                PC_OUT <= (others =>'0');
            elsif rising_edge(Clk) then
                PC_OUT <= PC_IN; -- ver!
            end if;
        end process;
        
        I_Addr <= PC_OUT;
        I_RdStb <= '1';
        I_WrStb <= '0';
        I_DataOut <= (others =>'0');
        --Sumar PC
        PC_4 <= PC_OUT + 4;
        
        --Multiplexor
        PC_IN <= PC_4 when PC_SRC = '0' else EXMEM_ADDRES; 
        
        --Registro IF/ID
        process (Clk, Reset)
        begin
            if Reset ='1' then
                IFID_PC4 <= (others => '0');
                IFID_MEM_OUT <= (others => '0');
            elsif rising_edge(Clk) then
                IFID_PC4 <= PC_4;
                IFID_MEM_OUT <= I_DataIn;
            end if;
        end process;
        
-----------------------------------------------------------------------------------------------
    --intanciar control
    UnidadDeControl: control port map(
        IF_ID_INSTR => IFID_MEM_OUT(31 downto 26),
        RegDest     => REGDST,
        AluSrc      => ALUSRC,
        MemToReg    => MEMAREG,
        ALUOp       => ALUOP,
        Branch      => B,
        RdMem       => MR,
        WrMem       => MW,
        WrReg       => RW
    );
		--Guardado en IDEX
		process (Clk, Reset)
		begin
			if (Reset='1') then
			    IDEX_RW <=  '0';
			    IDEX_MR <= '0';
			    IDEX_B <= '0';
			    IDEX_MW <= '0';
			    IDEX_MEMAREG <= '0';
			    IDEX_ALUOP <= (others => '0');
			    IDEX_ALUSRC <= '0';
			    IDEX_REGDST<= '0';
			    IDEX_SE<= (others => '0');
			    IDEX_READ1<= (others => '0');
			    IDEX_READ2<= (others => '0');
			    IDEX_PC4<= (others => '0');
			    IDEX_RT<= (others => '0');
			    IDEX_RD<= (others => '0');     
			elsif(rising_edge (Clk)) then
				IDEX_RW <= RW;
				IDEX_MR <= MR;
				IDEX_B <=  B;
				IDEX_MW <= MW;
				IDEX_MEMAREG <= MEMAREG;
				IDEX_ALUOP <= ALUOP;
				IDEX_ALUSRC <= ALUSRC;
				IDEX_REGDST <= REGDST;
				IDEX_SE <= SE;
				IDEX_READ1 <=READ1;
				IDEX_READ2 <= READ2;
				IDEX_PC4 <= IFID_PC4;
				IDEX_RT <= IFID_MEM_OUT (20 downto 16);
				IDEX_RD <= IFID_MEM_OUT (15 downto 11);
			end if;
		end process;	
				
		--Extension de Signo      
		INMEDIATO  <= IFID_MEM_OUT (15 downto 0);
		SE(31 downto 16) <= (others => '1') when INMEDIATO(15)='1' else (others => '0');
		SE(15 downto 0) <= INMEDIATO; 
		
		--Registers
		--instaciacion
		BancoDeRegistros: Registers port map(
            clk      => Clk,                       
            reset    => Reset,                     
            wr       => MEMWB_RW,           
            reg1_rd  => IFID_MEM_OUT(25 downto 21), 
            reg2_rd  => IFID_MEM_OUT(20 downto 16), 
            reg_wr   => MEMWB_REGDEST,           
            data_wr  => DATAW,                 
            data1_rd => READ1,            
            data2_rd => READ2             		
		);
		
-----------------------------------------------------------------------------------------------

    --ETAPA 3
        --reg dest mux
        MUX_REGDEST <= IDEX_RT when IDEX_REGDST ='0' else IDEX_RD;
        --ENTRADA ALU MUX
        MUX_ALU <= IDEX_READ2 when IDEX_ALUSRC ='0' else IDEX_SE;
        --shift left 2
        SHIFTL2 <= IDEX_SE (29 downto 0) & "00";
        --sumador
        RESADD <= IDEX_PC4 + SHIFTL2;
        --CONTROL DE LA ALU
        process(ALUOP, IDEX_SE)
        begin
          if(ALUOP = "011")then
              case IDEX_SE(5 downto 0) is
                when "100000" =>
                    ALUCTR <= "010";
                when "100010" =>
                    ALUCTR <= "110";
                when "100100" =>
                    ALUCTR <= "000";
                when "100101" =>
                    ALUCTR <= "001";
                when "101010" =>
                    ALUCTR <= "111";
                when others => 
                    ALUCTR <= "101";
              end case;
          else
            ALUCTR <= ALUOP;
          end if;
        end process;
        
        
        --Alu
            ComponenteALU: alu port map (
            a       => IDEX_READ1,
            b       => MUX_ALU,
            control => ALUCTR, 
            result  => ALU_OUT,
            zero    => ZERO
        );
        
        process (Clk, Reset)
        begin
            if (Reset ='1') then
                EXMEM_MR <=  '0';
                EXMEM_MW <= '0';
                EXMEM_RW <= '0';
                EXMEM_B <= '0';
                EXMEM_ALURES <= (others => '0'); 
                EXMEM_ADDRES <= (others => '0');
                EXMEM_REGDEST <= (others => '0');
                EXMEM_ZERO  <= '0';
                EXMEM_READ2 <= (others => '0');
                EXMEM_MEMAREG <= '0';              
            elsif ( rising_edge(Clk) ) then
                EXMEM_MR <= IDEX_MR;
                EXMEM_MW <= IDEX_MW;
                EXMEM_RW <= IDEX_RW;
                EXMEM_B <= IDEX_B;
                EXMEM_ALURES <= ALU_OUT; 
                EXMEM_ADDRES <= RESADD;
                EXMEM_REGDEST <= MUX_REGDEST;
                EXMEM_ZERO  <= ZERO;
                EXMEM_READ2 <= IDEX_READ2;
                EXMEM_MEMAREG <= IDEX_MEMAREG;  
            end if;
        end process;
        
-----------------------------------------------------------------------------------------------

    --Etapa 4        
     PC_SRC <= EXMEM_B and EXMEM_ZERO;
     
     D_Addr    <= EXMEM_ALURES;
     D_RdStb   <= EXMEM_MR;
     D_WrStb   <= EXMEM_MW;
     D_DataOut <= EXMEM_READ2;         
            
     process (Clk, Reset)
     begin
        if(Reset ='1') then
            MEMWB_RW<= '0';  
            MEMWB_MEMAREG<= '0';  
            MEMWB_READMEM<= (others => '0');  
            MEMWB_ALURES<= (others => '0');  
            MEMWB_REGDEST<= (others => '0');  
        elsif (rising_edge(Clk)) then
            MEMWB_RW<= EXMEM_RW;  
            MEMWB_MEMAREG<= EXMEM_MEMAREG ;  
            MEMWB_READMEM<= D_DataIn;  
            MEMWB_ALURES<= EXMEM_ALURES;  
            MEMWB_REGDEST<= EXMEM_REGDEST;          
        end if;
    end process;
    
    --etapa 5
     DATAW <=  MEMWB_ALURES when MEMWB_MEMAREG ='0' else MEMWB_READMEM; 
     
end processor_arq;
