library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Gate_In is 
    generic (
        PARKING_CAPACITY : integer := 7
    );
    port (
        clk                      : in std_logic;
        nrst                     : in std_logic;
        sensor_A                 : in std_logic;
        sensor_B                 : in std_logic;
        can_enter                : in std_logic;  -- Signal from controller indicating spots available
        barrier                  : out std_logic;
        inc_car                  : out std_logic; -- Signal to controller to increment car count
        gate_green_light         : out std_logic; -- Individual gate green light
        gate_red_light           : out std_logic  -- Individual gate red light
    );
end Gate_In;

architecture Behavioural of Gate_In is
    type state_types is (IDLE, CAR_DETECTED, CAR_ENTERING, 
                        CAR_ENTERED, FULL);
    signal current_state, next_state: state_types;
    
begin
    -- ------state register - sequential process
    state_register: process(clk, nrst)
    begin   
        if nrst = '0' then
            current_state <= IDLE;
        elsif rising_edge(clk) then
            current_state <= next_state;
        end if;
    end process;

    -- State transition process
    state_transition: process(current_state, sensor_A, sensor_B, can_enter)
    begin
        next_state <= current_state;
        
        case current_state is
            when IDLE =>
                if sensor_A = '1' then
                    if can_enter = '1' then
                        next_state <= CAR_DETECTED;
                    else
                        next_state <= FULL;
                    end if;
                else
                    next_state <= IDLE;
                end if;
                
            when CAR_DETECTED =>
                if sensor_A = '0' then
                    next_state <= IDLE;
                elsif sensor_B = '1' then
                    next_state <= CAR_ENTERING;
                end if;
                
            when CAR_ENTERING =>
                if sensor_A = '0' and sensor_B = '1' then
                    next_state <= CAR_ENTERED;
                elsif sensor_A = '1' and sensor_B = '0' then
                    next_state <= CAR_DETECTED;
                end if;
                
            when CAR_ENTERED =>
                if sensor_B = '0' then
                    next_state <= IDLE;
                else 
                    next_state <= CAR_ENTERED;
                end if;
                
            when FULL =>
                if sensor_A = '0' then
                    next_state <= IDLE;
                elsif can_enter = '1' then         
                    next_state <= CAR_DETECTED;
                end if;
        end case;
    end process;

    -- Output process
    output_logic: process(current_state, sensor_A, sensor_B, can_enter)
    begin
        -- Default values
        barrier <= '0';
        inc_car <= '0';
        gate_green_light <= '0';
        gate_red_light <= '0';
        
        case current_state is
            when IDLE =>
                gate_green_light <= '1';
                
            when CAR_DETECTED =>
                barrier <= '1';
                gate_green_light <= '1';
                
            when CAR_ENTERING =>
                barrier <= '1';
                gate_green_light <= '1';
                
            when CAR_ENTERED =>
                barrier <= '1';
                gate_green_light <= '1';
                
                -- Set inc_car when we transition out of this state
                if sensor_B = '0' then
                    inc_car <= '1';
                end if;
                
            when FULL =>
                gate_red_light <= '1';
                
                if can_enter = '1' then
                    gate_green_light <= '1';
                    gate_red_light <= '0';
                end if;
        end case;
        
        -- Override lighting based on capacity
        if current_state = IDLE and can_enter = '0' then
            gate_green_light <= '0';
            gate_red_light <= '1';
        end if;
    end process;
    
end architecture Behavioural;