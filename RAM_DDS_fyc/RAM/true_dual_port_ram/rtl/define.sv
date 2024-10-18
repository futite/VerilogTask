`timescale 1ns/1ps
`define DATA_WIDTH  32
`define DATA_DEPTH  1024
//`define ADDR_WIDTH 10
//`define FIGHT_MODE  "read_first" //可配置为“读优先，写优先，保持
`define RAM_STYLE_VAL  "distributed" //"distributed"  //配置为distribute或者block
`define A_PORT_FIGHT_MODE  3   //"read_first" 可配置为“读优先，写优先，保持 为1、2、3
`define B_PORT_FIGHT_MODE  3  //"read_first" 可配置为“读优先，写优先，保持 为1、2、3
