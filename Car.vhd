library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity Parking_Controllerz is
generic (PARKING_CAPACITY : integer := 7);
    port (

    -- Clock and Reset
    clk : in std_logic;
    nrst : in std_logic;
    
    -- Entry Gate 1 Sensors
    sensor_A_Gin1 : in std_logic; -- Before barrier
    sensor_B_Gin1 : in std_logic; -- After barrier
    
    -- Entry Gate 2 Sensors
    sensor_A_Gin2 : in std_logic;
    sensor_B_Gin2 : in std_logic;
    
    -- Exit Gate 1 Sensors
    sensor_A_Gout1 : in std_logic;
    sensor_B_Gout1 : in std_logic;

    -- Exit Gate 2 Sensors
    sensor_A_Gout2 : in std_logic;
    sensor_B_Gout2 : in std_logic;

    -- Payment Interface
    payment_done : in std_logic;
    payment_accepted : out std_logic;
    payment_request : out std_logic;

    -- Barrier Controls
    barrier_Gin1 : out std_logic; -- '1' = open
    barrier_Gin2 : out std_logic;
    barrier_Gout1 : out std_logic;
    barrier_Gout2 : out std_logic;
    
    -- Visual Indicators
    Green_Light : out std_logic;
    Red_Light : out std_logic;
    display : out std_logic_vector(6 downto 0)
    );
    
end entity;

architecture Behavioural of Parking_Controller is

    type gate_state_type is (IDLE, CAR_DETECTED, CAR_ENTERING, CAR_ENTERED);
    type exit_state_type is (IDLE, WAIT_PAYMENT, PAYMENT_OK, CAR_EXITING, CAR_EXITED);
    
    -- State signals for each gate
    signal state_Gin1, next_state_Gin1      : gate_state_type;
    signal state_Gin2, next_state_Gin2      : gate_state_type;
    signal state_Gout1, next_state_Gout1    : exit_state_type;
    signal state_Gout2, next_state_Gout2    : exit_state_type;
    
    --Signals
    -- Car counter
    signal car_count : integer range 0 to PARKING_CAPACITY := 0;
    
    -- Edge detection for sensors
    signal sensor_A_Gin1_prev, sensor_B_Gin1_prev : std_logic;
    begin
        resetting: process(clk, nrst)
        begin   
            if(nrst='0') then
                state_gin1 <= IDLE;
                state_gin2 <= IDLE; 
                state_gout1 <= IDLE;
                state_gout2 <= IDLE;
            elsif(rising_edge(clk)) then
                state_Gin1 <= next_state_Gin1;
            end if;
        end process;


    stateregister: process (clk, nrst) 
    begin
        if nrst = '0' then
            -- Reset all states to IDLE
            -- Reset sensor history
            sensor_A_Gin1_prev <= '0';
            sensor_B_Gin1_prev <= '0';

            state_Gin1_prev <= '0';
            state_Gin1_next <= '0';
            
            state_Gin2_prev <= '0';
            state_Gin2_next <= '0';
        elsif rising_edge(clk) then -- Update states
            state_Gin1 <= next_state_Gin1;
            -- ... (update others)
            -- Store sensor values for edge detection
            sensor_A_Gin1_prev <= sensor_A_Gin1;
            -- ... (store others)
        end if; 
    end process;
    transitions: process() -- <==== insert all the signals!
    begin   
        case state_gin1 is
            when IDLE =>
                if sensor_A_Gin1 ='1' then
                    next_state_gin1 <= --state of front_gin1
end architecture;