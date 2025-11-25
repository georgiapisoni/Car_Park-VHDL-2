library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Gate_Out is 
    generic (
        PARKING_CAPACITY : integer := 6
    );
    port (
        clk                      : in std_logic;
        nrst                     : in std_logic;
        sensor_A                 : in std_logic;
        sensor_B                 : in std_logic;
        payment_done             : in std_logic;
        can_exit                 : in std_logic;  -- Signal from controller indicating cars available to exit
        barrier                  : out std_logic;
        dec_car                  : out std_logic; -- Signal to controller to decrement car count
        payment_request          : out std_logic; -- Request payment from driver
        payment_accepted         : out std_logic  -- Signal that payment was accepted
    );
end Gate_Out;

architecture Behavioural of Gate_Out is
    type state_types is (IDLE, WAIT_PAYMENT, PAYMENT_OK, CAR_EXITING, CAR_EXITED);
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

    -- ------state transition process
    state_transition: process(current_state, sensor_A, sensor_B, payment_done, can_exit)
    begin
        next_state <= current_state;
        
        case current_state is
            when IDLE =>
                if sensor_A = '1' and can_exit = '1' then
                    next_state <= WAIT_PAYMENT;
                end if;
                
            when WAIT_PAYMENT =>
                if sensor_A = '0' then
                    next_state <= IDLE;
                elsif payment_done = '1' then
                    next_state <= PAYMENT_OK;
                end if;
                
            when PAYMENT_OK =>
                if sensor_B = '1' then
                    next_state <= CAR_EXITING;
                end if;
                
            when CAR_EXITING =>
                if sensor_A = '0' and sensor_B = '1' then
                    next_state <= CAR_EXITED;
                end if;
                
            when CAR_EXITED =>
                if sensor_B = '0' then
                    next_state <= IDLE;
                end if;
        end case;
    end process;

    -- Output process
    output_logic: process(current_state, sensor_A, sensor_B, payment_done, can_exit)
    begin
        -- Default values
        barrier <= '0';
        dec_car <= '0';
        payment_request <= '0';
        payment_accepted <= '0';
        
        case current_state is
            when IDLE =>
                null;
                
            when WAIT_PAYMENT =>
                payment_request <= '1';
                
            when PAYMENT_OK =>
                payment_accepted <= '1';
                
            when CAR_EXITING =>
                barrier <= '1';
                payment_accepted <= '1';
                
            when CAR_EXITED =>
                barrier <= '1';
                payment_accepted <= '1';
                
                -- Set decrement car count when transitioned out of state
                if sensor_B = '0' then
                    dec_car <= '1';
                end if;
        end case;
    end process;
    
end architecture Behavioural;