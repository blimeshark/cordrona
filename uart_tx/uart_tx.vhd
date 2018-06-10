
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity uart_tx is
    Generic ( baud : integer := 9600);
    Port (
         I_CLK : in STD_LOGIC;
         I_RST : in STD_LOGIC;
         I_TXSIG : in STD_LOGIC;
         
         I_TXDATA : in STD_LOGIC_VECTOR(7 downto 0);
         O_TXRDY : out STD_LOGIC;
         O_TX : out STD_LOGIC
         
     );
end uart_tx;

architecture Behavioral of uart_tx is
    signal tx_data : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal tx_state : integer := 0;
    signal tx_rdy : STD_LOGIC := '1';
    signal tx : STD_LOGIC := '1';
    signal perform_tx : STD_LOGIC := '1';
    signal trans_1 : STD_LOGIC := '0';
    signal trans_2 : STD_LOGIC := '0';

    constant BIT_PD : integer := integer(50000000 / baud); -- 100MHz clock limit    
    signal tx_clk_counter : integer := BIT_PD;
    signal tx_clk : STD_LOGIC := '0'; 
begin

    clk_gen: process (I_CLK)
    begin
            if rising_edge(I_CLK) then
                if tx_clk_counter = 0 then
                    tx_clk_counter <= BIT_PD;
                    tx_clk <= not tx_clk;
                else
                    tx_clk_counter <= tx_clk_counter - 1;
                end if;
            end if;
    end process;                

    O_TX <= tx;
    O_TXRDY <= tx_rdy;

    tx_proc: process (tx_clk, tx_state)
    begin        
        if rising_edge(tx_clk) then
            if tx_state = 0 and I_TXSIG = '1' then               
                tx_state <= 1;
                tx_data <= I_TXDATA;
                tx_rdy <= '0';
                tx <= '0';            
            elsif tx_state < 9 and tx_rdy = '0' then
                tx <= tx_data(0);
                tx_data <= '0' & tx_data(7 downto 1);
                tx_state <= tx_state + 1;
            elsif tx_state = 9 and tx_rdy = '0' then
                tx <= '1';
                tx_rdy <= '1';
                tx_data <= X"00";
            elsif tx_state = 9 and tx_rdy = '1' and I_TXSIG = '0' then
                tx_state <= 0;            
            end if;
        end if;                
    end process;      


end Behavioral;

