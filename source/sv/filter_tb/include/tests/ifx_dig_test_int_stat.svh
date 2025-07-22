/**************************
 * (C) Copyright 2025 All Rights Reserved
 *
 * MODULE:
 * DEVICE:
 * PROJECT: SUMMER_SCHOOL_2025
 * AUTHOR:
 * DATE:
 * FILE:
 * REVISION:
 *
 * FILE DESCRIPTION:
 *
 ***************************/

class ifx_dig_test_int_stat extends ifx_dig_testbase;
    `uvm_component_utils(ifx_dig_test_int_stat)

    int filter_list[$];
    int reg_addresses[$];

    function new(string name = "ifx_dig_test_int_stat", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction : build_phase

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        `TEST_INFO("Run phase started")
    endtask

    task main_phase(uvm_phase phase);
        phase.raise_objection(this);
        super.main_phase(phase);
        write_reg_fields(
            .reg_name("FILTER_CTRL3"),
            .fields_names({"FILTER_TYPE"}),
            .fields_values({2'b11})
        );

        `TEST_INFO("start using read_reg")
        read_reg("FILTER_CTRL3");

        read_reg("INT_STATUS2");
        `TEST_INFO("Main phase started")
        for(int idx = 0; idx < 2**`AWIDTH; idx++) begin
            reg_addresses.push_back(idx);
        end
        for(int ifilt = 1; ifilt <= `FILT_NB; ifilt++) begin
            filter_list.push_back(ifilt);
        end
        foreach(filter_list[ifilt]) begin

            `TEST_INFO($sformatf("Testing filter: %0d. Configure randomly the filter, except the filter type and interrupt enable", filter_list[ifilt]))
            configure_filter(
                .filt_idx(filter_list[ifilt]),
                .filter_type(FILT_RISING),
                .int_en(1) // enable interrupt - to ensure IRQ responds to the filter
                // .wd_rst(FILT_ASYNC_RESET), // by not configuring the reset type, the default will be random
                // .window_size(2) // by not configuring the window size, the default will be random
            );
            `WAIT_NS(10)

            `TEST_INFO($sformatf("Drive a valid pulse length on filter: %0d", filter_list[ifilt]))
           // TODO: drive a valid pulse on the filter using the ifx_dig_pin_filter_uvc_pulse_sequence
            pin_filter_valid_pulse_seq.start(dig_env.v_seqr.p_pin_filter_uvc_seqr[filter_list[ifilt] - 1]);

            `WAIT_NS(100)
        end
    for(int idx = `FILT_NB; idx < 2**`AWIDTH; idx++) begin
        data_bus_write_seq.address = idx;
            data_bus_write_seq.data = 8'h00;
            data_bus_write_seq.start(dig_env.data_bus_uvc_agt.sequencer);
        `WAIT_NS(20)
    end
    `WAIT_NS(100)
    for(int idx = `FILT_NB; idx < 2**`AWIDTH; idx++) begin
        data_bus_read_seq.address = idx;
            data_bus_read_seq.start(dig_env.data_bus_uvc_agt.sequencer);
        `WAIT_NS(20)
    end
    foreach(filter_list[ifilt]) begin

            `TEST_INFO($sformatf("Testing filter: %0d. Configure randomly the filter, except the filter type and interrupt enable", filter_list[ifilt]))
            configure_filter(
                .filt_idx(filter_list[ifilt]),
                .filter_type(FILT_RISING),
                .int_en(1) // enable interrupt - to ensure IRQ responds to the filter
                // .wd_rst(FILT_ASYNC_RESET), // by not configuring the reset type, the default will be random
                // .window_size(2) // by not configuring the window size, the default will be random
            );
            `WAIT_NS(10)

            `TEST_INFO($sformatf("Drive a valid pulse length on filter: %0d", filter_list[ifilt]))
           // TODO: drive a valid pulse on the filter using the ifx_dig_pin_filter_uvc_pulse_sequence
            pin_filter_valid_pulse_seq.start(dig_env.v_seqr.p_pin_filter_uvc_seqr[filter_list[ifilt] - 1]);

            `WAIT_NS(100)
        end
        for(int idx = `FILT_NB; idx < 2**`AWIDTH; idx++) begin
        data_bus_write_seq.address = idx;
            data_bus_write_seq.data = 8'h11;
            data_bus_write_seq.start(dig_env.data_bus_uvc_agt.sequencer);
            `WAIT_NS(20)
        end
        for(int idx = `FILT_NB; idx < 2**`AWIDTH; idx++) begin
            data_bus_read_seq.address = idx;
            data_bus_read_seq.start(dig_env.data_bus_uvc_agt.sequencer);
            `WAIT_NS(20)
        end

        phase.drop_objection(this);
    endtask

endclass