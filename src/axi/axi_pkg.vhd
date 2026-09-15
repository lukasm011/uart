package axi_pkg is
    type axi_read_state_type is (IDLE, DECODE_1, DECODE_2, DATA);
    type axi_write_state_type is (IDLE, DECODE, DATA, RESP);
end;