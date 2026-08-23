## OVERVIEW
This UART module is able to transmit at 9600baud (slow mode) and 115200baud (fast mode).
Reception is possible at baudrates from 4800baud to 1Mbaud.
The implementation consists of two subsystems, namely TX and RX.

![Module block diagram](docs/images/uart_top-blockdiagram.svg)

Both subsystems are implemented as FSMDs (Finite State Machines with Datapath) largely using a two process design.

## APPLICATION NOTES
On startup, the reset port must be asserted low for at least one clock cycle. The module subsequently requires
one more clock cycle to revert to the idle state, ready to transmit/receive. Thus, transmission and reception can start on the next cycle.
![Reset sequence](docs/images/WaveformReset.png) 

If trig is applied during the first clock cycle after asserting rst low, the module will not read the sel input and default to operation in the slow mode at 9600 baud. 
Selection between the two modes is possible using the sel port.
Input on sel must be stable at least one cycle before toggling trig.
The data to be transmitted is passed to the TX-subsystem via the data_in_ser input and the trigger input must be
asserted high for at least one clock cycle to begin the transmission.
The data received is written to data_out_ser by the RX-subsystem when the stop bit has been read. The output value is set to 0x00 upon reset. If there has been an error during the reading process, error_out will be toggled for one clock cycle, and the RX-subsystem will return to idle state. The output will not be updated.
The RX-subsystem uses automatic baud rate detection (autobaud) to determine the baudrate of incoming transmissions.
Thus, after a reset, a defined sequence must be followed, as outlined below.

## AUTOBAUD OPERATION
After a reset, the RX-subsytem transitions into the state "DETECT_IDLE".
![FSM state diagram](docs/images/uart_rx-statemachine.svg)

In this state, the subsystem will wait for the beginning of a transmission of the ASCII character 'U' in order to determine the baud rate. This baud rate will be utilized until the next reset is started. Thus, a reset is necessary to change the baudrate of the receiver. The RX- and TX-subsystem's baud rates are indipendent and do not influence each other.

## SYNCHRONIZATION AND FILTERING

The rx_in input of the RX-subsystem is used after being routed through a two stage synchronizer and a filter. Filtering is accomplished by using a counter to keep track of the value of the current bit relative to the previous values. The counter is incremented in case of a '1' and decremented in case of a '0'. The maximum value is 3 and a minimum value of 0. Thus, to change a stable value, the opposite must be applied for at least 3 clock cycles in order to toggle the signal. The influence of noise is therefore minimized, preventing false starts or errors.