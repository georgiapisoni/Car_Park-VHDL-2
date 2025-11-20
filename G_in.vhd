library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity Gate_In is 
port (
    clk                      : in std_logic;
    nrst                     : in std_logic;
    sensor_A, sensor_B       : in std_logic;
    barrier                  : out std_logic;
    Green_Light              : out std_logic;
    Red_Light                : out std_logic;
    display                  : out std_logic_vector(6 downto 0)
);
end Gate_In;

architecture Behavioural of Gate_In is
    type state_types is (IDLE, CAR_DETECTED, CAR_ENTERING, FULL, CAR_ENTERED);
    signal current_state, next_state: state_types;          --states
    signal barrier, Green_Light, display: state_types;      --outputs

    -- Car counter
    signal car_count : integer range 0 to PARKING_CAPACITY := 0;

    begin
    seq: process(clk, nrst)
        begin   
            if(nrst='0') then
                next_state <= IDLE;
                current_state <=  IDLE;
            elsif(rising_edge(clk)) then
                current_state <= next_state;
            end if;
        end process;

    combinatory: process(clk, nrst, sensor_A, sensor_B, barrier, Green_Light, 
                            Red_Light, display)
        begin   
            case state_types is
                when IDLE =>
                    if sensor_A ='1' then
                        next_state<=CAR_DETECTED;
                end if;
                when CAR_DETECTED =>
                    if (sensor_A='0') then
                        next_state<=IDLE;
                    elsif (car_count >= PARKING_CAPACITY) then
                        next_state <= FULL;
                    elsif(sensor_B='1') then
                        next_state <= CAR_ENTERING;
                    elsif car_count >= PARKING_CAPACITY then
                        next_state <= FULL;
                    else
                        next_state <= CAR_DETECTED;
                end if;
                when CAR_ENTERING =>
                    if(sensor_A='0' and sensor_B='1') then
                        next_state <= CAR_ENTERED;
                    elsif (sensor_A='1' and sensor_B='0') then
                        next_state <= CAR_DETECTED;
                    else
                        next_state <= CAR_ENTERING;
                end if;
                when CAR_ENTERED =>
                    if sensor_B = '1' then
                        next_state <= CAR_ENTERED;
                    else
                        next_state <= IDLE; 
                end if;
                when FULL =>
                    if sensor_A = '0' or car_count < PARKING_CAPACITY then --A CAR EXITED IN THE WHILE
                        next_state <= IDLE;
                    else
                        next_state <= FULL;
                    end if;
                end case;
    end process;
    
end architecture;

