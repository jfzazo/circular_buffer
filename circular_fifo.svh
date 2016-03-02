//==================================================================================================
//  Filename      : circular_fifo.v
//  Created On    : 2016-03-02 11:37:20
//  Last Modified : 2016-03-02 12:55:11
//  Revision      : 1.0
//  Author        : Jose Fernando Zazo Rollon
//  Company       : Naudit
//  Email         : josefernando.zazo@naudit.es
//
//  Description   : A general circular fifo buffer implemented in systemverilog
//
//==================================================================================================

`ifndef CIRCULAR_FIFO_SVH_
`define CIRCULAR_FIFO_SVH_

interface circular_fifo # (parameter DATA_WIDTH = 512, BUFFER_SIZE = 16);
    /* Round the buffer size specified by the user to the closest power of 2 */
    function integer clog;
        input [31:0] value;
        integer  i;
        begin
            clog = 0;
            for(i = 0; 2**i < value; i = i + 1)
                clog = i + 1;
        end
    endfunction

    // Define the widths as local parameters
    localparam buffer_size_clog_c = clog(BUFFER_SIZE)      ;
    localparam buffer_size_c      = (1<<buffer_size_clog_c);


    // Buffer
    logic [DATA_WIDTH-1:0] data_buffer[buffer_size_c-1:0]; 
    // Number of elements inside the buffer
    logic [buffer_size_clog_c:0] bufd_occupancy;
    // Is the buffer full?
    logic                        bufd_full     ;
    // Next element to read
    logic [buffer_size_clog_c:0] bufd_rd_ptr   ;
    // Next position where it is possible to write
    logic [buffer_size_clog_c:0] bufd_wr_ptr   ;


    // Define some constants
    assign bufd_full      = bufd_occupancy[buffer_size_clog_c];
    assign bufd_occupancy = bufd_wr_ptr - bufd_rd_ptr;

    // And the function that truncates the vectors
    function [buffer_size_clog_c-1:0] trunc(input [buffer_size_clog_c:0] value);
        trunc = value[buffer_size_clog_c-1:0];
    endfunction

    /*
        Be careful with the following tasks because the result will be registered
    */

    task reset;
        begin
            for(int i = 0; i< buffer_size_c;  i++) begin
                data_buffer[i] <= 0;
            end
            bufd_rd_ptr <= 0;
            bufd_wr_ptr <= 0;
        end
    endtask

    task write;
        input logic [DATA_WIDTH-1:0] wdata;
        begin
            if(!bufd_full) begin
                data_buffer[trunc(bufd_wr_ptr)] <= wdata;
                bufd_wr_ptr <= bufd_wr_ptr +1;
            end
        end
    endtask


    task read;
        output logic [DATA_WIDTH-1:0] rdata;
        begin
            rdata = data_buffer[trunc(bufd_rd_ptr)];
        end
    endtask

    task read_next;
        input integer inc;
        output logic [DATA_WIDTH-1:0] rdata;
        begin
            rdata = data_buffer[trunc(bufd_rd_ptr+inc)];
        end
    endtask


    task forget;
        input integer inc;
        begin
            bufd_rd_ptr = bufd_rd_ptr+inc;
        end
    endtask

    task occupancy;
        output logic [buffer_size_clog_c:0]  occ;
        begin
            occ <= bufd_occupancy;
        end
    endtask


endinterface


`endif


